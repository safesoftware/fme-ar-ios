//
//  ViewController+Reader.swift
//  FMEAR
//
//  Created by Angus Lau on 2020-08-30.
//  Copyright © 2020 Safe Software Inc. All rights reserved.
//

import Foundation

extension ViewController: FMEReaderDelegate {
    
    func openDataset(url: URL) {
        // Since we don't support multiple datasets yet, we should close all the previous
        // datasets and create a new reader so that we can forget the dataset still being
        // read
        closeAllDatasets()
        reader = FMEARReader()
        reader?.delegate = self

        print("Opening dataset '\(url)'...")

        if datasetOpened(url: url) {
            // TODO: We have opened this dataset. We will reuse the model by creating
            // another instance of the model in the scene.
        } else {
            reader?.read(url: url)
        }
    }
    
     func closeDataset(url: URL) {
         print("Closing dataset '\(url)'...")
         datasetsReady.removeValue(forKey: url)
         if let dataset = datasets.removeValue(forKey: url) {
             if let model = dataset.model as? VirtualObject {
                 for viewpoint in model.viewpoints {
                     let _ = self.overlayView.removeLabel(labelName: viewpoint.id.uuidString)
                 }
                 
                 model.removeFromParentNode()
             }
         }
                 
         // TODO: The default viewpoint name and the geolocation
         // anchor name are not associated with any dataset. We
         // have to remove them whenever we remove a dataset, but
         // we should change them to something unique that only
         // assoicate to a dataset.
         let _ = self.overlayView.removeLabel(labelName: self.geomarkerLabelName)
         let _ = self.overlayView.removeLabel(labelName: self.viewpointLabelName)
     }
     

     func datasetOpened(url: URL) -> Bool {
         return datasets[url] != nil
     }
    
    func closeAllDatasets() {
        let datasetUrls = datasets.keys
        for url in datasetUrls {
            closeDataset(url: url)
        }
    }
    
    func reloadAllDatasets() {
        print("Reloading all \(datasets.count) datasets...")
        let keys = datasets.keys
        closeAllDatasets()
        for key in keys {
            openDataset(url: key)
        }
    }
    
    // MARK: - FMEReaderDelegate
    func reader(_ reader: FMEReader, datasetRead: Dataset) {
        // NOTE: The UI elements might not be ready yet while we are here since this
        // delegate function could be called before viewDidLoad. Be careful not to access
        // anything of the UI.
        
        // If the reader is not the current one, we should forget about the dataset
        if reader != self.reader {
            return
        }
        
        // If there is a model, we will add it to the scene in the next frame update.
        if let url = datasetRead.documentURL, datasetRead.model != nil {
            datasets[url] = datasetRead
            datasetsReady[url] = datasetRead
        }
    }
    
    func reader(_ reader: FMEReader, didFailWithError error: Error) {
        // NOTE: The UI elements might not be ready yet while we are here since this
        // delegate function could be called before viewDidLoad. Be careful not to access
        // anything of the UI.
        if reader != self.reader {
            return
        }
        
        errors.append(error)
    }
    
    
}
