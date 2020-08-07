//
//  PointyLabelNode.swift
//  FMEAR
//
//  Created by Angus Lau on 2020-07-29.
//  Copyright © 2020 Safe Software Inc. All rights reserved.
//

import Foundation
import SpriteKit

class PointyLabelNode: SKNode {

    private var label: LabelNode!
    private var button: ButtonNode!
    private var lineNode: SKShapeNode!
    
    var alwaysVisibleOnScreen: Bool = false
    
    var point = CGPoint(x: 0, y: 0) {
        didSet {
            updateLabelNodePosition()
        }
    }
    
    var text: String = "" {
        didSet {
            if label.primaryText != text {
                label.primaryText = text
                updateLabelNodePosition()
            }
        }
    }
    
    var secondaryText: String = "" {
        didSet {
            if label.secondaryText != secondaryText {
                label.secondaryText = secondaryText
                updateLabelNodePosition()
            }
        }
    }
    
    var callToActionText: String = "" {
        didSet {
            if label.callToActionText != callToActionText {
                label.callToActionText = callToActionText
                updateLabelNodePosition()
            }
        }
    }
    
    var callToAction: Bool {
        set {
            button.callToAction = newValue
        }
        
        get {
            return button.callToAction
        }
    }
    
    override var name: String? {
        didSet {
            button.id = name
        }
    }
    
    init(iconNamed: String? = nil) {
        super.init()
        
        self.lineNode = SKShapeNode()
        lineNode.strokeColor =  Colors.labelFill
        self.addChild(self.lineNode)
        
        self.label = LabelNode(iconNamed: iconNamed)
        self.addChild(self.label)
        
        self.button = ButtonNode()
        self.addChild(self.button)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // We want to put the label above and center the target point, unless the
    // target point is at the top part of the screen with no room for the label
    // or near the side edge of the screen.
    func updateLabelNodePosition() {
        
        guard let scene = self.scene else {
            return
        }
        
        // Point Node
        button.position = point
        
        // We don't want to have the button "tail" to start from the corner
        // since it's more difficult to create the shape for the tail, and
        // it won't look good. Instead, the button tail will always start
        // from the horizontal or vertical side of the button border.
        let sceneWidth = scene.size.width
        let sceneHeight = scene.size.height
        let labelFrame = label.calculateAccumulatedFrame()
        let buttonWidth = labelFrame.size.width
        let buttonHeight = labelFrame.size.height
        let lineHeight: CGFloat = 100.0
        let ratioX = (sceneWidth <= 0.0) ? 0.0 : (point.x / sceneWidth)
        
        // Button position
        var buttonX = point.x - (ratioX * buttonWidth)
        var buttonY = point.y + lineHeight
        if alwaysVisibleOnScreen {
            buttonX = min(max(50.0, buttonX), sceneWidth - 50.0 - buttonWidth)
            buttonY = min(max(50.0, buttonY), sceneHeight - 50.0 - buttonHeight)
        }
        label.position = CGPoint(x: buttonX, y: buttonY)
        
        let secondEndPoint = CGPoint(x: labelFrame.origin.x + (labelFrame.size.width * 0.5), // label.position.x + (label.size.width * 0.5),
                                     y: buttonY)

        
        let path = CGMutablePath()
        path.move(to: point)
        path.addLine(to: secondEndPoint)
        
        // 2020-07-27: The dash line copy creates a memoryleak after many calls.
        //let pattern : [CGFloat] = [2.0, 2.0]
        //lineNode.path = path.copy(dashingWithPhase: 1, lengths: pattern)
        lineNode.path = path
    }
}

class ButtonNode: SKNode {
    
    var pointNode: SKShapeNode!
    var ellipseNode: SKShapeNode!
    
    var id: String?
    
    var callToAction: Bool = false {
        didSet {
            let anim = CABasicAnimation.init(keyPath: "path")
            anim.duration = 10.0
            anim.isRemovedOnCompletion  = false
            
            if callToAction {
                self.ellipseNode.fillColor = Colors.callToActionFill
                self.ellipseNode.strokeColor = Colors.callToActionStroke
                self.pointNode.fillColor = DesignSystem.Colour.ExtendedPalette.orange
                self.pointNode.strokeColor = self.pointNode.fillColor
                let scaleAction = SKAction.scale(to: 1.0, duration: 1)
                ellipseNode.run(scaleAction)
            } else {
                let scaleAction = SKAction.scale(to: 0.1, duration: 1)
                ellipseNode.run(scaleAction) {
                    self.ellipseNode.fillColor = Colors.labelFill
                    self.ellipseNode.strokeColor = self.ellipseNode.fillColor
                    self.pointNode.fillColor = Colors.labelFill
                    self.pointNode.strokeColor = self.pointNode.fillColor
                }
            }
        }
    }
    
    override init() {
        super.init()
        
        self.pointNode = SKShapeNode(ellipseOf: CGSize(width: 6.0, height: 3.0))
        pointNode.fillColor = DesignSystem.Colour.ExtendedPalette.orange
        pointNode.strokeColor = pointNode.fillColor
        self.addChild(self.pointNode)
        
        self.ellipseNode = SKShapeNode(ellipseOf: CGSize(width: 60.0, height: 30.0))
        ellipseNode.fillColor = DesignSystem.Colour.ExtendedPalette.orangeLight20.withAlphaComponent(0.5)
        ellipseNode.strokeColor = DesignSystem.Colour.ExtendedPalette.orange
        self.addChild(self.ellipseNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isUserInteractionEnabled: Bool {
        get {
            return true
        }
        set {
            // ignore
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !callToAction {
            return
        }
        
        if let overlaySKScene = scene as? OverlaySKScene {
            if let delegate = overlaySKScene.overlaySKSceneDelegate {
                delegate.overlaySKSceneDelegate(overlaySKScene, didTapNode: id)
            }
        }
    }
}
