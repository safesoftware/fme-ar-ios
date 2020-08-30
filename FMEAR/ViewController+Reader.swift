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
        reader.delegate = self
        
        print("Opening dataset '\(url)'...")
        
        if datasetOpened(url: url) {
            // TODO: We have opened this dataset. We will reuse the model by creating
            // another instance of the model in the scene.
        } else {
            reader.read(url: url)
        }
    }
    
    func closeDataset(url: URL) {
        print("Closing dataset '\(url)'...")
        // TODO: Remove the record, the model, and the overlay
    }
    
    func reloadAllDatasets() {
        let keys = datasets.keys
        datasets.removeAll()
        for key in keys {
            openDataset(url: key)
        }
    }
    
    func datasetOpened(url: URL) -> Bool {
        return datasets[url] != nil
    }
    
    // MARK: - FMEReaderDelegate
    func reader(_ reader: FMEReader, datasetRead: Dataset) {
        // NOTE: The UI elements might not be ready yet while we are here since this
        // delegate function could be called before viewDidLoad. Be careful not to access
        // anything of the UI.
        
        // If there is a model, we will add it to the scene in the next frame update.
        if let url = datasetRead.documentURL, datasetRead.model != nil {
            datasets[url] = datasetRead
            datasetsReady.append(url)
        }
    }
    
    func reader(_ reader: FMEReader, didFailWithError error: Error) {
        // NOTE: The UI elements might not be ready yet while we are here since this
        // delegate function could be called before viewDidLoad. Be careful not to access
        // anything of the UI.
        errors.append(error)
    }
    
    
}
