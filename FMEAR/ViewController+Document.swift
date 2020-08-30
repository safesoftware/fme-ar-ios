/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Methods on the main view controller for handling virtual object loading and movement
*/

import UIKit
import SceneKit
import Foundation
import CoreLocation
import SceneKit.ModelIO

extension ViewController: FileManagerDelegate {

//    func openDataset2(url: URL) {
//        print("openDataset2")
//
//        if datasets[url] == nil {
//            // We want to extract the data from the document url and create a scene node.
//            let document = Document(fileURL: url)
//            document.open() { success in
//                if success {
//                    // Record the dataset
//                    let dataset = Dataset()
//                    dataset.documentURL = url
//                    self.datasets[url] = dataset
//
//                    let documentName = document.fileURL.pathComponents.last ?? ""
//                    //self.textManager.showMessage("Opening \(documentName)...")
//
//                    // Create a file manager to handle create and remove folders
//                    let fileManager = FileManager.default
//                    fileManager.delegate = self
//
//                    // Get the document directory path
//                    guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first as URL? else {
//                        self.errors.append(FMEError.failedToOpenDataset(url))
//                        return
//                    }
//
//                    // Create the destination folder for the unzipped content
//                    let unzippedFolderUrl = documentDirectory.appendingPathComponent(UUID().uuidString)
//                    do {
//                        try fileManager.createDirectory(at: unzippedFolderUrl,
//                                                        withIntermediateDirectories: true,
//                                                        attributes: nil)
//                    } catch {
//                        self.errors.append(FMEError.failedToOpenDataset(url))
//                        return
//                    }
//
//                    // Unzip the .fmear file
//                    if let unzipError = self.unzipFile(fileUrl: url, destinationFolderUrl: unzippedFolderUrl) {
//                        self.errors.append(unzipError)
//                    } else {
//                        // Load the model into the scene
//                        dataset.settings = self.readSettings(folderUrl: unzippedFolderUrl)
//                        dataset.model = self.readModel(folderUrl: unzippedFolderUrl,
//                                                       settings: dataset.settings)
//
////                        if let model = dataset.model {
////                            self.logSceneNode(model, level: 0)
////                        }
//
//                        // If there is a model, we will add it to the scene in the next
//                        // frame update.
//                        if dataset.model != nil {
//                            self.datasetsReady.append(url)
//                        }
//                    }
//
//                    // Remove the unzipped folder
//                    do {
//                        try fileManager.removeItem(at: unzippedFolderUrl)
//                    } catch let error {
//                        print("Failed to remove the unzipped content in \(unzippedFolderUrl.path): \(error)")
//                    }
//
//                    // Close the document since we don't need it anymore
//                    document.close() { success in
//                        if success {
//                            print("\(documentName) closed")
//                        } else {
//                            print("Failed to close \(documentName)")
//                        }
//                    }
//
//                    // Update the compass.
//                    // TODO: Currently we replace the compass image. If in the future
//                    // we want to handle more than one models, we will need to update
//                    // the image that includes all models.
//
//
//                } else {
//                    self.errors.append(FMEError.failedToOpenDataset(url))
//                }
//            }
//
//        } else {
//            // TODO: We have opened this dataset. We will reuse the model.
//
//            // We do nothing now
//        }
//    }
//
//    func unzipFile(fileUrl: URL, destinationFolderUrl: URL) -> Error? {
//        if SSZipArchive.unzipFile(atPath: fileUrl.path, toDestination: destinationFolderUrl.path) {
//            return nil
//        } else {
//            return FMEError.failedToOpenDataset(fileUrl)
//        }
//    }
//
//    func closeDataset(url: URL) {
//        datasets.removeValue(forKey: url)
//    }
//
//    func reloadAllDatasets() {
//        let keys = datasets.keys
//        datasets.removeAll()
//        for key in keys {
//            openDataset(url: key)
//        }
//    }
    
//    func openDocument(document: UIDocument) {
//        // Access the document
//        document.open(completionHandler: { (success) in
//            if success {
////                self.documentOpened = true
//
//                // Display the content of the document, e.g.:
//                //self.documentNameLabel.text = self.document?.fileURL.lastPathComponent
//                print("Opening document '\(document.fileURL)'...")
//                let documentName = document.fileURL.pathComponents.last ?? ""
//                self.textManager.showMessage("Opening document '\(documentName)'...")
//
//                // Create
//                //SSZipArchive.createZipFileAtPath(zipPath, withContentsOfDirectory: sampleDataPath)
//
//                // Unzip
//                //SSZipArchive.unzipFileAtPath(zipPath, toDestination: unzipPath)
//
//                let fileManager = FileManager.default
//                fileManager.delegate = self
//
//                let url: URL? = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first as URL?
//                guard let documentsUrl = url else {
//                    print("Failed to open '\(document.fileURL)'")
//                    return
//                }
//
//                let zipFile = documentsUrl.appendingPathComponent("\(UUID().uuidString).zip")
//                do {
//                    try fileManager.removeItem(at: zipFile)
//                } catch {
//                    // Do nothing if it doesn't exist or fails
//                }
//
//                do {
//                    try fileManager.copyItem(atPath: document.fileURL.path, toPath: zipFile.path)
//                } catch let error {
//                    print("Failed to rename '\(document.fileURL.path)' to '\(zipFile)' with error '\(error)'")
//                }
//
//                let unzippedFolderUrl: URL = documentsUrl.appendingPathComponent("model")
//
//                do {
//                    try fileManager.removeItem(at: unzippedFolderUrl)
//                } catch {
//                    // Do nothing if it doesn't exist or fails
//                }
//
//                do {
//                    try fileManager.createDirectory(at: unzippedFolderUrl, withIntermediateDirectories: true, attributes: nil)
//                } catch let error {
//                    print("Failed to create directory '\(unzippedFolderUrl)' with error '\(error)'")
//                }
//
//                print("Unzipping file '\(zipFile)'")
//                let unzipSuccessful = SSZipArchive.unzipFile(atPath: document.fileURL.path /*zipFile.path*/, toDestination: unzippedFolderUrl.path)
//                if unzipSuccessful {
//                    print("Unzipped to '\(unzippedFolderUrl.absoluteString)'")
//                } else {
//                    print("Failed to unzip the file '\(zipFile.path)'")
//                }
//
//                do {
//                    try fileManager.removeItem(at: zipFile)
//                } catch let error {
//                    print("Failed to remove item at '\(zipFile)' with error '\(error)'")
//                }
//
//                self.loadModel(path: unzippedFolderUrl)
//            } else {
//                // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
//                print("Failed to open '\(document.fileURL)'")
//            }
//        })
//    }
    
//    func readSettings(folderUrl: URL) -> Settings? {
//        let fileManager = FileManager.default
//        fileManager.delegate = self
//        guard let enumerator = fileManager.enumerator(atPath: folderUrl.path) else {
//            return nil
//        }
//
//        // Find the settings.json file
//        while let objectPath = enumerator.nextObject() as? String {
//            if objectPath.hasPrefix("__MACOSX") {
//                // Ignore this __MACOSX folder
//                continue
//            }
//
//            if objectPath.hasSuffix("settings.json") {
//                return readSettingsFile(file: folderUrl.appendingPathComponent(objectPath))
//            } else if objectPath.hasSuffix(".json") {
//                // Version 1 and 2 of the settings json file has a "model" name
//                // that should match the folder name inside the .fmear archive
//                let jsonPath = folderUrl.appendingPathComponent(objectPath)
//                let jsonFilename = jsonPath.deletingPathExtension().lastPathComponent
//                let folderName = jsonPath.deletingLastPathComponent().lastPathComponent
//                if jsonFilename == folderName {
//                    return readSettingsFile(file: jsonPath)
//                }
//            }
//        }
//
//        return nil
//    }
    
//    func readModel(folderUrl: URL, settings: Settings?) -> SCNNode? {
//        let fileManager = FileManager.default
//        fileManager.delegate = self
//        guard let enumerator = fileManager.enumerator(atPath: folderUrl.path) else {
//            return nil
//        }
//
//        // Find the settings.json file
//        var assets: [SCNNode] = []
//        while let objectPath = enumerator.nextObject() as? String {
//            if objectPath.hasPrefix("__MACOSX") {
//                // Ignore this __MACOSX folder
//                continue
//            }
//
//            let objSuffix = ".obj"
//            if objectPath.hasSuffix(objSuffix) {
//                if let objNode = readObjFile(file: folderUrl.appendingPathComponent(objectPath)) {
//                    // Set the node name as the OBJ file name, which should
//                    // be the asset/feature type name from the FME AR writer
//                    var assetName = objectPath
//                    assetName.removeLast(objSuffix.count)
//                    print("Reading asset \(assetName)")
//                    objNode.name = assetName
//                    assets.append(objNode)
//                }
//            }
//        }
//
//        print("\(assets.count) asset(s) found")
//
//        if (assets.count > 0) {
//
//            let model = SCNNode()
//            for asset in assets {
//                model.addChildNode(asset)
//            }
//
//            // Dimension and position
//            let (minCoord, maxCoord) = model.boundingBox
//            let centerX = (minCoord.x + maxCoord.x) * 0.5
//            let centerY = (minCoord.y + maxCoord.y) * 0.5
//            let groundZ = 0.0
//
//            // json.settings version 4 - Viewpoints
//            // ----------
//            let viewpoints = settings?.viewpoints ?? []
//
//            // json.settings version 3 - Anchor
//            // ------
//            // By default, set the anchor to the center of the model, with the
//            // 0.0 height as the ground
//            var anchor: SCNVector3 = SCNVector3(centerX, Float(groundZ), centerY) // default
//            if let anchors = settings?.anchors {
//                if let firstAnchor = anchors.first {
//                    anchor = SCNVector3(firstAnchor.x ?? Double(centerX),
//                                       firstAnchor.z ?? groundZ,
//                                       firstAnchor.y ?? Double(centerY))
//                }
//            }
//
//            // json.settings version 3
//            if viewpoints.isEmpty {
//                // Position the container node, including the model and the anchor
//                // node, to the anchor location.
//                // The FME coordinate z axis = ARKit y axis
//                // The FME coordinate y axis = ARKit z axis
//                model.position = SCNVector3(-anchor.x, -anchor.y, anchor.z)
//            } else {
//                // If we have a viewpont, we should always show it at the beginning
//                UserDefaults.standard.set(true, for: .drawAnchor)
//            }
//
//            // Rotate to Y up
//            model.eulerAngles.x = -Float.pi / 2
//
//            // TODO: Change the name to something more meaningful
//            model.name = "VirtualObjectContent"
//
//            let modelDimension = self.dimension(model)
//            let maxLength = max(modelDimension.x, modelDimension.y, modelDimension.z)
//            let definition = VirtualObjectDefinition(modelName: "model", displayName: "model", particleScaleInfo: [:])
//            let object = VirtualObject(definition: definition,
//                                     modelNode: model,
//                                     viewpoints: viewpoints)
//
//            // TODO: Change the name to something more meaningful
//            object.name = "VirtualObject"
//
//            if let firstViewpoint = object.viewpoints.first {
//                object.anchorAtViewpoint(viewpointId: firstViewpoint.id)
//            }
//
//            // Set a cteagory bit mask to include the virtual object in the hit test.
//            object.categoryBitMask = HitTestOptionCategoryBitMasks.virtualObject.rawValue
//
//            // Scale the virtual object
//            if maxLength > 0 {
//                // By default, scale the model to be within a 0.5 meter cube.
//                // If the scaling is set in the model json file, use it instead.
//                if self.scaleMode == .fullScale {
//                    object.scale = SCNVector3(1.0, 1.0, 1.0)
//                } else if let userSpecifiedScale = self.scaling {
//                    object.scale = SCNVector3(userSpecifiedScale, userSpecifiedScale, userSpecifiedScale)
//                } else {
//                    let preferredScale = (Float(0.5) / maxLength)
//                    object.scale = SCNVector3(preferredScale, preferredScale, preferredScale)
//                }
//
//                // Set scale lock
//                DispatchQueue.main.async {
//                    self.virtualObjectManager.allowScaling = !self.scaleLockEnabled
//                }
//            }
//
//            return object
//        } else {
//            return nil
//        }
//    }
//
//    func readObjFile(file: URL) -> SCNNode? {
//        let loadingOptions = [
//            SCNSceneSource.LoadingOption.createNormalsIfAbsent : false,
//            SCNSceneSource.LoadingOption.convertToYUp: false,
//            SCNSceneSource.LoadingOption.flattenScene: true]
//
//        if let sceneSource = SCNSceneSource(url: file, options: loadingOptions) {
//            //self.logSceneSource(sceneSource)
//
//            let statusHandler = { (totalProgress: Float, status: SCNSceneSourceStatus, error: Error?, stopLoading: UnsafeMutablePointer<ObjCBool>) -> Void in
//                switch status {
//                case .error: print("error: \(totalProgress)")
//                case .parsing: print("parsing: \(totalProgress)")
//                case .validating: print("validating: \(totalProgress)")
//                case .processing: print("processing: \(totalProgress)")
//                case .complete: print("complete: \(totalProgress)")
//                default: print("default status: \(totalProgress)");
//                }
//            };
//
//            if let scene = sceneSource.scene(options: loadingOptions, statusHandler:  statusHandler) {
//
//                // TODO: SceneKit gives an error (Removing the root node
//                // of a scene from its scene is not allowed), but cloning
//                // doesn't work. The clone seems to lose the material colours
//                let rootNode = scene.rootNode
//                adjustMaterialProperties(sceneNode: rootNode)
//                return rootNode
//            }
//        }
//
//        return nil
//    }
    
//    func closeDocument(document: UIDocument) {
//        print("Closing '\(document.fileURL)'...")
//        document.close(completionHandler: nil)
//
//        let fileManager = FileManager.default
//        fileManager.delegate = self
//
//        let url: URL? = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first as URL?
//        guard let documentsUrl = url else {
//            print("Document not found")
////            documentOpened = false
//            return
//        }
//
//
//        let unzippedFolderUrl: URL = documentsUrl.appendingPathComponent("model")
//
//        do {
//            try fileManager.removeItem(atPath: unzippedFolderUrl.path)
//            print("Removed temporary folder '\(unzippedFolderUrl.path)'")
//        } catch let error {
//            print("Error: \(error)")
//        }
//
////        documentOpened = false
//    }
    
//    func readSettingsFile(file: URL) -> Settings? {
//
//        var settings: Settings?
//
//        do {
//            let jsonData = try Data(contentsOf: file)
//            let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: [])
//            settings = try Settings(json: jsonDict)
//        } catch {
//            print("No settings")
//            settings = nil
//        }
//
//        // TODO: Move the following state-changing code to somewhere else
//        self.scaleMode = .customScale
//        self.scaleLockEnabled = false
//        if let scaling = settings?.scaling {
//            if scaling == 1.0 {
//                self.scaleMode = .fullScale
//            } else {
//                self.scaleMode = .customScale
//            }
//
//            self.scaleLockEnabled = true
//            self.scaling = scaling
//        }
//
//        DispatchQueue.main.async {
//            // Update the scale options button
//            self.setShowScaleOptionsButton(mode: self.scaleMode, lockOn: self.scaleLockEnabled)
//        }
//
//        return settings
//    }
    
//    func loadModel(path: URL) {
//
//        guard let cameraTransform = self.session.currentFrame?.camera.transform else {
//            print("Still trying to get camera position for the model '\(path)'")
//            self.textManager.showMessage("Still trying to get camera position for the model '\(path)'")
//
//            // Save the model path and load it when the camera position is available
//            //self.modelPath = path
//
//            return
//        }
//
//        print("Loading model '\(path)'")
//        self.textManager.showMessage("Loading model...", autoHide: false)
//
//        let loadingOptions = [
//            SCNSceneSource.LoadingOption.createNormalsIfAbsent : false,
//            SCNSceneSource.LoadingOption.convertToYUp: false,
//            SCNSceneSource.LoadingOption.flattenScene: true]
//
//        // Set a name so that we can find this object later
//        let modelNode = SCNNode()
//        modelNode.name = "VirtualObjectContent"
//
//        // Go through the directory path and find all the obj models
//        let fileManager = FileManager.default
//        fileManager.delegate = self
//        var numObjFiles : UInt = 0
//        if let dirEnumerator = fileManager.enumerator(atPath: path.path) {
//            while let element = dirEnumerator.nextObject() as? String {
//
//                print("element = \(element)")
//
//                if !element.hasPrefix("__MACOSX") {
//                    if element.hasSuffix(".obj") {
//                        let objPath = path.appendingPathComponent(element)
//
//                        let src = SCNSceneSource(url: objPath, options: loadingOptions)
//                        //if let sceneSource = src {
//                        //    self.logSceneSource(sceneSource)
//                        //}
//
//                        let statusHandler = { (totalProgress: Float, status: SCNSceneSourceStatus, error: Error?, stopLoading: UnsafeMutablePointer<ObjCBool>) -> Void in
//                            switch status {
//                            case .error: print("error: \(totalProgress)")
//                            case .parsing: print("parsing: \(totalProgress)")
//                            case .validating: print("validating: \(totalProgress)")
//                            case .processing: print("processing: \(totalProgress)")
//                            case .complete: print("complete: \(totalProgress)")
//                            default: print("default status: \(totalProgress)");
//                            }
//                        };
//
//                        if let scene = src?.scene(options: loadingOptions, statusHandler:  statusHandler) {
//
//                            // TODO: SceneKit gives an error (Removing the root node
//                            // of a scene from its scene is not allowed), but cloning
//                            // doesn't work. The clone seems to lose the material colours
//                            let rootNode = scene.rootNode
//                            adjustMaterialProperties(sceneNode: rootNode)
//
//                            // Set the node name as the OBJ file name, which should
//                            // be the asset/feature type name from the FME AR writer
//                            rootNode.name = element
//                            rootNode.name?.removeLast(/*.obj*/ 4)
//                            //self.logSceneNode(containerNode, level: 0)
//                            modelNode.addChildNode(rootNode)
//                            numObjFiles += 1
//                        }
//                    } else if element.hasSuffix("settings.json") {
//                        self.settings = readSettingsFile(file: path.appendingPathComponent(element))
//                    } else if element.hasSuffix(".json") {
//                        // Version 1 and 2 of the settings json file has a "model" name
//                        // that should match the folder name inside the .fmear archive
//                        let jsonPath = path.appendingPathComponent(element)
//                        let jsonFilename = jsonPath.deletingPathExtension().lastPathComponent
//                        let folderName = jsonPath.deletingLastPathComponent().lastPathComponent
//                        if jsonFilename == folderName {
//                            self.settings = readSettingsFile(file: jsonPath)
//                        }
//                    }
//                }
//            }
//        }
//
//        self.textManager.showMessage("\(numObjFiles) Assets Found")
//
//        if (numObjFiles > 0) {
//
//            self.overlayView.compass().image
//                = modelNode.snapshot(size: CGSize(width: 512.0, height: 512.0))
//
//            let (minCoord, maxCoord) = modelNode.boundingBox
//            let centerX = (minCoord.x + maxCoord.x) * 0.5
//            let centerY = (minCoord.y + maxCoord.y) * 0.5
//            let groundZ = 0.0
//
//            // json.settings version 4 - Viewpoints
//            // ----------
//            let viewpoints = settings?.viewpoints ?? []
//
//            // json.settings version 3 - Anchor
//            // ------
//            // By default, set the anchor to the center of the model, with the
//            // 0.0 height as the ground
//            var anchor: SCNVector3 = SCNVector3(centerX, Float(groundZ), centerY) // default
//            var geolocation: CLLocation?
//            var isDefaultAnchor = true
//            if let anchors = settings?.anchors {
//                if let firstAnchor = anchors.first {
//
//                    if firstAnchor.x != nil && firstAnchor.y != nil {
//                        isDefaultAnchor = false
//                    }
//
//                    anchor = SCNVector3(firstAnchor.x ?? Double(centerX),
//                                        firstAnchor.z ?? groundZ,
//                                        firstAnchor.y ?? Double(centerY))
//
//                    if let coordinate = firstAnchor.coordinate {
//                        geolocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
//                    }
//                }
//            }
//
//            // json.settings version 3
//            if viewpoints.isEmpty {
//                self.serialQueue.async {
//                    let viewpointLabelNode = self.overlayView.labelNode(labelName: self.viewpointLabelName,
//                                                                        iconNamed: LabelIcons.geolocationAnchor.rawValue)
//                    viewpointLabelNode.isHidden = !(UserDefaults.standard.bool(for: .drawAnchor))
//                    viewpointLabelNode.callToAction = false
//
//                    if isDefaultAnchor {
//                        viewpointLabelNode.text = "Anchor (Default)"
//                    } else {
//                        viewpointLabelNode.text = "Anchor (Custom)"
//                    }
//                }
//
//                // Position the container node, including the model and the anchor
//                // node, to the anchor location.
//                // The FME coordinate z axis = ARKit y axis
//                // The FME coordinate y axis = ARKit z axis
//                modelNode.position = SCNVector3(-anchor.x, -anchor.y, anchor.z)
//            } else {
//                // If we have a viewpont, we should always show it at the beginning
//                UserDefaults.standard.set(true, for: .drawAnchor)
//            }
//
//            // Rotate to Y up
//            modelNode.eulerAngles.x = -Float.pi / 2
//
////            // Rotate to face True North
////            if let initialHeading = self.initialHeading {
////                print("Setting model heading to \(initialHeading)")
////                modelNode.eulerAngles.y = Float(initialHeading) * Float.pi / 180.0
////            }
//
//            let modelDimension = self.dimension(modelNode)
//            let maxLength = max(modelDimension.x, modelDimension.y, modelDimension.z)
//            let definition = VirtualObjectDefinition(modelName: "model", displayName: "model", particleScaleInfo: [:])
//            let object = VirtualObject(definition: definition,
//                                       modelNode: modelNode,
//                                       viewpoints: viewpoints)
//            object.name = "VirtualObject"
//
//            if let firstViewpoint = object.viewpoints.first {
//                object.anchorAtViewpoint(viewpointId: firstViewpoint.id)
//            }
//
//            // Set a cteagory bit mask to include the virtual object in the hit test.
//            object.categoryBitMask = HitTestOptionCategoryBitMasks.virtualObject.rawValue
//
//            // Scale the virtual object
//            if maxLength > 0 {
//                // By default, scale the model to be within a 0.5 meter cube.
//                // If the scaling is set in the model json file, use it instead.
//                if self.scaleMode == .fullScale {
//                    object.scale = SCNVector3(1.0, 1.0, 1.0)
//                } else if let userSpecifiedScale = self.scaling {
//                    object.scale = SCNVector3(userSpecifiedScale, userSpecifiedScale, userSpecifiedScale)
//                } else {
//                    let preferredScale = (Float(0.5) / maxLength)
//                    object.scale = SCNVector3(preferredScale, preferredScale, preferredScale)
//                }
//
//                // Set scale lock
//                self.virtualObjectManager.allowScaling = !self.scaleLockEnabled
//            }
//
//            //logSceneNode(object, level: 0)
//
//            let position = (self.focusSquare?.lastPosition ?? SIMD3<Float>(0, 0, -5))
//
//            self.virtualObjectManager.loadVirtualObject(object, to: position, cameraTransform: cameraTransform)
//            if object.parent == nil {
//                self.serialQueue.async {
//                    self.sceneView.scene.rootNode.addChildNode(object)
//
//                    // Add Viewpoint labels
//                    for index in object.viewpoints.indices {
//                        let viewpoint = object.viewpoints[index]
//
//                        let viewpointLabelNode = self.overlayView.labelNode(labelName: viewpoint.id.uuidString,
//                                                                            iconNamed: LabelIcons.viewpoint.rawValue)
//
//                        if (object.currentViewpoint == viewpoint.id) {
//                            viewpointLabelNode.secondaryText = "CURRENT VIEWPOINT"
//                            viewpointLabelNode.callToAction = false
//                        } else {
//                            viewpointLabelNode.callToAction = true
//                        }
//
//                        if let name = viewpoint.name, !name.isEmpty {
//                            viewpointLabelNode.text = name
//
//                        } else {
//                            viewpointLabelNode.text = "❂ Viewpoint \(index)"
//                            object.viewpoints[index].name = viewpointLabelNode.text
//                        }
//                    }
//
//                    if let geolocation = geolocation {
//                        var geomarker = self.geolocationNode()
//                        if geomarker == nil {
//                            geomarker = self.addGeolocationNode()
//                        }
//                        geomarker!.geolocation = geolocation
//                        geomarker!.simdPosition = position
//                        geomarker!.anchor = self.settings?.anchors.first
//                        geomarker!.isHidden = true
//
//                        // If there is a geolocation, we should always show
//                        // the geolocation at the beginning
//                        UserDefaults.standard.set(true, for: .drawGeomarker)
//                    }
//                }
//            }
//
//            DispatchQueue.main.async {
//                self.showAssetsButton.isEnabled = true
//                self.showScaleOptionsButton.isHidden = false
//                self.scaleLabel.isHidden = false
//                self.scaleLabel.text = self.dimensionAndScaleText(scale: object.scale.x, node: object)
//
//                if let date = self.settings?.metadata?.modelExpiry {
//
//                    // Create date from components
//                    let userCalendar = Calendar.current // user calendar
//                    let hour = userCalendar.component(.hour, from: date)
//                    let minute = userCalendar.component(.minute, from: date)
//                    let second = userCalendar.component(.second, from: date)
//
//                    let dateFormatter = DateFormatter()
//                    dateFormatter.timeZone = .current
//                    if hour == 23 && minute == 59 && second == 59 {
//                        dateFormatter.dateFormat = "MMM d,yyyy"
//                    } else {
//                        dateFormatter.dateFormat = "MMM d,yyyy HH:mm:ss"
//                    }
//
//                    let dateString = dateFormatter.string(from: date)
//
//                    self.expirationDateLabel.isHidden = false
//
//                    if date < Date() {
//                        self.expirationDateLabel.backgroundColor = .red
//                        self.expirationDateLabel.setTitle("Model expired on \(dateString)", for: .normal)
//                    } else {
//                        self.expirationDateLabel.backgroundColor = .darkGray
//                         self.expirationDateLabel.setTitle("Model will expire on \(dateString)", for: .normal)
//                    }
//                }
//            }
//        }
//        else {
//            self.textManager.showAlert(title: "Invalid File", message: "No model in the file")
//        }
//
//        //self.modelPath = nil;
//    }
    
//    func adjustMaterialProperties(sceneNode: SCNNode) {
//
//        if let geometry = sceneNode.geometry {
//            for material in geometry.materials {
//
//                // FMEMOBILE-384
//                // SCNSceneSource seems to mistakenly load the OBJ Ka (ambient)
//                // material property as emission property. Since we dont' care
//                // emission for now, we will just copy the emission value to the
//                // original ambient value, and reset the emission property
//                // to zero.
//                material.ambient.contents = material.emission.contents
//                material.emission.contents = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
//
//                // Set doubleSided so that the user can always see the model
//                material.isDoubleSided = true
//
//                // For some reasons, the Tr value in the OBJ model is not read
//                // correctly using SCNSceneSource or Model IO. If the OBJ material has
//                // the d value.
//                if let transparent = material.transparent.contents as? NSNumber {
//                    material.transparency = CGFloat(transparent.floatValue)
//                }
//            }
//
//        }
//
//        for childNode in sceneNode.childNodes {
//            adjustMaterialProperties(sceneNode: childNode)
//        }
//    }
    
//    func logSceneSource(_ sceneSource: SCNSceneSource) {
//        if let assetContributor = sceneSource.property(forKey: SCNSceneSourceAssetContributorsKey) as? String {
//            print("Scene Source: Asset Contributor: \(assetContributor)")
//        }
//
//        if let assetCreatedDate = sceneSource.property(forKey: SCNSceneSourceAssetCreatedDateKey) as? String {
//            print("Scene Source: Asset Created Date: \(assetCreatedDate)")
//        }
//
//        if let assetModifiedDate = sceneSource.property(forKey: SCNSceneSourceAssetModifiedDateKey) as? String {
//            print("Scene Source: Asset Modified Date: \(assetModifiedDate)")
//        }
//
//        if let assetUpAxis = sceneSource.property(forKey: SCNSceneSourceAssetUpAxisKey) as? String {
//            print("Scene Source: Asset Up Axis: \(assetUpAxis)")
//        }
//
//        if let assetUnit = sceneSource.property(forKey: SCNSceneSourceAssetUnitKey) as? String {
//            print("Scene Source: Asset Unit: \(assetUnit)")
//        }
//    }
    
//    func logSceneNode(_ sceneNode: SCNNode, level: Int) {
//
//        let currentLevel = max(0 as Int, level)
//        let indentation = String(repeating: "    ", count: currentLevel)
//        let childIndentation = String(repeating: "    ", count: currentLevel + 1)
//        
//        if let name = sceneNode.name {
//            print("\(indentation)SCNNode name: \(name)")
//        } else {
//            print("\(indentation)SCNNode name: <none>")
//        }
//        
//        let (minCoord, maxCoord) = sceneNode.boundingBox
//        print("\(childIndentation)boundingBox = '\(minCoord)', '\(maxCoord)'")
//        
//        if let geometry = sceneNode.geometry {
//            print("\(childIndentation)geometry: \(geometry)")
//            logGeometry(geometry, level: currentLevel + 2)
//        } else {
//            print("\(childIndentation)geometry: <none>")
//        }
//        
//        for childNode in sceneNode.childNodes {
//            logSceneNode(childNode, level: currentLevel + 1)
//        }
//    }
//    
//    func logGeometry(_ geometry: SCNGeometry, level: Int) {
//        let currentLevel = max(0 as Int, level)
//        let indentation = String(repeating: "    ", count: currentLevel)
//        
//        if let name = geometry.name {
//            print("\(indentation)SCNGeometry name: \(name)")
//        } else {
//            print("\(indentation)SCNGeometry name: <none>")
//        }
//        
//        print("\(indentation)Geometry Elements: \(geometry.elements.count)")
//        for (index, geometryElement) in geometry.elements.enumerated() {
//            logGeometryElement(geometryElement, level: currentLevel + 1, prefix: "\(index)")
//        }
//        
//        print("\(indentation)Materials: \(geometry.materials.count)")
//        for (index, material) in geometry.materials.enumerated() {
//            logMaterial(material, level: currentLevel + 1, prefix: "\(index)")
//        }
//    }
//    
//    func logGeometryElement(_ element: SCNGeometryElement, level: Int, prefix: String) {
//        let currentLevel = max(0 as Int, level)
//        let indentation = String(repeating: "    ", count: currentLevel)
//
//        print("\(indentation)\(prefix): \(element)")
//    }
//    
//    func logMaterial(_ material: SCNMaterial, level: Int, prefix: String) {
//        let currentLevel = max(0 as Int, level)
//        let indentation = String(repeating: "    ", count: currentLevel)
//        let childIndentation = String(repeating: "    ", count: currentLevel + 1)
//        
//        if let materialName = material.name {
//            print("\(indentation)\(prefix): name: \(materialName)")
//        } else {
//            print("\(indentation)\(prefix): name: <none>")
//        }
//        
//        print("\(childIndentation)lightingModel: \(material.lightingModel)")
//        print("\(childIndentation)shininess: \(material.shininess)")
//        print("\(childIndentation)fresnelExponent: \(material.fresnelExponent)")
//        print("\(childIndentation)isLitPerPixel: \(material.isLitPerPixel)")
//        print("\(childIndentation)isDoubleSided: \(material.isDoubleSided)")
//        print("\(childIndentation)cullMode: \(material.cullMode)")
//        print("\(childIndentation)blendMode: \(material.blendMode)")
//        print("\(childIndentation)locksAmbientWithDiffuse: \(material.locksAmbientWithDiffuse)")
//        print("\(childIndentation)writesToDepthBuffer: \(material.writesToDepthBuffer)")
//        print("\(childIndentation)readsFromDepthBuffer: \(material.readsFromDepthBuffer)")
//        print("\(childIndentation)colorBufferWriteMask: \(material.colorBufferWriteMask)")
//        print("\(childIndentation)fillMode: \(material.fillMode)")
//        print("\(childIndentation)transparency: \(material.transparency)")
//        logMaterialProperty(material.transparent, level: currentLevel + 1, prefix: "transparent")
//        logMaterialProperty(material.diffuse, level: currentLevel + 1, prefix: "diffuse")
//        logMaterialProperty(material.specular, level: currentLevel + 1, prefix: "specular")
//        logMaterialProperty(material.ambient, level: currentLevel + 1, prefix: "ambient")
//        logMaterialProperty(material.ambientOcclusion, level: currentLevel + 1, prefix: "ambientOcclusion")
//        logMaterialProperty(material.selfIllumination, level: currentLevel + 1, prefix: "selfIllumination")
//        logMaterialProperty(material.metalness, level: currentLevel + 1, prefix: "metalness")
//        logMaterialProperty(material.roughness, level: currentLevel + 1, prefix: "roughness")
//        logMaterialProperty(material.displacement, level: currentLevel + 1, prefix: "displacement")
//        logMaterialProperty(material.normal, level: currentLevel + 1, prefix: "normal")
//        logMaterialProperty(material.reflective, level: currentLevel + 1, prefix: "reflective")
//        logMaterialProperty(material.emission, level: currentLevel + 1, prefix: "emission")
//        
//    }
//    
//    func logMaterialProperty(_ materialProperty: SCNMaterialProperty, level: Int, prefix: String) {
//        let currentLevel = max(0 as Int, level)
//        let indentation = String(repeating: "    ", count: currentLevel)
//        
//        print("\(indentation)\(prefix): \(materialProperty)")
//        
//    }
//    
//    // MARK: FileManagerDelegate
//    
//    func fileManager(_ fileManager: FileManager, shouldRemoveItemAt URL: URL) -> Bool {
//        
//        // For some unknown reasons, the follow commented code caused some textures not
//        // being able to be removed from the previous model and incorrectly apply the
//        // textures to the next model. We reverted back to always return true, but this
//        // causes an error if the user opens a file without anchoring the model on a
//        // plane before closing the file.
//        //if fileManager.fileExists(atPath: URL.absoluteString) {
//        //    return true
//        //} else {
//        //    return false
//        //}
//        return true
//    }
//    
//    func dimension(_ sceneNode: SCNNode) -> SCNVector3 {
//        let (minCoord, maxCoord) = sceneNode.boundingBox
//        return SCNVector3(maxCoord.x - minCoord.x, maxCoord.y - minCoord.y, maxCoord.z - minCoord.z)
//    }
}
