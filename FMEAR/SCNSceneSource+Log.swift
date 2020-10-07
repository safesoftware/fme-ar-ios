//
//  SCNSceneSource+Log.swift
//  FMEAR
//
//  Created by Angus Lau on 2020-08-30.
//  Copyright © 2020 Safe Software Inc. All rights reserved.
//

import Foundation
import SceneKit

extension SCNSceneSource {
    func log() {
        if let assetContributor = property(forKey: SCNSceneSourceAssetContributorsKey) as? String {
            print("Scene Source: Asset Contributor: \(assetContributor)")
        }
        
        if let assetCreatedDate = property(forKey: SCNSceneSourceAssetCreatedDateKey) as? String {
            print("Scene Source: Asset Created Date: \(assetCreatedDate)")
        }
        
        if let assetModifiedDate = property(forKey: SCNSceneSourceAssetModifiedDateKey) as? String {
            print("Scene Source: Asset Modified Date: \(assetModifiedDate)")
        }
        
        if let assetUpAxis = property(forKey: SCNSceneSourceAssetUpAxisKey) as? String {
            print("Scene Source: Asset Up Axis: \(assetUpAxis)")
        }
        
        if let assetUnit = property(forKey: SCNSceneSourceAssetUnitKey) as? String {
            print("Scene Source: Asset Unit: \(assetUnit)")
        }
    }
}
