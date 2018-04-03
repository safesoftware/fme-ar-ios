/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Methods on the main view controller for handling virtual object loading and movement
*/

import UIKit
import SceneKit
import Foundation
import SceneKit.ModelIO

extension ViewController: FileManagerDelegate {

    func openDocument(document: UIDocument) {
        // Access the document
        document.open(completionHandler: { (success) in
            if success {
                // Display the content of the document, e.g.:
                //self.documentNameLabel.text = self.document?.fileURL.lastPathComponent
                print("Opening document '\(document.fileURL)'...")
                let documentName = document.fileURL.pathComponents.last ?? ""
                self.textManager.showMessage("Opening document '\(documentName)'...")
                
                // Create
                //SSZipArchive.createZipFileAtPath(zipPath, withContentsOfDirectory: sampleDataPath)
                
                // Unzip
                //SSZipArchive.unzipFileAtPath(zipPath, toDestination: unzipPath)
                
                let fileManager = FileManager.default
                fileManager.delegate = self
                
                let documentsUrl: URL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first as URL!
                
                let zipFile = documentsUrl.appendingPathComponent("\(UUID().uuidString).zip")
                do {
                    try fileManager.removeItem(at: zipFile)
                } catch {
                    // Do nothing if it doesn't exist or fails
                }
                
                do {
                    try fileManager.copyItem(atPath: document.fileURL.path, toPath: zipFile.path)
                } catch let error {
                    print("Failed to rename '\(document.fileURL.path)' to '\(zipFile)' with error '\(error)'")
                }
                
                let unzippedFolderUrl: URL = documentsUrl.appendingPathComponent("model")

                do {
                    try fileManager.removeItem(at: unzippedFolderUrl)
                } catch {
                    // Do nothing if it doesn't exist or fails
                }

                do {
                    try fileManager.createDirectory(at: unzippedFolderUrl, withIntermediateDirectories: true, attributes: nil)
                } catch let error {
                    print("Failed to create directory '\(unzippedFolderUrl)' with error '\(error)'")
                }
                
                print("Unzipping file '\(zipFile)'")
                let unzipSuccessful = SSZipArchive.unzipFile(atPath: zipFile.path, toDestination: unzippedFolderUrl.path)
                if unzipSuccessful {
                    print("Unzipped to '\(unzippedFolderUrl.absoluteString)'")
                } else {
                    print("Failed to unzip the file '\(zipFile.path)'")
                }
                
                do {
                    try fileManager.removeItem(at: zipFile)
                } catch let error {
                    print("Failed to remove item at '\(zipFile)' with error '\(error)'")
                }

                self.loadModel(path: unzippedFolderUrl)
            } else {
                // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
                print("Failed to open '\(document.fileURL)'")
            }
        })
    }
    
    func closeDocument(document: UIDocument) {
        print("Closing '\(document.fileURL)'...")
        document.close(completionHandler: nil)

        let fileManager = FileManager.default
        fileManager.delegate = self

        let documentsUrl: URL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first as URL!
        let unzippedFolderUrl: URL = documentsUrl.appendingPathComponent("model")

        do {
            try fileManager.removeItem(atPath: unzippedFolderUrl.path)
            print("Removed temporary folder '\(unzippedFolderUrl.path)'")
        } catch let error {
            print("Error: \(error)")
        }
        
        documentOpened = false
    }
    
