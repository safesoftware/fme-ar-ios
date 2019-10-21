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

class OverlaySKScene: SKScene {
    
//    var geolocationlabelNode: SKLabelNode!
//    var pointerNode: SKShapeNode!
    
    //var pointLabelNode: PointLabelNode!
    
    override init(size: CGSize) {
        super.init(size: size)
        
//        self.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
//
//        self.geolocationlabelNode = SKLabelNode(text: "Testing")
//        self.geolocationlabelNode.fontName = "DINAlternate-Bold"
//        self.geolocationlabelNode.fontColor = .white
//        self.geolocationlabelNode.fontSize = 24
//        self.geolocationlabelNode.position = CGPoint(x: size.width/2, y: size.height/2)
//        self.geolocationlabelNode.horizontalAlignmentMode = .left
//        self.geolocationlabelNode.verticalAlignmentMode = .bottom
//
//        self.pointerNode = SKShapeNode()
//        self.pointerNode.strokeColor = .white
        
//        self.pointLabelNode = PointLabelNode()
//        self.pointLabelNode.text = "Point Label Node"
        
//        self.addChild(self.geolocationlabelNode)
//        self.addChild(self.pointerNode)
        //self.addChild(self.pointLabelNode)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func labelNode(labelName: String) -> PointLabelNode {
        if let node = childNode(withName: labelName) as? PointLabelNode {
            return node
        } else {
            let newLabelNode = PointLabelNode()
            newLabelNode.name = labelName
            addChild(newLabelNode)
            return newLabelNode
        }
    }
    
//    func distance(from: CGPoint, to: CGPoint) -> CGFloat {
//        return sqrt((from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y))
//    }
    
//    func updateLabelPosition() {
//        let x: CGFloat = min(max(20, (geolocationScreenCoordinate.x + 20)), size.width - geolocationlabelNode.frame.width - 80)
//        let y: CGFloat = min(max(100, (geolocationScreenCoordinate.y + 20)), size.height - geolocationlabelNode.frame.height - 100)
//        self.geolocationlabelNode.position = CGPoint(x: x, y: y)
//    }
//
//    var geolocationScreenCoordinate: CGPoint = CGPoint(x: 0, y: 0) {
//        didSet {
//
//            self.pointLabelNode.point = geolocationScreenCoordinate
//
//            updateLabelPosition()
//
//            var path = CGMutablePath()
//
//            // Draw the pointer line
//            let labelCenter = self.geolocationlabelNode.position.x + (geolocationlabelNode.frame.width / 2)
//            if labelCenter < geolocationScreenCoordinate.x {
//                path.move(to: self.geolocationlabelNode.position + (CGPoint(x: geolocationlabelNode.frame.width, y: 0)))
//            } else {
//                path.move(to: self.geolocationlabelNode.position)
//            }
//            path.addLine(to: geolocationScreenCoordinate)
//
//            // Draw an horizontal line below the text
//            path.move(to: self.geolocationlabelNode.position)
//            path.addLine(to: geolocationlabelNode.position + CGPoint(x: geolocationlabelNode.frame.width, y: 0))
//            pointerNode.path = path
//        }
//    }
}

class PointLabelNode: SKNode {
    
    let fontName = "DINAlternate-Bold"
    var labelNode: SKLabelNode!
    var pointerNode: SKShapeNode!
    
    var point = CGPoint(x: 0, y: 0) {
        didSet {
            updateLabelNodePosition()
            updatePointerNodePath()
        }
    }
    
    var text: String = "" {
        didSet {
            self.labelNode.text = text
            updateLabelNodePosition()
            updatePointerNodePath()
        }
    }
    
    override init() {
        super.init()
        
        self.labelNode = SKLabelNode(text: "")
        self.labelNode.fontName = self.fontName
        self.labelNode.fontColor = .white
        self.labelNode.fontSize = 16
        self.labelNode.horizontalAlignmentMode = .left
        self.labelNode.verticalAlignmentMode = .bottom
        
        self.pointerNode = SKShapeNode()
        self.pointerNode.strokeColor = .white
        
        self.addChild(self.labelNode)
        self.addChild(self.pointerNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateLabelNodePosition() {
        
        guard let scene = self.scene else {
            return
        }
        
        let leftMargin: CGFloat = 20.0
        let rightMargin: CGFloat = 80.0
        let topMargin: CGFloat = 100.0
        let bottomMargin: CGFloat = 100.0
        let horizontalSpacing: CGFloat = 20.0
        let verticalSpacing: CGFloat = 20.0
        
        let x: CGFloat = min(max(leftMargin, (point.x + horizontalSpacing)), scene.size.width - labelNode.frame.width - rightMargin)
        let y: CGFloat = min(max(bottomMargin, (point.y + verticalSpacing)), scene.size.height - labelNode.frame.height - topMargin)
        self.labelNode.position = CGPoint(x: x, y: y)
    }
    
    func updatePointerNodePath() {
        let path = CGMutablePath()
        
        // Draw the pointer line
        let labelCenter = self.labelNode.position.x + (labelNode.frame.width / 2)
        if labelCenter < point.x {
            path.move(to: self.labelNode.position + (CGPoint(x: labelNode.frame.width, y: 0)))
        } else {
            path.move(to: self.labelNode.position)
        }
        path.addLine(to: point)
        
        // Draw an horizontal line below the text
        path.move(to: self.labelNode.position)
        path.addLine(to: labelNode.position + CGPoint(x: labelNode.frame.width, y: 0))
        pointerNode.path = path
    }
}
