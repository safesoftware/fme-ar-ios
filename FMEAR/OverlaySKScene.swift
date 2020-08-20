//
//  OverlaySKScene.swift
//  FMEAR
//
//  Created by Angus Lau on 2019-10-18.
//  Copyright © 2019 Safe Software Inc. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit
import CoreLocation

protocol OverlaySKSceneDelegate: class {
    func overlaySKSceneDelegate(_: OverlaySKScene, didTapNode nodeName: String?)
}

class OverlaySKScene: SKScene, LocationServiceDelegate {
    
    weak var overlaySKSceneDelegate: OverlaySKSceneDelegate?
    
    let compassName = "Compass"
    let modelOrientationIndicatorName = "Model Orirentation Indicator"

    override init(size: CGSize) {
        super.init(size: size)
        self.scaleMode = .resizeFill
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // We don't want the overlay to block any user interaction in the AR view.
    // We enable user interaction on only the nodes that handle tap.
    override var isUserInteractionEnabled: Bool {
        get {
            return false
        }
        set {
            // ignore
        }
    }
    
    // MARK: Labels
    func labelNode(labelName: String, iconNamed: String?) -> PointyLabelNode {
        if let node = childNode(withName: labelName) as? PointyLabelNode {
            return node
        } else {
            let newLabelNode = PointyLabelNode(iconNamed: iconNamed)
            newLabelNode.name = labelName
            addChild(newLabelNode)
            return newLabelNode
        }
    }
    
    func labelNodeOrNil(labelName: String) -> PointyLabelNode? {
        return childNode(withName: labelName) as? PointyLabelNode;
    }
    
    // MARK: Compass
    func compass() -> Compass {
        if let compass = childNode(withName: compassName) as? Compass {
            return compass
        } else {
            let compass = Compass()
            compass.name = compassName
            addChild(compass)
            updateCompassPosition()
            return compass
        }
    }
    
    func updateCompassPosition() {
        let c = compass()
        if UIDevice.current.orientation.isLandscape {
            c.position = CGPoint(x: 40.0 + (c.size.width * 0.5), y: 40.0 + (c.size.height * 0.5))
        } else {
            c.position = CGPoint(x: 20.0 + (c.size.width * 0.5), y: 60.0 + (c.size.height * 0.5))
        }
    }
    
    // MARK: LocationServiceDelegate
    func didUpdateHeading(_ locationService: LocationService, heading: CLHeading) {
        compass().zRotation = CGFloat(heading.trueHeading.toRadian())
    }
}