    func loadModel(path: URL) {
        
        guard let cameraTransform = self.session.currentFrame?.camera.transform else {
            print("Still trying to get camera position for the model '\(path)'")
            self.textManager.showMessage("Still trying to get camera position for the model '\(path)'")
            
            // Save the model path and load it when the camera position is available
            self.modelPath = path
            
            return
        }

        print("Loading model '\(path)'")
        self.textManager.showMessage("Loading model...", autoHide: false)

        // The generated normals mess up lighting in some models
        let loadingOptions = [SCNSceneSource.LoadingOption.createNormalsIfAbsent : false]
        
        // Set a name so that we can find this object later
        let containerNode = SCNNode()
        containerNode.name = "VirtualObject"

        // Go through the directory path and find all the obj models
        let fileManager = FileManager.default
        fileManager.delegate = self
        var numObjFiles : UInt = 0
        if let dirEnumerator = fileManager.enumerator(atPath: path.path) {
            while let element = dirEnumerator.nextObject() as? String {
                
                if element.hasSuffix(".obj") && !element.hasPrefix("__MACOSX") {
                    let objPath = path.appendingPathComponent(element)
                    
                    let src = SCNSceneSource(url: objPath, options: [.convertToYUp: false])
                    //if let sceneSource = src {
                    //    self.logSceneSource(sceneSource)
                    //}
                    
                    if let scene = src?.scene(options: loadingOptions) {
                        
                        // Set the node name as the OBJ file name, which should
                        // be the asset/feature type name from the FME AR writer
                        scene.rootNode.name = element
                        scene.rootNode.name?.removeLast(/*.obj*/ 4)
                        //self.logSceneNode(scene.rootNode, level: 0)
                        containerNode.addChildNode(scene.rootNode)
                        numObjFiles += 1
                    }
                }
            }
        }

        self.textManager.showMessage("\(numObjFiles) Assets Found")
        
        if (numObjFiles > 0) {

            // Normalize the model to be within a 0.5 meter cube.
            normalize(containerNode, scale: Float(0.5))
            
            let definition = VirtualObjectDefinition(modelName: "model", displayName: "model", particleScaleInfo: [:])
            let object = VirtualObject(definition: definition, childNodes: [containerNode])
            
            // Scale the virtual object
            let modelDimension = self.dimension(containerNode)
            let maxLength = max(modelDimension.x, modelDimension.y, modelDimension.z)
            if maxLength > 0 {
                
                // Scale the model to be within a 0.5 meter cube.
                let initialScale = Float(0.5) / maxLength
                object.scale = SCNVector3(initialScale, initialScale, initialScale)
            }
            
            logSceneNode(object, level: 0)
    
            let position = self.focusSquare?.lastPosition ?? float3(0, 0, -5)
            
            self.virtualObjectManager.loadVirtualObject(object, to: position, cameraTransform: cameraTransform)
            if object.parent == nil {
                self.serialQueue.async {
                    self.sceneView.scene.rootNode.addChildNode(object)
                    
                    for (_, lightNode) in self.spotLightNodes.enumerated() {
                        if (lightNode.light!.type == .spot) {
                            let constraint = SCNLookAtConstraint(target: object)
                            constraint.isGimbalLockEnabled = true
                            lightNode.constraints = [constraint]
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.showAssetsButton.isEnabled = true
            }
        }
        else {
            self.textManager.showAlert(title: "Invalid File", message: "No model in the file")
        }
        
        self.modelPath = nil;
    }
    
    
    func logSceneSource(_ sceneSource: SCNSceneSource) {
        if let assetContributor = sceneSource.property(forKey: SCNSceneSourceAssetContributorsKey) as? String {
            print("Scene Source: Asset Contributor: \(assetContributor)")
        }
        
        if let assetCreatedDate = sceneSource.property(forKey: SCNSceneSourceAssetCreatedDateKey) as? String {
            print("Scene Source: Asset Created Date: \(assetCreatedDate)")
        }
        
        if let assetModifiedDate = sceneSource.property(forKey: SCNSceneSourceAssetModifiedDateKey) as? String {
            print("Scene Source: Asset Modified Date: \(assetModifiedDate)")
        }
        
        if let assetUpAxis = sceneSource.property(forKey: SCNSceneSourceAssetUpAxisKey) as? String {
            print("Scene Source: Asset Up Axis: \(assetUpAxis)")
        }
        
        if let assetUnit = sceneSource.property(forKey: SCNSceneSourceAssetUnitKey) as? String {
            print("Scene Source: Asset Unit: \(assetUnit)")
        }
    }
    
    func logSceneNode(_ sceneNode: SCNNode, level: Int) {

        let currentLevel = max(0 as Int, level)
        let indentation = String(repeating: "    ", count: currentLevel)
        let childIndentation = String(repeating: "    ", count: currentLevel + 1)
        
        if let name = sceneNode.name {
            print("\(indentation)SCNNode name: \(name)")
        } else {
            print("\(indentation)SCNNode name: <none>")
        }
        
        let (minCoord, maxCoord) = sceneNode.boundingBox
        print("\(childIndentation)boundingBox = '\(minCoord)', '\(maxCoord)'")
        
        if let geometry = sceneNode.geometry {
            print("\(childIndentation)geometry: \(geometry)")
            logGeometry(geometry, level: currentLevel + 2)
        } else {
            print("\(childIndentation)geometry: <none>")
        }
        
        for childNode in sceneNode.childNodes {
            logSceneNode(childNode, level: currentLevel + 1)
        }
    }
    
    func logGeometry(_ geometry: SCNGeometry, level: Int) {
        let currentLevel = max(0 as Int, level)
        let indentation = String(repeating: "    ", count: currentLevel)
        
        if let name = geometry.name {
            print("\(indentation)SCNGeometry name: \(name)")
        } else {
            print("\(indentation)SCNGeometry name: <none>")
        }
        
        print("\(indentation)Geometry Elements: \(geometry.elements.count)")
        for (index, geometryElement) in geometry.elements.enumerated() {
            logGeometryElement(geometryElement, level: currentLevel + 1, prefix: "\(index)")
        }
        
        print("\(indentation)Materials: \(geometry.materials.count)")
        for (index, material) in geometry.materials.enumerated() {
            logMaterial(material, level: currentLevel + 1, prefix: "\(index)")
        }
    }
    
    func logGeometryElement(_ element: SCNGeometryElement, level: Int, prefix: String) {
        let currentLevel = max(0 as Int, level)
        let indentation = String(repeating: "    ", count: currentLevel)

        print("\(indentation)\(prefix): \(element)")
    }
    
    func logMaterial(_ material: SCNMaterial, level: Int, prefix: String) {
        let currentLevel = max(0 as Int, level)
        let indentation = String(repeating: "    ", count: currentLevel)
        let childIndentation = String(repeating: "    ", count: currentLevel + 1)
        
        if let materialName = material.name {
            print("\(indentation)\(prefix): name: \(materialName)")
        } else {
            print("\(indentation)\(prefix): name: <none>")
        }
        
        // HACK: For some reasons, the Tr value in the OBJ model is not read
        // correctly using SCNSceneSource or Model IO. If the OBJ material has
        // the d value.
        if let transparent = material.transparent.contents as? NSNumber {
            material.transparency = CGFloat(transparent.floatValue)
        }
        
        print("\(childIndentation)lightingModel: \(material.lightingModel)")
        print("\(childIndentation)shininess: \(material.shininess)")
        print("\(childIndentation)fresnelExponent: \(material.fresnelExponent)")
        print("\(childIndentation)isLitPerPixel: \(material.isLitPerPixel)")
        print("\(childIndentation)isDoubleSided: \(material.isDoubleSided)")
        print("\(childIndentation)cullMode: \(material.cullMode)")
        print("\(childIndentation)blendMode: \(material.blendMode)")
        print("\(childIndentation)locksAmbientWithDiffuse: \(material.locksAmbientWithDiffuse)")
        print("\(childIndentation)writesToDepthBuffer: \(material.writesToDepthBuffer)")
        print("\(childIndentation)readsFromDepthBuffer: \(material.readsFromDepthBuffer)")
        print("\(childIndentation)colorBufferWriteMask: \(material.colorBufferWriteMask)")
        print("\(childIndentation)fillMode: \(material.fillMode)")
        print("\(childIndentation)transparency: \(material.transparency)")
        logMaterialProperty(material.transparent, level: currentLevel + 1, prefix: "transparent")
        logMaterialProperty(material.diffuse, level: currentLevel + 1, prefix: "diffuse")
        logMaterialProperty(material.specular, level: currentLevel + 1, prefix: "specular")
        logMaterialProperty(material.ambient, level: currentLevel + 1, prefix: "ambient")
        logMaterialProperty(material.ambientOcclusion, level: currentLevel + 1, prefix: "ambientOcclusion")
        logMaterialProperty(material.selfIllumination, level: currentLevel + 1, prefix: "selfIllumination")
        logMaterialProperty(material.metalness, level: currentLevel + 1, prefix: "metalness")
        logMaterialProperty(material.roughness, level: currentLevel + 1, prefix: "roughness")
        logMaterialProperty(material.displacement, level: currentLevel + 1, prefix: "displacement")
        logMaterialProperty(material.normal, level: currentLevel + 1, prefix: "normal")
        logMaterialProperty(material.reflective, level: currentLevel + 1, prefix: "reflective")
        logMaterialProperty(material.emission, level: currentLevel + 1, prefix: "emission")
        
    }
    
    func logMaterialProperty(_ materialProperty: SCNMaterialProperty, level: Int, prefix: String) {
        let currentLevel = max(0 as Int, level)
        let indentation = String(repeating: "    ", count: currentLevel)
        
        print("\(indentation)\(prefix): \(materialProperty)")
        
    }
    
    // MARK: FileManagerDelegate
    
    func fileManager(_ fileManager: FileManager, shouldRemoveItemAt URL: URL) -> Bool {
        print("Should remove item at '\(URL)'")
        return true
    }
    
    func dimension(_ sceneNode: SCNNode) -> SCNVector3 {
        let (minCoord, maxCoord) = sceneNode.boundingBox
        return SCNVector3(maxCoord.x - minCoord.x, maxCoord.y - minCoord.y, maxCoord.z - minCoord.z)
    }

    func normalize(_ sceneNode: SCNNode, scale: Float) -> Void {
        // Rotate to Y up
        sceneNode.eulerAngles.x = -Float.pi / 2

        // Scale and offset the model so that the model stays on the ground
        let modelDimension = self.dimension(sceneNode)
        let maxLength = max(modelDimension.x, modelDimension.y, modelDimension.z)
        if maxLength > 0 {
            let (minCoord, maxCoord) = sceneNode.boundingBox
            sceneNode.position = SCNVector3(/*center x*/ -(minCoord.x + maxCoord.x) * 0.5,
                                            /*put the model on the plane*/ -minCoord.z,
                                            /*center z, which was y before the rotation*/ (minCoord.y + maxCoord.y) * 0.5)
        }
    }
}
