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
    func overlaySKSceneDelegate(_: OverlaySKScene, didTapNode node: SKNode)
}


class OverlaySKScene: SKScene {
    
    weak var overlaySKSceneDelegate: OverlaySKSceneDelegate?
    
    override init(size: CGSize) {
        super.init(size: size)
        self.scaleMode = .resizeFill
        self.isUserInteractionEnabled = false
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
            newLabelNode.buttonText = "Move model here >>>"
            newLabelNode.isUserInteractionEnabled = true
            addChild(newLabelNode)
            return newLabelNode
        }
    }
}

class ButtonNode: SKNode {
    
    var labelNode: SKLabelNode?
    var shapeNode: SKShapeNode?
    
    var text: String = "" {
        didSet {
            
            if let oldLabelNode = labelNode {
                self.removeChildren(in: [oldLabelNode])
            }
            self.labelNode = SKLabelNode(text: text)
            self.labelNode!.fontName = UIFont.systemFont(ofSize: 10).fontName
            self.labelNode!.fontColor = .white
            self.labelNode!.fontSize = 10
            self.labelNode!.horizontalAlignmentMode = .left
            self.labelNode!.verticalAlignmentMode = .bottom
//            self.addChild(self.labelNode!)

            if let oldShapeNode = shapeNode {
                self.removeChildren(in: [oldShapeNode])
            }

            let padding: CGFloat = 2.0
            let buttonOrigin = CGPoint(x: -padding, y: -padding)
            let buttonSize = CGSize(width: self.labelNode!.frame.size.width + (padding * 2),
                                    height: self.labelNode!.frame.size.height + (padding * 2))
            let rect = CGRect(origin: buttonOrigin, size: buttonSize)
            self.shapeNode = SKShapeNode(rect: rect)
            self.shapeNode!.fillColor = UIColor(white: 1.0, alpha: 0.2)
            self.shapeNode!.strokeColor = .white
            
            self.shapeNode!.addChild(self.labelNode!)
            self.addChild(self.shapeNode!)
        }
    }
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PointLabelNode: SKNode {

    var labelNode: SKLabelNode!
    var lineNode: SKShapeNode!
    var pointNode: SKShapeNode!
    var buttonNode: ButtonNode?
    
    var point = CGPoint(x: 0, y: 0) {
        didSet {
            updatePointNodePosition()
            updateLabelNodePosition()
            updateLineNode()
        }
    }
    
    var text: String = "" {
        didSet {
            self.labelNode.text = text
            updateLabelNodePosition()
            updateLineNode()
        }
    }
    
    var buttonText: String = "" {
        didSet {
            if buttonText.isEmpty {
                if let buttonNode = buttonNode {
                    self.removeChildren(in: [buttonNode])
                }
            } else {
                if self.buttonNode == nil {
                    self.buttonNode = ButtonNode()
                    self.addChild(self.buttonNode!)
                }
                
                self.buttonNode!.text = buttonText
            }
        }
    }
    
    override init() {
        super.init()
        
        self.labelNode = SKLabelNode(text: "")
//        self.labelNode.fontName = self.fontName
//        self.labelNode.fontColor = .white
        self.labelNode!.fontName = UIFont.systemFont(ofSize: 10).fontName
        self.labelNode.fontSize = 10
        self.labelNode.horizontalAlignmentMode = .left
        self.labelNode.verticalAlignmentMode = .bottom
        
        self.lineNode = SKShapeNode()
        self.lineNode.strokeColor = .white
        
        self.pointNode = SKShapeNode(circleOfRadius: 1)
        self.pointNode.fillColor = .white
                
        self.addChild(self.labelNode)
        self.addChild(self.lineNode)
        self.addChild(self.pointNode)
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
        let horizontalSpacing: CGFloat = 40.0
        let verticalSpacing: CGFloat = 40.0
        
        // Assume we want to display the label right to and above the target point
        var x: CGFloat = min(max(leftMargin, (point.x + horizontalSpacing)), scene.size.width - labelNode.frame.width - rightMargin)
        var y: CGFloat = min(max(bottomMargin, (point.y + verticalSpacing)), scene.size.height - labelNode.frame.height - topMargin)
        
        if x < (point.x - horizontalSpacing) {
            x = min(max(leftMargin, point.x - horizontalSpacing - labelNode.frame.width), scene.size.width - labelNode.frame.width - rightMargin)
        }
        
        self.labelNode.position = CGPoint(x: x, y: y)
        
        if let buttonNode = self.buttonNode {
            let buttonSize = buttonNode.calculateAccumulatedFrame().size
            buttonNode.position = CGPoint(x: x + self.labelNode.frame.width - buttonSize.width, y: y - buttonSize.height)
        }
    }
    
    func updateLineNode() {
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
        lineNode.path = path
    }
    
    func updatePointNodePosition() {
        pointNode.position = point
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {

            let location = touch.location(in: self)

            if contains(location) {
                print("Point Label Touch Began")
            }
        }
    }


    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {

            let location = touch.location(in: self)

            if contains(location) {
                print("Point Label Touch Ended")
            }
            
            if let overlaySKScene = scene as? OverlaySKScene {
                if let delegate = overlaySKScene.overlaySKSceneDelegate {
                    delegate.overlaySKSceneDelegate(overlaySKScene, didTapNode: self)
                }
            }
        }
    }
}
