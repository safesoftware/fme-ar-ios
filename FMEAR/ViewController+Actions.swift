/*
See LICENSE folder for this sample’s licensing information.

Abstract:
UI Actions for the main view controller.
*/

import UIKit
import SceneKit
import SpriteKit

extension ViewController: UIPopoverPresentationControllerDelegate, SettingsViewControllerDelegate, ScaleOptionsViewControllerDelegate, OverlaySKSceneDelegate {
    
    enum SegueIdentifier: String {
        case showSettings
        case showAssets
        case showScaleOptions
    }
    
    // MARK: - Interface Actions
    
    @IBAction func chooseObject(_ button: UIButton) {
        // Abort if we are about to load another object to avoid concurrent modifications of the scene.
        if isLoadingObject { return }
        
        textManager.cancelScheduledMessage(forType: .contentPlacement)
        
        // Disable objects menu
        performSegue(withIdentifier: SegueIdentifier.showAssets.rawValue, sender: button)
    }
    
    /// - Tag: restartExperience
    @IBAction func restartExperience(_ sender: Any) {
        guard restartExperienceButtonIsEnabled, !isLoadingObject else { return }
        
//        if let document = self.document {
//            closeDocument(document: document)
//        }
//        documentOpened = false
        
        DispatchQueue.main.async {
            self.restartExperienceButtonIsEnabled = false
            
            self.textManager.cancelAllScheduledMessages()
            self.textManager.dismissPresentedAlert()
            self.textManager.showMessage("STARTING A NEW SESSION")
            
            self.virtualObjectManager.removeAllVirtualObjects()
            self.removeGeolocationNode()
            self.showAssetsButton.setImage(#imageLiteral(resourceName:"showAssets"), for: [])
            self.showAssetsButton.setImage(#imageLiteral(resourceName:"showAssetsPressed"), for: [.highlighted])
            self.showAssetsButton.isEnabled = false
            self.showScaleOptionsButton.isHidden = true
            self.focusSquare?.isHidden = true
            self.scaleLabel.isHidden = true
            self.expirationDateLabel.isHidden = true
            
            // Reset heading
            self.initialHeading = nil
            self.numHeadingUpdates = 0
            self.firstHeadings = []
            
            // Remove overlay labels
            self.sceneView.overlaySKScene?.removeAllChildren()
            
            self.resetTracking()
            
            self.restartExperienceButton.setImage(#imageLiteral(resourceName: "restart"), for: [])
            
            // Show the focus square after a short delay to ensure all plane anchors have been deleted.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.setupFocusSquare()
            })
            
            // Disable Restart button for a while in order to give the session enough time to restart.
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
                self.restartExperienceButtonIsEnabled = true
            })
            
            self.reloadAllDatasets()
        }
    }
    
    /// - Tag: backToDocumentBrowser
    @IBAction func backToDocumentBrowser(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    // MARK: - SettingsViewControllerDelegate
    
    func settingsViewControllerDelegate(_: SettingsViewController, didToggleLightEstimation on: Bool) {
        if !on {
            // If the light estimation is toggled off, we should reapply the
            // light intensity and temperature to the light nodes since they were using the
            // light estimation
            setLightIntensity(intensity: lightIntensity)
            setLightTemperature(temperature: lightTemperature)
        }
    }
    
    func settingsViewControllerDelegate(_: SettingsViewController, didToggleDrawDetectedPlane on: Bool) {
        for (_, plane) in planes {
            plane.isHidden = !on
        }
    }
    
    func settingsViewControllerDelegate(_: SettingsViewController, didToggleDrawAnchor on: Bool) {
        overlayView.childNode(withName: self.viewpointLabelName)?.isHidden = !on
        setViewpointsVisible(visible: on)
    }
    
    func settingsViewControllerDelegate(_: SettingsViewController, didToggleDrawGeomarker on: Bool) {
        geolocationNode()?.updateVisibility()
        overlayView.childNode(withName: self.geomarkerLabelName)?.isHidden = !on
    }
    
    func settingsViewControllerDelegate(_: SettingsViewController, didToggleShowCenterDistance on: Bool) {
        self.centerObjectDistanceLabel.isHidden = !on
        self.centerMarker.isHidden = !on
    }
    
    func settingsViewControllerDelegate(_: SettingsViewController, didToggleEnablePeopleOcclusion on: Bool) {
        self.updateFrameSemantics()
    }

    func settingsViewControllerDelegate(_: SettingsViewController, didChangeScale scale: Float) {
        if let virtualObjectNode = virtualObject() {

            let duration = max(3.0, min(5.0, scale / virtualObjectNode.scale.x))
            print("Animating scale from '\(virtualObjectNode.scale)' to '\(scale)' in a duration of '\(duration)'")
            print("Pivot = \(virtualObjectNode.pivot)")

            let scaleAction = SCNAction.scale(to: CGFloat(scale), duration: Double(duration))

            virtualObjectNode.runAction(scaleAction)
        }
    }
    
    func settingsViewControllerDelegate(_: SettingsViewController, didChangeIntensity intensity: Float) {
        setLightIntensity(intensity: CGFloat(intensity))
    }
    
    func settingsViewControllerDelegate(_: SettingsViewController, didChangeTemperature temperature: Float) {
        setLightTemperature(temperature: CGFloat(temperature))
    }
    
    func setLightIntensity(intensity: CGFloat) {
        lightIntensity = intensity
        for (_, light) in self.lights.enumerated() {
            light.intensity = intensity
        }
    }

    func setLightTemperature(temperature: CGFloat) {
        lightTemperature = temperature
        for (_, light) in self.lights.enumerated() {
            light.temperature = temperature
        }
    }
    
    // MARK: - OverlaySKSceneDelegate
    
    func overlaySKSceneDelegate(_ overlayView: OverlaySKScene, didTapNode nodeName: String?) {
        
        if let nodeName = nodeName {
            print("Tapped \(nodeName)")
            
            if nodeName == self.geomarkerLabelName, let geolocationNode = self.geolocationNode() {
                
                if self.updateUserLocationEnabled {
                    // Disable user location (and geolocation anchor) update since
                    // we are going into a modal dialog.
                    self.updateUserLocationEnabled = false
                    
                    var coordinates = ""
                    if let geolocation = geolocationNode.geolocation {
                        let latitude = String(format: "%.6f", geolocation.coordinate.latitude)
                        let longitude = String(format: "%.6f", geolocation.coordinate.longitude)
                        coordinates = " (\(latitude),\(longitude))"
                    }
                    
                    let dialogMessage = UIAlertController(title: "Move Model",
                                                          message: "Are you sure you want to move the model to the geolocation anchor at \(coordinates)?", preferredStyle: .alert)
                    
                    // Create OK button with action handler
                    let ok = UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
                        self.moveModelToGeolocation()
                        self.serialQueue.async {
                            if let geomarkerLabelNode = self.overlayView.labelNodeOrNil(labelName: self.geomarkerLabelName) {
                                geomarkerLabelNode.callToActionText = Texts.rescan
                            }
                        }
                    })
                    
                    // Create Cancel button with action handlder
                    let cancel = UIAlertAction(title: "No", style: .cancel) { (action) -> Void in
                        // Re-enable user location update
                        geolocationNode.userLocation = self.latestLocation
                        self.updateUserLocationEnabled = true
                    }
                    
                    // Present dialog message to user
                    dialogMessage.addAction(ok)
                    dialogMessage.addAction(cancel)
                    self.present(dialogMessage, animated: true, completion: nil)
                } else {
                    let dialogMessage = UIAlertController(title: "Rescan location",
                                                          message: "Do you want to rescan the geolocation?", preferredStyle: .alert)
                    
                    // Create OK button with action handler
                    let ok = UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
                        geolocationNode.userLocation = self.latestLocation
                        self.updateUserLocationEnabled = true
                        self.serialQueue.async {
                            if let geomarkerLabelNode = self.overlayView.labelNodeOrNil(labelName: self.geomarkerLabelName) {
                                geomarkerLabelNode.callToActionText = Texts.moveModel
                            }
                        }
                    })
                    
                    let cancel = UIAlertAction(title: "No", style: .cancel) { (action) -> Void in
                        // Do nothing
                    }
                    
                    // Present dialog message to user
                    dialogMessage.addAction(ok)
                    dialogMessage.addAction(cancel)
                    self.present(dialogMessage, animated: true, completion: nil)
                }
                
            } else if let uuid = UUID(uuidString: nodeName), let model = virtualObject() {
                if let viewpoint = model.viewpoint(id: uuid) {
                    
                    if viewpoint.id != model.currentViewpoint {
                        
                        let viewpointName = viewpoint.name ?? "this viewpoint"
                        
                        let dialogMessage = UIAlertController(title: "Set Current Viewpoint", message: "Do you want to use \'\(viewpointName)\' as the current viewpoint?", preferredStyle: .alert)
                        
                        // Create OK button with action handler
                        let ok = UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
                            print("Ok button tapped")
                            
                            // Restore the original viewpoint label
                            if let currentViewpointId = model.currentViewpoint {
                                if let currentViewpoint = model.viewpoint(id: currentViewpointId) {
                                    self.serialQueue.async {
                                        if let currentViewpointNode = overlayView.labelNodeOrNil(labelName: currentViewpoint.id.uuidString) {
                                            currentViewpointNode.secondaryText = ""
                                            currentViewpointNode.callToAction = true
                                        }
                                    }
                                }
                            }
                            
                            model.anchorAtViewpoint(viewpointId: viewpoint.id)
    
                            self.serialQueue.async {
                                if let newCurrentViewpointNode = overlayView.labelNodeOrNil(labelName: viewpoint.id.uuidString) {
                                    newCurrentViewpointNode.secondaryText = "CURRENT VIEWPOINT"
                                    newCurrentViewpointNode.callToAction = false
                                }
                            }
                        })
                        
                        // Create Cancel button with action handlder
                        let cancel = UIAlertAction(title: "No", style: .cancel) { (action) -> Void in
                            print("Cancel button tapped")
                        }
                        
                        dialogMessage.addAction(ok)
                        dialogMessage.addAction(cancel)

                        // Present dialog message to user
                        self.present(dialogMessage, animated: true, completion: nil)
                    }
                }
            }
        }
    }

    // MARK: - UIPopoverPresentationControllerDelegate
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        // All popover segues should be popovers even on iPhone.
        if let popoverController = segue.destination.popoverPresentationController, let button = sender as? UIButton {
            popoverController.delegate = self
            popoverController.sourceRect = button.bounds
        }
        
        guard let identifier = segue.identifier, let segueIdentifer = SegueIdentifier(rawValue: identifier) else { return }
        if segueIdentifer == .showAssets, let assetViewController = segue.destination as? AssetViewController {
            assetViewController.delegate = self
            assetViewController.assets = getAssets()
        } else if segueIdentifer == .showSettings, let settingsViewController = segue.destination as? SettingsViewController {
            // Update the scale to the current model scale
            settingsViewController.delegate = self
            settingsViewController.scale = currentScale()
            settingsViewController.intensity = Float(lightIntensity)
        } else if segueIdentifer == .showScaleOptions, let scaleOptionsViewController = segue.destination as? ScaleOptionsViewController {
            scaleOptionsViewController.delegate = self
            scaleOptionsViewController.setValues(dimension: modelDimension(),
                                                 scaleMode: self.scaleMode,
                                                 scaleLockEnabled: self.scaleLockEnabled,
                                                 currentScale: currentScale())
        }
    }
    
    func getAssets() -> [Asset] {
        var assets = [Asset]()
        
        if let virtualObjectNode = self.sceneView.scene.rootNode.childNode(withName: "VirtualObjectContent", recursively: true) {
            for childNode in virtualObjectNode.childNodes {
                if let name = childNode.name {
                    if name != VirtualObject.viewpointParentNodeName {
                        print("Asset Name = '\(name)' with opacity = \(childNode.opacity)")
                        assets.append(Asset(name: name, selected: childNode.opacity > 0.2))
                    }
                }
            }
        }
        
        return assets.sorted()
    }

    // MARK: - ScaleOptionsViewControllerDelegate
    func setShowScaleOptionsButton(mode: ScaleMode, lockOn: Bool) {
        self.scaleMode = mode
        self.scaleLockEnabled = lockOn
        showScaleOptionsButton.setTitle(scaleOptionsButtonText(mode: mode, lockOn: lockOn), for: .normal)
        virtualObjectManager.allowScaling = !lockOn
    }
    
    func scaleOptionsViewControllerDelegate(_: ScaleOptionsViewController, didChangeScaleMode mode: ScaleMode, lockOn: Bool) {
        setShowScaleOptionsButton(mode: mode, lockOn: lockOn)
    }

    func scaleOptionsViewControllerDelegate(_: ScaleOptionsViewController, didChangeScale scale: Float) {
        setScale(scale: scale)
        if let virtualObjectNode = virtualObject() {
            let (minBounds, maxBounds) = virtualObjectNode.boundingBox
            scaleLabel.text = dimensionAndScaleText(scale: 1.0, boundingBoxMin: minBounds, boundingBoxMax: maxBounds)
        }
    }
    
    // MARK: - Viewpoints
    func setViewpointsVisible(visible: Bool) {
        if let virtualObject = virtualObject() {
            for viewpoint in virtualObject.viewpoints {
                self.serialQueue.async {
                    if let viewpointLabelNode = self.overlayView.labelNodeOrNil(labelName: viewpoint.id.uuidString) {
                        viewpointLabelNode.isHidden = !visible
                    }
                }
            }
        }
    }
}
