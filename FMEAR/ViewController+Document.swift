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
                
                let url: URL? = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first as URL?
                guard let documentsUrl = url else {
                    print("Failed to open '\(document.fileURL)'")
                    return
                }
                
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

        let url: URL? = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first as URL?
        guard let documentsUrl = url else {
            print("Document not found")
            documentOpened = false
            return
        }
        
        
        let unzippedFolderUrl: URL = documentsUrl.appendingPathComponent("model")

        do {
            try fileManager.removeItem(atPath: unzippedFolderUrl.path)
            print("Removed temporary folder '\(unzippedFolderUrl.path)'")
        } catch let error {
            print("Error: \(error)")
        }
        
        documentOpened = false
    }
    
    func loadSettings(file: URL) {
        do {
            let jsonData = try Data(contentsOf: file)
            let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: [])
            settings = try Settings(json: jsonDict)
            
        } catch {
            print("No settings")
            settings = nil
        }
    
        DispatchQueue.main.async {
            self.scaleMode = .customScale
            self.scaleLockEnabled = false
            if let scaling = self.settings?.scaling {
                if scaling == 1.0 {
                    self.scaleMode = .fullScale
                    self.scaleLockEnabled = true
                }
            }
                   
            // Update the scale options button
            self.setShowScaleOptionsButton(mode: self.scaleMode, lockOn: self.scaleLockEnabled)
        }
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

        let loadingOptions = [
            SCNSceneSource.LoadingOption.createNormalsIfAbsent : false,
            SCNSceneSource.LoadingOption.convertToYUp: false,
            SCNSceneSource.LoadingOption.flattenScene: true]
        
        // Set a name so that we can find this object later
        let containerNode = SCNNode()
        containerNode.name = "VirtualObjectContent"

        // Go through the directory path and find all the obj models
        let fileManager = FileManager.default
        fileManager.delegate = self
        var numObjFiles : UInt = 0
        if let dirEnumerator = fileManager.enumerator(atPath: path.path) {
            while let element = dirEnumerator.nextObject() as? String {
                
                print("element = \(element)")
                
                if !element.hasPrefix("__MACOSX") {
                    if element.hasSuffix(".obj") {
                        let objPath = path.appendingPathComponent(element)

                        let src = SCNSceneSource(url: objPath, options: loadingOptions)
                        //if let sceneSource = src {
                        //    self.logSceneSource(sceneSource)
                        //}
                        
                        let statusHandler = { (totalProgress: Float, status: SCNSceneSourceStatus, error: Error?, stopLoading: UnsafeMutablePointer<ObjCBool>) -> Void in
                            switch status {
                            case .error: print("error: \(totalProgress)")
                            case .parsing: print("parsing: \(totalProgress)")
                            case .validating: print("validating: \(totalProgress)")
                            case .processing: print("processing: \(totalProgress)")
                            case .complete: print("complete: \(totalProgress)")
                            default: print("default status: \(totalProgress)");
                            }
                        };
                        
                        if let scene = src?.scene(options: loadingOptions, statusHandler:  statusHandler) {
                            
                            adjustMaterialProperties(sceneNode: scene.rootNode)
                            
                            // Set the node name as the OBJ file name, which should
                            // be the asset/feature type name from the FME AR writer
                            scene.rootNode.name = element
                            scene.rootNode.name?.removeLast(/*.obj*/ 4)
                            //self.logSceneNode(scene.rootNode, level: 0)
                            containerNode.addChildNode(scene.rootNode)
                            numObjFiles += 1
                        }
                    } else if element.hasSuffix("settings.json") {
                        loadSettings(file: path.appendingPathComponent(element))
                    } else if element.hasSuffix(".json") {
                        // Version 1 and 2 of the settings json file has a "model" name
                        // that should match the folder name inside the .fmear archive
                        let jsonPath = path.appendingPathComponent(element)
                        let jsonFilename = jsonPath.deletingPathExtension().lastPathComponent
                        let folderName = jsonPath.deletingLastPathComponent().lastPathComponent
                        if jsonFilename == folderName {
                            loadSettings(file: jsonPath)
                        }
                    }
                }
            }
        }

        self.textManager.showMessage("\(numObjFiles) Assets Found")
        
        if (numObjFiles > 0) {
            let (minCoord, maxCoord) = containerNode.boundingBox
            
            // By default, set the anchor to the center of the model, with the
            // 0.0 height as the ground
            let centerX = (minCoord.x + maxCoord.x) * 0.5
            let centerY = (minCoord.y + maxCoord.y) * 0.5
            let groundZ = 0.0
            var anchor: SCNVector3 = SCNVector3(centerX, Float(groundZ), centerY)
            
            if let anchors = settings?.anchors {
                if let firstAnchor = anchors.first {
                    anchor = SCNVector3(firstAnchor.x ?? Double(centerX),
                                        firstAnchor.z ?? groundZ,
                                        firstAnchor.y ?? Double(centerY))
                }
            }
            
            // TEST - The bottom-left corner of the Arc de Triomphe, using the
            // roof as the ground (i.e. the building will be displayed underground)
            //anchor = SCNVector3(-2132.81, 2068, -1855.440373)

            // Position the container node, including the model and the anchor
            // node, to the anchor location. The z value was the
            containerNode.position = SCNVector3(-anchor.x, -anchor.y, anchor.z)
            
            // Rotate to Y up
            containerNode.eulerAngles.x = -Float.pi / 2
                        
            let modelDimension = self.dimension(containerNode)
            let maxLength = max(modelDimension.x, modelDimension.y, modelDimension.z)

            // Add the anchor geometry and node
            let anchorHeight: CGFloat = CGFloat(modelDimension.z * 2)
            let anchorRadius: CGFloat = anchorHeight * 0.01
            let anchorMaterial = SCNMaterial()
            anchorMaterial.diffuse.contents = UIColor.red
            let anchorGeometry = SCNCone(topRadius: anchorRadius, bottomRadius: 0, height: anchorHeight)
            anchorGeometry.firstMaterial = anchorMaterial
            let anchorNode = SCNNode(geometry: anchorGeometry)
            anchorNode.name = "Anchor Node"
            // Need to shift the SCNCone up since it's origin is the middle of the
            // cone.
            anchorNode.simdPosition =  float3(0, Float(anchorHeight * 0.5), 0)
            // Initial visibility of the anchor node
            anchorNode.isHidden = !(UserDefaults.standard.bool(for: .drawAnchor))
            containerNode.addChildNode(anchorNode)


            let definition = VirtualObjectDefinition(modelName: "model", displayName: "model", particleScaleInfo: [:])
            let object = VirtualObject(definition: definition, childNodes: [containerNode, anchorNode])
            object.name = "VirtualObject"
            
            // Set a cteagory bit mask to include the virtual object in the hit test.
            object.categoryBitMask = HitTestOptionCategoryBitMasks.virtualObject.rawValue

            // Scale the virtual object
            if maxLength > 0 {
                // By default, scale the model to be within a 0.5 meter cube.
                // If the scaling is set in the model json file, use it instead.
                let preferredScale = (self.scaleMode == .fullScale) ? 1.0 : (Float(0.5) / maxLength)
                object.scale = SCNVector3(preferredScale, preferredScale, preferredScale)

                // Set scale lock
                self.virtualObjectManager.allowScaling = !self.scaleLockEnabled
            }
            
            //logSceneNode(object, level: 0)
            
            let position = (self.focusSquare?.lastPosition ?? float3(0, 0, -5))
            
//            // We need to negate the anchor.z (which was the y in FME) since
//            // the y in FME is reverse compared to ARKit
//            anchorNode.simdPosition = position + float3(anchor.x, anchor.y, -anchor.z)
            
            self.virtualObjectManager.loadVirtualObject(object, to: position, cameraTransform: cameraTransform)
            if object.parent == nil {
                self.serialQueue.async {
                    self.sceneView.scene.rootNode.addChildNode(object)
                }
            }
            
            DispatchQueue.main.async {
                self.showAssetsButton.isEnabled = true
                self.showScaleOptionsButton.isHidden = false
                self.scaleLabel.isHidden = false
                self.scaleLabel.text = self.dimensionAndScaleText(scale: object.scale.x, node: object)
            }
        }
        else {
            self.textManager.showAlert(title: "Invalid File", message: "No model in the file")
        }
        
        self.modelPath = nil;
    }
    
    func adjustMaterialProperties(sceneNode: SCNNode) {
        
        if let geometry = sceneNode.geometry {
            for material in geometry.materials {

                // FMEMOBILE-384
                // SCNSceneSource seems to mistakenly load the OBJ Ka (ambient)
                // material property as emission property. Since we dont' care
                // emission for now, we will just copy the emission value to the
                // original ambient value, and reset the emission property
                // to zero.
                material.ambient.contents = material.emission.contents
                material.emission.contents = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
                
                // Set doubleSided so that the user can always see the model
                material.isDoubleSided = true
                
                // For some reasons, the Tr value in the OBJ model is not read
                // correctly using SCNSceneSource or Model IO. If the OBJ material has
                // the d value.
                if let transparent = material.transparent.contents as? NSNumber {
                    material.transparency = CGFloat(transparent.floatValue)
                }
            }

        }
        
        for childNode in sceneNode.childNodes {
            adjustMaterialProperties(sceneNode: childNode)
        }
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

//    func normalize(_ sceneNode: SCNNode) -> Void {
//        // Rotate to Y up
//        sceneNode.eulerAngles.x = -Float.pi / 2
//        
//        // Scale and offset the model so that the model stays on the ground
//        let modelDimension = self.dimension(sceneNode)
//        let maxLength = max(modelDimension.x, modelDimension.y, modelDimension.z)
//        if maxLength > 0 {
//            let (minCoord, maxCoord) = sceneNode.boundingBox
//            sceneNode.position = SCNVector3(/*center x*/ -(minCoord.x + maxCoord.x) * 0.5,
//                                            /*honor the original z position to allow negative features*/ 0.0,
//                                            /*center z, which was y before the rotation*/ (minCoord.y + maxCoord.y) * 0.5)
//        }
//    }
}
