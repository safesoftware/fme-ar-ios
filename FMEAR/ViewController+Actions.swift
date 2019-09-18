/*
See LICENSE folder for this sample’s licensing information.

Abstract:
UI Actions for the main view controller.
*/

import UIKit
import SceneKit

extension ViewController: UIPopoverPresentationControllerDelegate, SettingsViewControllerDelegate, ScaleOptionsViewControllerDelegate {
    
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
        
        if let document = self.document {
            closeDocument(document: document)
        }
        
        DispatchQueue.main.async {
            self.restartExperienceButtonIsEnabled = false
            
            self.textManager.cancelAllScheduledMessages()
            self.textManager.dismissPresentedAlert()
            self.textManager.showMessage("STARTING A NEW SESSION")
            
            self.virtualObjectManager.removeAllVirtualObjects()
            self.showAssetsButton.setImage(#imageLiteral(resourceName:"showAssets"), for: [])
            self.showAssetsButton.setImage(#imageLiteral(resourceName:"showAssetsPressed"), for: [.highlighted])
            self.showAssetsButton.isEnabled = false
            self.focusSquare?.isHidden = true
            self.scaleLabel.isHidden = true
            
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
        }
    }
    
    /// - Tag: backToDocumentBrowser
    @IBAction func backToDocumentBrowser(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
            scaleOptionsViewController.preferredContentSize = CGSize(width: 350, height: 200)
            scaleOptionsViewController.dimension = modelDimension()
            scaleOptionsViewController.currentScale = currentScale()
        }
    }
    
    func getAssets() -> [Asset] {
        var assets = [Asset]()
        
        if let virtualObjectNode = self.sceneView.scene.rootNode.childNode(withName: "VirtualObjectContent", recursively: true) {
            for childNode in virtualObjectNode.childNodes {
                if let name = childNode.name {
                    print("Asset Name = '\(name)' with opacity = \(childNode.opacity)")
                    assets.append(Asset(name: name, selected: childNode.opacity > 0.2))
                }
            }
        }
        
        return assets.sorted()
    }

    // MARK: - ScaleOptionsViewControllerDelegate
    func scaleOptionsViewControllerDelegate(_: ScaleOptionsViewController, didChangeScaleMode mode: ScaleMode, lockOn: Bool) {
        showScaleOptionsButton.setTitle(scaleOptionsButtonText(mode: mode, lockOn: lockOn), for: .normal)
    }

    func scaleOptionsViewControllerDelegate(_: ScaleOptionsViewController, didChangeScale scale: Float) {
        setScale(scale: scale)
        if let virtualObjectNode = virtualObject() {
            let (minBounds, maxBounds) = virtualObjectNode.boundingBox
            scaleLabel.text = dimensionAndScaleText(scale: 1.0, boundingBoxMin: minBounds, boundingBoxMax: maxBounds)
        }
    }
}
