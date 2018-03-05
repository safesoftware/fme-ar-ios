/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Methods on the main view controller for handling virtual object loading and movement
*/

import UIKit
import SceneKit

extension ViewController: VirtualObjectSelectionViewControllerDelegate, AssetViewControllerDelegate, VirtualObjectManagerDelegate {
    
    // MARK: - assetViewControllerDelegate
    func assetViewControllerDelegate(_: AssetViewController, didSelectAsset asset: Asset) {
        if let virtualObjectNode = self.sceneView.scene.rootNode.childNode(withName: "VirtualObject", recursively: true) {
            for childNode in virtualObjectNode.childNodes {
                if asset.name == childNode.name {
                    let fadeInAction = SCNAction.fadeIn(duration: 0.5)
                    childNode.runAction(fadeInAction)
                }
            }
        }
    }
    
    func assetViewControllerDelegate(_: AssetViewController, didDeselectAsset asset: Asset) {
        if let virtualObjectNode = self.sceneView.scene.rootNode.childNode(withName: "VirtualObject", recursively: true) {
            for childNode in virtualObjectNode.childNodes {
                if asset.name == childNode.name {
                    let fadeOutAction = SCNAction.fadeOut(duration: 0.5)
                    childNode.runAction(fadeOutAction)
                }
            }
        }
    }
    
    
    // MARK: - VirtualObjectManager delegate callbacks
    
    func virtualObjectManager(_ manager: VirtualObjectManager, willLoad object: VirtualObject) {
        DispatchQueue.main.async {
            // Show progress indicator
            self.spinner = UIActivityIndicatorView()
            self.spinner!.center = self.showAssetsButton.center
            self.spinner!.bounds.size = CGSize(width: self.showAssetsButton.bounds.width - 5, height: self.showAssetsButton.bounds.height - 5)
            self.showAssetsButton.setImage(#imageLiteral(resourceName: "buttonring"), for: [])
            self.sceneView.addSubview(self.spinner!)
            self.spinner!.startAnimating()
            
            self.isLoadingObject = true
        }
    }
    
    func virtualObjectManager(_ manager: VirtualObjectManager, didLoad object: VirtualObject) {
        DispatchQueue.main.async {
            self.isLoadingObject = false
            
            // Remove progress indicator
            self.spinner?.removeFromSuperview()
            self.showAssetsButton.setImage(#imageLiteral(resourceName:"showAssets"), for: [])
            self.showAssetsButton.setImage(#imageLiteral(resourceName:"showAssetsPressed"), for: [.highlighted])
        }
    }
    
    func virtualObjectManager(_ manager: VirtualObjectManager, couldNotPlace object: VirtualObject) {
        textManager.showMessage("CANNOT PLACE OBJECT\nTry moving left or right.")
    }
    
    // MARK: - VirtualObjectSelectionViewControllerDelegate
    
    func virtualObjectSelectionViewController(_: VirtualObjectSelectionViewController, didSelectObjectAt index: Int) {
        guard let cameraTransform = session.currentFrame?.camera.transform else {
            return
        }
        
        let definition = VirtualObjectManager.availableObjects[index]
        let object = VirtualObject(definition: definition)
        let position = focusSquare?.lastPosition ?? float3(0)
        virtualObjectManager.loadVirtualObject(object, to: position, cameraTransform: cameraTransform)
        if object.parent == nil {
            serialQueue.async {
                self.sceneView.scene.rootNode.addChildNode(object)
            }
        }
    }
    
    func virtualObjectSelectionViewController(_: VirtualObjectSelectionViewController, didDeselectObjectAt index: Int) {
        virtualObjectManager.removeVirtualObject(at: index)
    }



}
