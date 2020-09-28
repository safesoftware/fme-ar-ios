//
//  FMEARReader.swift
//  FMEAR
//
//  Created by Angus Lau on 2020-08-29.
//  Copyright © 2020 Safe Software Inc. All rights reserved.
//

import Foundation
import SceneKit

protocol FMEReaderDelegate: class {
    func reader(_ reader: FMEReader, datasetRead: Dataset)
    func reader(_ reader: FMEReader, didFailWithError error: Error)
}

class FMEReader: NSObject {
    
}

class FMEARReader: FMEReader, FileManagerDelegate {

    weak var delegate: FMEReaderDelegate?
    let fileManager = FileManager()
    
    override init() {
        super.init()
        fileManager.delegate = self
    }
    
    func read(url: URL) {
        print("reading '\(url)'...")
        
        // We want to extract the data from the document url and create a scene node.
        let document = Document(fileURL: url)
        document.open() { success in
            if success {
                // Record the dataset
                let dataset = Dataset()
                dataset.documentURL = url
                
                let documentName = document.fileURL.pathComponents.last ?? ""
                //self.textManager.showMessage("Opening \(documentName)...")
                
                // Get the document directory path
                guard let documentDirectory = self.fileManager.urls(for: .documentDirectory, in: .userDomainMask).first as URL? else {
                    self.delegate?.reader(self, didFailWithError: FMEError.failedToOpenDataset(url))
                    return
                }
                
                // Create the destination folder for the unzipped content
                let unzippedFolderUrl = documentDirectory.appendingPathComponent(UUID().uuidString)
                do {
                    try self.fileManager.createDirectory(at: unzippedFolderUrl,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
                } catch {
                    self.delegate?.reader(self, didFailWithError: FMEError.failedToOpenDataset(url))
                    return
                }
                
                // Unzip the .fmear file
                if SSZipArchive.unzipFile(atPath: url.path, toDestination: unzippedFolderUrl.path) {
                    // Load the model into the scene
                    dataset.settings = self.readSettings(folderUrl: unzippedFolderUrl)
                    (dataset.model, dataset.snapshot) = self.readModel(
                        folderUrl: unzippedFolderUrl,
                        settings: dataset.settings) ?? (nil, nil)
                                            
//                    if let model = dataset.model {
//                        model.log()
//                    }
                } else {
                    self.delegate?.reader(self, didFailWithError: FMEError.failedToOpenDataset(url))
                }
                
                // Remove the unzipped folder
                do {
                    try self.fileManager.removeItem(at: unzippedFolderUrl)
                } catch let error {
                    print("Failed to remove the unzipped content in \(unzippedFolderUrl.path): \(error)")
                }

                // Close the document since we don't need it anymore
                document.close() { success in
                    if success {
                        print("\(documentName) closed")
                    } else {
                        print("Failed to close \(documentName)")
                    }
                }
                
                self.delegate?.reader(self, datasetRead: dataset)
                
            } else {
                self.delegate?.reader(self, didFailWithError: FMEError.failedToOpenDataset(url))
            }
        }
    }
    
    func readSettings(folderUrl: URL) -> Settings? {
        guard let enumerator = fileManager.enumerator(atPath: folderUrl.path) else {
            return nil
        }
        
        // Find the settings.json file
        while let objectPath = enumerator.nextObject() as? String {
            if objectPath.hasPrefix("__MACOSX") {
                // Ignore this __MACOSX folder
                continue
            }
            
            if objectPath.hasSuffix("settings.json") {
                return readSettingsFile(file: folderUrl.appendingPathComponent(objectPath))
            } else if objectPath.hasSuffix(".json") {
                // Version 1 and 2 of the settings json file has a "model" name
                // that should match the folder name inside the .fmear archive
                let jsonPath = folderUrl.appendingPathComponent(objectPath)
                let jsonFilename = jsonPath.deletingPathExtension().lastPathComponent
                let folderName = jsonPath.deletingLastPathComponent().lastPathComponent
                if jsonFilename == folderName {
                    return readSettingsFile(file: jsonPath)
                }
            }
        }
        
        return nil
    }
    
    func readModel(folderUrl: URL, settings: Settings?) -> (SCNNode?, UIImage?)? {
        guard let enumerator = fileManager.enumerator(atPath: folderUrl.path) else {
            return nil
        }
        
        // Find the settings.json file
        var assets: [SCNNode] = []
        while let objectPath = enumerator.nextObject() as? String {
            if objectPath.hasPrefix("__MACOSX") {
                // Ignore this __MACOSX folder
                continue
            }
            
            let objSuffix = ".obj"
            if objectPath.hasSuffix(objSuffix) {
                if let objNode = readObjFile(file: folderUrl.appendingPathComponent(objectPath)) {
                    // Set the node name as the OBJ file name, which should
                    // be the asset/feature type name from the FME AR writer
                    var assetName = objectPath
                    assetName.removeLast(objSuffix.count)
                    print("Reading asset \(assetName)")
                    objNode.name = assetName
                    assets.append(objNode)
                }
            }
        }
        
        print("\(assets.count) asset(s) found")
        
        if (assets.count > 0) {
            
            let model = SCNNode()
            for asset in assets {
                model.addChildNode(asset)
            }
            
            let snapshot = model.snapshot(size: CGSize(width: 512.0, height: 512.0))
            
            // Dimension and position
            let (minCoord, maxCoord) = model.boundingBox
            let centerX = (minCoord.x + maxCoord.x) * 0.5
            let centerY = (minCoord.y + maxCoord.y) * 0.5
            let groundZ = 0.0
            
            // json.settings version 4 - Viewpoints
            // ----------
            var viewpoints = settings?.viewpoints ?? []
            if viewpoints.isEmpty {
                var defaultViewpoint = Viewpoint()
                defaultViewpoint.name = "Default Viewpoint"
                defaultViewpoint.x = Double(centerX)
                defaultViewpoint.y = Double(centerY)
                defaultViewpoint.z = groundZ
                
                viewpoints.append(defaultViewpoint)
            }
            
            // we should always show viewpoints at the beginning
            UserDefaults.standard.set(true, for: .drawAnchor)
            
            // Rotate to Y up
            model.eulerAngles.x = -Float.pi / 2
            
            // TODO: Change the name to something more meaningful
            model.name = "VirtualObjectContent"
            
            let modelDimension = model.dimension()
            let maxLength = max(modelDimension.x, modelDimension.y, modelDimension.z)
            let definition = VirtualObjectDefinition(modelName: "model", displayName: "model", particleScaleInfo: [:])
            let object = VirtualObject(definition: definition,
                                     modelNode: model,
                                     viewpoints: viewpoints)
            
            // TODO: Change the name to something more meaningful
            object.name = "VirtualObject"

            if let firstViewpoint = object.viewpoints.first {
                object.anchorAtViewpoint(viewpointId: firstViewpoint.id)
            }
            
            // Set a cteagory bit mask to include the virtual object in the hit test.
            object.categoryBitMask = HitTestOptionCategoryBitMasks.virtualObject.rawValue
            
            // Scale the virtual object
            if maxLength > 0 {
                // By default, scale the model to be within a 0.5 meter cube.
                // If the scaling is set in the model json file, use it instead.
                if let scaling = settings?.scaling {
                    object.scale = SCNVector3(scaling, scaling, scaling)
                } else {
                    let preferredScale = (Float(0.5) / maxLength)
                    object.scale = SCNVector3(preferredScale, preferredScale, preferredScale)
                }
            }
            
            return (object, snapshot)
        } else {
            return nil
        }
    }
    
    func readObjFile(file: URL) -> SCNNode? {
        let loadingOptions = [
            SCNSceneSource.LoadingOption.createNormalsIfAbsent : false,
            SCNSceneSource.LoadingOption.convertToYUp: false,
            SCNSceneSource.LoadingOption.flattenScene: true]
        
        if let sceneSource = SCNSceneSource(url: file, options: loadingOptions) {
            sceneSource.log()
            
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
            
            if let scene = sceneSource.scene(options: loadingOptions, statusHandler:  statusHandler) {
                
                // TODO: SceneKit gives an error (Removing the root node
                // of a scene from its scene is not allowed), but cloning
                // doesn't work. The clone seems to lose the material colours
                let rootNode = scene.rootNode
                adjustMaterialProperties(sceneNode: rootNode)
                return rootNode
            }
        }
        
        return nil
    }
        
    func readSettingsFile(file: URL) -> Settings? {
        
        var settings: Settings?
        
        do {
            let jsonData = try Data(contentsOf: file)
            let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: [])
            settings = try Settings(json: jsonDict)
        } catch {
            print("No settings")
            settings = nil
        }

        return settings
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
        
    // MARK: FileManagerDelegate
    func fileManager(_ fileManager: FileManager, shouldRemoveItemAt URL: URL) -> Bool {
        // For some unknown reasons, the follow commented code caused some textures not
        // being able to be removed from the previous model and incorrectly apply the
        // textures to the next model. We reverted back to always return true, but this
        // causes an error if the user opens a file without anchoring the model on a
        // plane before closing the file.
        //if fileManager.fileExists(atPath: URL.absoluteString) {
        //    return true
        //} else {
        //    return false
        //}
        return true
    }
}
