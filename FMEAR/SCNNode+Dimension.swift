//
//  SCNNode+Dimension.swift
//  FMEAR
//
//  Created by Angus Lau on 2020-08-29.
//  Copyright © 2020 Safe Software Inc. All rights reserved.
//

import Foundation
import SceneKit

extension SCNNode {
    
    // Returns the dimension of the x, y, and z in a SCNVector3
    func dimension() -> SCNVector3 {
        let (minCoord, maxCoord) = self.boundingBox
        return SCNVector3(maxCoord.x - minCoord.x, maxCoord.y - minCoord.y, maxCoord.z - minCoord.z)
    }
}
