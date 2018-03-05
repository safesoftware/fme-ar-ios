/*
See LICENSE folder for this sample’s licensing information.

Abstract:
UI Actions for the main view controller.
*/

import UIKit
import SceneKit

extension ViewController: UIPopoverPresentationControllerDelegate {
    
    enum SegueIdentifier: String {
        case showSettings
        case showAssets
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
        }
    }
    
    func getAssets() -> [Asset] {
        var assets = [Asset]()
        
        if let virtualObjectNode = self.sceneView.scene.rootNode.childNode(withName: "VirtualObject", recursively: true) {
            for childNode in virtualObjectNode.childNodes {
                if let name = childNode.name {
                    print("Asset Name = '\(name)' with opacity = \(childNode.opacity)")
                    assets.append(Asset(name: name, selected: childNode.opacity > 0.2))
                }
            }
        }
        
        return assets.sorted()
    }
}
