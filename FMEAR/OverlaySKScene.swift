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

protocol OverlaySKSceneDelegate: class {
    func overlaySKSceneDelegate(_: OverlaySKScene, didTapNode nodeName: String?)
}

class OverlaySKScene: SKScene {
    
    weak var overlaySKSceneDelegate: OverlaySKSceneDelegate?
    
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
    
    func labelNode(labelName: String) -> PointyLabelNode {
        if let node = childNode(withName: labelName) as? PointyLabelNode {
            return node
        } else {
            let newLabelNode = PointyLabelNode()
            newLabelNode.name = labelName
            addChild(newLabelNode)
            return newLabelNode
        }
    }
    
    func labelNodeOrNil(labelName: String) -> PointyLabelNode? {
        return childNode(withName: labelName) as? PointyLabelNode;
    }
}

