/*
See LICENSE folder for this sample’s licensing information.

Abstract:
ARSCNViewDelegate interactions for `ViewController`.
*/

import ARKit
import CoreLocation

extension SCNVector3 {
    static func distanceFrom(vector vector1: SCNVector3, toVector vector2: SCNVector3) -> Float {
        let x0 = vector1.x
        let x1 = vector2.x
        let y0 = vector1.y
        let y1 = vector2.y
        let z0 = vector1.z
        let z1 = vector2.z

        return sqrtf(powf(x1-x0, 2) + powf(y1-y0, 2) + powf(z1-z0, 2))
    }
}

extension ViewController: ARSCNViewDelegate {
    // MARK: - ARSCNViewDelegate

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        updateDatasets()
        updateFocusSquare()
        updateLights()
        updateModelIndicators()
        updateOverlay()
    }
    
    func updateDatasets() {
        guard let cameraTransform = self.session.currentFrame?.camera.transform else {
            return
        }
        
        guard let focusSquare = self.focusSquare else {
            return
        }
        
        if self.planes.isEmpty {
            return
        }
        
        for (url, dataset) in datasetsReady {
            guard let model = dataset.model as? VirtualObject else {
                print("Failed to read the model from \(url)")
                continue
            }
            
            // Update the snapshot in the compass
            self.overlayView.compass().image = dataset.snapshot

            let position = focusSquare.lastPosition ?? SIMD3<Float>(0, 0, -5)
            
            self.virtualObjectManager.loadVirtualObject(model, to: position, cameraTransform: cameraTransform)

            self.sceneView.scene.rootNode.addChildNode(model)
                                
            // Add Viewpoint labels
            if model.viewpoints.isEmpty {
                let viewpointLabelNode = self.overlayView.labelNode(labelName: self.viewpointLabelName,
                                                                iconNamed: LabelIcons.geolocationAnchor.rawValue)
                viewpointLabelNode.isHidden = !(UserDefaults.standard.bool(for: .drawAnchor))
                viewpointLabelNode.callToAction = false
                viewpointLabelNode.text = "Anchor"
            } else {
                for index in model.viewpoints.indices {
                    let viewpoint = model.viewpoints[index]
                    
                    let viewpointLabelNode = self.overlayView.labelNode(labelName: viewpoint.id.uuidString,
                                                                    iconNamed: LabelIcons.viewpoint.rawValue)
                    
                    if (model.currentViewpoint == viewpoint.id) {
                        viewpointLabelNode.secondaryText = "CURRENT VIEWPOINT"
                        viewpointLabelNode.callToAction = false
                    } else {
                        viewpointLabelNode.callToAction = true
                    }
                    
                    if let name = viewpoint.name, !name.isEmpty {
                        viewpointLabelNode.text = name

                    } else {
                        viewpointLabelNode.text = "Viewpoint \(index)"
                        model.viewpoints[index].name = viewpointLabelNode.text
                    }
                }
            }
            
            if let anchors = dataset.settings?.anchors {
                if let firstAnchor = anchors.first {
                    if let coordinate = firstAnchor.coordinate {
                        var geomarker = self.geolocationNode()
                        if geomarker == nil {
                            geomarker = self.addGeolocationNode()
                        }
                        geomarker!.geolocation = CLLocation(latitude: coordinate.latitude,
                                                         longitude: coordinate.longitude)
                        geomarker!.simdPosition = position
                        geomarker!.anchor = dataset.settings?.anchors.first
                        geomarker!.isHidden = true
                        
                        // If there is a geolocation, we should always show
                        // the geolocation at the beginning
                        UserDefaults.standard.set(true, for: .drawGeomarker)
                    }
                }
            }
            
            // TODO: Move this UI block to somewhere better
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }

                self.showAssetsButton.isEnabled = true
                self.showScaleOptionsButton.isHidden = false
                self.scaleLabel.isHidden = false
                self.scaleLabel.text = self.dimensionAndScaleText(scale: model.scale.x, node: model)
                
                // Udate scale
                var allowScaling = true
                var scaleMode = ScaleMode.customScale
                if let scaling = dataset.settings?.scaling {
                    allowScaling = false
                    if scaling == 1.0 {
                        scaleMode = .fullScale
                    }
                }
                self.setShowScaleOptionsButton(mode: scaleMode, lockOn: !allowScaling)
                
                if let date = dataset.settings?.metadata?.modelExpiry {

                    // Create date from components
                    let userCalendar = Calendar.current // user calendar
                    let hour = userCalendar.component(.hour, from: date)
                    let minute = userCalendar.component(.minute, from: date)
                    let second = userCalendar.component(.second, from: date)
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.timeZone = .current
                    if hour == 23 && minute == 59 && second == 59 {
                        dateFormatter.dateFormat = "MMM d,yyyy"
                    } else {
                        dateFormatter.dateFormat = "MMM d,yyyy HH:mm:ss"
                    }
                    
                    let dateString = dateFormatter.string(from: date)

                    self.expirationDateLabel.isHidden = false
                    
                    if date < Date() {
                        self.expirationDateLabel.backgroundColor = .red
                        self.expirationDateLabel.setTitle("Model expired on \(dateString)", for: .normal)
                    } else {
                        self.expirationDateLabel.backgroundColor = .darkGray
                         self.expirationDateLabel.setTitle("Model will expire on \(dateString)", for: .normal)
                    }
                }
            }
        }
        
        datasetsReady.removeAll()
    }
    
    func updateLights() {
        // If light estimation is enabled, update the intensity of the model's lights
        var lightIntensity: CGFloat = 1000
        var lightTemperature: CGFloat = 6500
        let lightEstimationEnabled = UserDefaults.standard.bool(for: .estimateLight)
        if lightEstimationEnabled {
            if let lightEstimate = session.currentFrame?.lightEstimate {
                lightIntensity = lightEstimate.ambientIntensity
                lightTemperature = lightEstimate.ambientColorTemperature
                //print("light estimate: \(ambientIntensity); light temperature: \(ambientColorTemperature)")
            }
            
            for (_, light) in self.lights.enumerated() {
                light.intensity = lightIntensity
                light.temperature = lightTemperature
            }
        }
    }
    
    func updateModelIndicators() {
        
        var screenPosition: SCNVector3?
        
        // If there is a model but it's outside the screen, we use one or
        // more indicators to show where to find the model.
        if let virtualObjectNode = self.virtualObject() {
            if let pointOfView = self.sceneView.pointOfView {
                if !self.sceneView.isNode(virtualObjectNode, insideFrustumOf: pointOfView) {
                    screenPosition = self.sceneView.projectPoint(virtualObjectNode.position)
                }
            }
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }

            if let screenPosition = screenPosition {
                self.modelIndicatorUp.isHidden = (screenPosition.y > Float(self.sceneView.bounds.minY))
                self.modelIndicatorDown.isHidden = (screenPosition.y < Float(self.sceneView.bounds.maxY))
                self.modelIndicatorLeft.isHidden = (screenPosition.x > Float(self.sceneView.bounds.minX))
                self.modelIndicatorRight.isHidden = (screenPosition.x < Float(self.sceneView.bounds.maxX))
            } else {
                self.modelIndicatorUp.isHidden = true
                self.modelIndicatorDown.isHidden = true
                self.modelIndicatorLeft.isHidden = true
                self.modelIndicatorRight.isHidden = true
            }
        }
    }
    
    func updateOverlay() {
        if let geomarker = self.geolocationNode() {
            if let userLocation = geomarker.userLocation, let markerLocation = geomarker.geolocation {

                let worldPosition = geomarker.position
                let geomarkerPosition = SCNVector3(worldPosition.x, worldPosition.y, worldPosition.z)
                let screenCoord = self.sceneView.projectPoint(geomarkerPosition)
                let distance = String(format: "%.2f", markerLocation.distance(from: userLocation))

                if self.viewSize.width > 0 && self.viewSize.height > 0 {
                    // When the z is larger than 1, the geomarker is actually at
                    // the opposite direction or invalid, and the screenCoord.x is wrong.
                    // We can simply use a very large screen value, such as 10000,
                    // to make the geolocation offscreen.
                    let geomarkerScreenPosition = CGPoint(
                        x: (screenCoord.z <= 1.0) ? CGFloat(screenCoord.x) : 10000,
                        y: self.viewSize.height - CGFloat(screenCoord.y))

                    var labelNode = self.overlayView.labelNodeOrNil(labelName: self.geomarkerLabelName)
                    if labelNode == nil {
                        labelNode = self.overlayView.labelNode(labelName: self.geomarkerLabelName, iconNamed: LabelIcons.geolocationAnchor.rawValue)
                        labelNode!.secondaryText = "GEOLOCATION ANCHOR"
                        labelNode!.alwaysVisibleOnScreen = true
                        labelNode!.callToAction = true
                        labelNode!.callToActionText = Texts.moveModel
                    }

                    labelNode!.isHidden = geomarker.isHidden

                    if let node = labelNode {
                        node.text = "\(distance)m"
                        
                        if node.point != geomarkerScreenPosition {
                            node.point = geomarkerScreenPosition
                        }
                    }
                }
            }
        }

        // Update viewpoint labels
        if let virtualObject = virtualObject() {
            
            // json.settings version 4
            for viewpoint in virtualObject.viewpoints {
                if let vPos = virtualObject.viewpointWorldPosition(viewpointId: viewpoint.id),
                   let labelNode = self.overlayView.labelNodeOrNil(labelName: viewpoint.id.uuidString),
                   let pointOfView = self.sceneView.pointOfView,
                   let viewpointNode = virtualObject.viewpointNode(viewpointId: viewpoint.id) {
                    
                    // See if we the viewpoint is within the point of view. If yes,
                    // we update it's position. If not, we hide the label.
                    if self.sceneView.isNode(viewpointNode, insideFrustumOf: pointOfView) {
                        let screenCoord = self.sceneView.projectPoint(vPos)
                        if viewSize.width > 0 && viewSize.height > 0 {
                            // When the z is larger than 1, the geomarker is actually at
                            // the opposite direction or invalid, and the screenCoord.x is wrong.
                            // We can simply use a very large screen value, such as 10000,
                            // to make the geolocation offscreen.
                            let screenPosition = CGPoint(
                                x: (screenCoord.z <= 1.0) ? CGFloat(screenCoord.x) : 10000,
                                y: viewSize.height - CGFloat(screenCoord.y))

                            labelNode.point = screenPosition
                            labelNode.isHidden = !(UserDefaults.standard.bool(for: .drawAnchor))
                        }
                    }
                    else {
                        labelNode.isHidden = true
                    }
                }
            }
            
            // json.settings version 3
            if let labelNode = self.overlayView.labelNodeOrNil(labelName: self.viewpointLabelName) {
                let modelPosition = SCNVector3(virtualObject.position.x,
                                               virtualObject.position.y,
                                               virtualObject.position.z)
                let screenCoord = self.sceneView.projectPoint(modelPosition)

                if self.viewSize.width > 0 && self.viewSize.height > 0 {
                    // When the z is larger than 1, the geomarker is actually at
                    // the opposite direction or invalid, and the screenCoord.x is wrong.
                    // We can simply use a very large screen value, such as 10000,
                    // to make the geolocation offscreen.
                    let screenPosition = CGPoint(
                        x: (screenCoord.z <= 1.0) ? CGFloat(screenCoord.x) : 10000,
                        y: self.viewSize.height - CGFloat(screenCoord.y))
                    
                        labelNode.point = screenPosition
                }
                
                labelNode.isHidden = !(UserDefaults.standard.bool(for: .drawAnchor))
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        serialQueue.async { [weak self] in
            self?.addPlane(node: node, anchor: planeAnchor)
            self?.virtualObjectManager.checkIfObjectShouldMoveOntoPlane(anchor: planeAnchor, planeAnchorNode: node)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        serialQueue.async { [weak self] in
            self?.updatePlane(node: node, anchor: planeAnchor)
            self?.virtualObjectManager.checkIfObjectShouldMoveOntoPlane(anchor: planeAnchor, planeAnchorNode: node)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        serialQueue.async { [weak self] in
            self?.removePlane(node: node, anchor: planeAnchor)
        }
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        textManager.showTrackingQualityInfo(for: camera.trackingState, autoHide: true)
        
        switch camera.trackingState {
        case .notAvailable:
            fallthrough
        case .limited:
            textManager.escalateFeedback(for: camera.trackingState, inSeconds: 3.0)
        case .normal:
            textManager.cancelScheduledMessage(forType: .trackingStateEscalation)
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        guard let arError = error as? ARError else { return }
        
        var title = "Error"
        var isRecoverable = false
        let nsError = error as NSError
        var sessionErrorMsg = "\(nsError.localizedDescription) \(nsError.localizedFailureReason ?? "")"
        if let recoveryOptions = nsError.localizedRecoveryOptions {
            for option in recoveryOptions {
                sessionErrorMsg.append("\(option).")
            }
        }

        switch arError.code {
        case .cameraUnauthorized:
            title = "Camera Unauthorized"
        case .unsupportedConfiguration:
            title = "Unsupported Configuration"
        case .sensorUnavailable:
            title = "Sensor Unavailable"
        case .sensorFailed:
            title = "Sensor Failed"
            setARWorldTrackingConfiguration(worldAlignment: .gravity)
            isRecoverable = true
            sessionErrorMsg += "\nFailed to access the direction. You can reset the session without direction access."
        case .microphoneUnauthorized:
            title = "Microphone Unauthorized"
        case .worldTrackingFailed:
            title = "World Tracking Failed"
            isRecoverable = true
            sessionErrorMsg += "\nYou can try resetting the session or quit the application."
        case .invalidReferenceImage:
            title = "Invalid Reference Image"
        case .invalidReferenceObject:
            title = "Invalid Reference Object"
        case .invalidWorldMap:
            title = "Invalid World Map"
        case .invalidConfiguration:
            title = "Invalid Configuration"
        case .collaborationDataUnavailable:
            title = "Collaboration Data Unavailable"
        case .insufficientFeatures:
            title = "Insufficient Features"
        case .objectMergeFailed:
            title = "Object Merge Failed"
        case .fileIOFailed:
            title = "File IO Failed"
        case .locationUnauthorized:
            title = "Location Unauthorized"
        case .geoTrackingNotAvailableAtLocation:
            title = "Geo-Tracking Not Available At Location"
        case .geoTrackingFailed:
            title = "Geo-Tracking Failed"
        case .requestFailed:
            title = "Request Failed"
        @unknown default:
            title = "Unknown Error"
        }
        
        if !isRecoverable {
            sessionErrorMsg += "\nThis is an unrecoverable error that requires to quit the application."
        }
        
        displayErrorMessage(title: title, message: sessionErrorMsg, allowRestart: isRecoverable)
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        textManager.blurBackground()
        textManager.showAlert(title: "Session Interrupted", message: "The session will be reset after the interruption has ended.")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        textManager.unblurBackground()
        session.run(standardConfiguration, options: [.resetTracking, .removeExistingAnchors])
        restartExperience(self)
        textManager.showMessage("RESETTING SESSION")
    }
}
