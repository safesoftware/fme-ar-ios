/*
See LICENSE folder for this sample’s licensing information.

Abstract:
ARSCNViewDelegate interactions for `ViewController`.
*/

import ARKit

extension ViewController: ARSCNViewDelegate {
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        updateFocusSquare()
        updateLights()
        updateModelIndicators()
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
        DispatchQueue.main.async{
            
            // Hide all indicators first
            self.modelIndicatorUp.isHidden = true
            self.modelIndicatorDown.isHidden = true
            self.modelIndicatorLeft.isHidden = true
            self.modelIndicatorRight.isHidden = true
            
            // If there is a model but it's outside the screen, we use one or
            // more indicators to show where to find the model.
            if let virtualObjectNode = self.virtualObject() {
                if let pointOfView = self.sceneView.pointOfView {
                    if !self.sceneView.isNode(virtualObjectNode, insideFrustumOf: pointOfView) {
                        let screenPosition = self.sceneView.projectPoint(virtualObjectNode.position)
                        self.modelIndicatorUp.isHidden = (screenPosition.y > Float(self.sceneView.bounds.minY))
                        self.modelIndicatorDown.isHidden = (screenPosition.y < Float(self.sceneView.bounds.maxY))
                        self.modelIndicatorLeft.isHidden = (screenPosition.x > Float(self.sceneView.bounds.minX))
                        self.modelIndicatorRight.isHidden = (screenPosition.x < Float(self.sceneView.bounds.maxX))
                    }
                }
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        //print("ADD \(anchor.identifier): \(anchor.transform)")

        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        serialQueue.async {
            self.addPlane(node: node, anchor: planeAnchor)
            self.virtualObjectManager.checkIfObjectShouldMoveOntoPlane(anchor: planeAnchor, planeAnchorNode: node)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        //print("UPDATE \(anchor.identifier): \(anchor.transform)")

        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        serialQueue.async {
            self.updatePlane(node: node, anchor: planeAnchor)
            self.virtualObjectManager.checkIfObjectShouldMoveOntoPlane(anchor: planeAnchor, planeAnchorNode: node)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        serialQueue.async {
            self.removePlane(node: node, anchor: planeAnchor)
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
        
        let nsError = error as NSError
        var sessionErrorMsg = "\(nsError.localizedDescription) \(nsError.localizedFailureReason ?? "")"
        if let recoveryOptions = nsError.localizedRecoveryOptions {
            for option in recoveryOptions {
                sessionErrorMsg.append("\(option).")
            }
        }
        
        let isRecoverable = (arError.code == .worldTrackingFailed)
        if isRecoverable {
            sessionErrorMsg += "\nYou can try resetting the session or quit the application."
        } else {
            sessionErrorMsg += "\nThis is an unrecoverable error that requires to quit the application."
        }
        
        displayErrorMessage(title: "We're sorry!", message: sessionErrorMsg, allowRestart: isRecoverable)
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
