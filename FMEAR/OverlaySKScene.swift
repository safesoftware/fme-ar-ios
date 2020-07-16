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
            newLabelNode.isUserInteractionEnabled = true
            addChild(newLabelNode)
            return newLabelNode
        }
    }
    
    func labelNodeOrNil(labelName: String) -> PointLabelNode? {
        return childNode(withName: labelName) as? PointLabelNode;
    }
}

class ButtonNode: SKNode {
    
    struct ColourPalette {
        
        struct LightMode {
            static let text = DesignSystem.Colour.NeutralPalette.grey
            static let secondaryText = DesignSystem.Colour.NeutralPalette.greyLight30
            static let callToActionText = DesignSystem.Colour.ExtendedPalette.orangeLight10
            static let fill = DesignSystem.Colour.NeutralPalette.offWhite.withAlphaComponent(0.95)
            static let border = UIColor.clear
        }
        
        struct DarkMode {
            static let text = DesignSystem.Colour.NeutralPalette.offWhite
            static let secondaryText = DesignSystem.Colour.NeutralPalette.white
            static let callToActionText = DesignSystem.Colour.ExtendedPalette.blueLight30
            static let fill = DesignSystem.Colour.NeutralPalette.grey.withAlphaComponent(0.99)
            static let border = UIColor.clear
        }
    }
    
    var labelNode: SKLabelNode
    var shapeNode: SKShapeNode
    let cornerRadius: CGFloat = 5.0
    let maxWidth: CGFloat = 150
    private(set) var size: CGSize = CGSize()
    let padding: CGFloat = 20.0
    
    var callToAction: Bool = false {
        didSet {
            updateLabelNode()
        }
    }
    
    var text: String = "" {
        didSet {
            updateLabelNode()
        }
    }
    
    var secondaryText: String = "" {
        didSet {
            updateLabelNode()
        }
    }
    
    func updateLabelNode() {
        if labelNode.text != text {
            // 2020-07-10: As of today, SKLabelNode is not able to properly
            // center the text. Attributed string can workaround the issue
            let newline = "\n"
            let attrString = NSMutableAttributedString(string: text + newline + secondaryText)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            // Text
            let textRange = NSRange(location: 0, length: text.count + newline.count)
            attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle,
                                    range: textRange)
            attrString.addAttributes([NSAttributedString.Key.foregroundColor : ColourPalette.LightMode.text,
                                      NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: .headline).withSize(labelNode.fontSize)],
                                     range: textRange)
            
            // Secondary Text
            let secondaryColour = (callToAction) ? ColourPalette.LightMode.callToActionText : ColourPalette.LightMode.secondaryText
            let secondaryTextRange = NSRange(location: text.count + newline.count, length: secondaryText.count)
            attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle,
                                    range: secondaryTextRange)
            attrString.addAttributes([NSAttributedString.Key.foregroundColor : secondaryColour,
                                      NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: .subheadline).withSize(labelNode.fontSize)],
                                     range: secondaryTextRange)
            
            labelNode.attributedText = attrString
            
            updateShape()
        }
    }
        
    override init() {
        
        labelNode = SKLabelNode()
        labelNode.fontName = "Helvetica-Bold"
        labelNode.fontColor = .white
        
        let systemFontSize = UIFont.preferredFont(forTextStyle: .body).pointSize
        labelNode.fontSize = systemFontSize - 4 // System font is 14 - 23 (or 53 for Larger Accessibiliy Sizes)
        labelNode.horizontalAlignmentMode = .left
        labelNode.verticalAlignmentMode = .bottom
        labelNode.preferredMaxLayoutWidth = maxWidth
        labelNode.lineBreakMode = .byWordWrapping
        labelNode.numberOfLines = 0
        labelNode.zPosition = 1
        labelNode.position = CGPoint(x: padding, y: padding)

        shapeNode = SKShapeNode()
        
        super.init()
        
        self.addChild(labelNode)
        self.addChild(shapeNode)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateShape() {
        self.removeChildren(in: [shapeNode])

        let buttonOrigin = CGPoint.zero // CGPoint(x: -padding, y: -padding)
        let buttonSize = CGSize(width: labelNode.frame.size.width + (padding * 2),
                                height: labelNode.frame.size.height + (padding * 2))
        let rect = CGRect(origin: buttonOrigin, size: buttonSize)
        shapeNode = SKShapeNode(rect: rect, cornerRadius: cornerRadius)
        shapeNode.fillColor = ColourPalette.LightMode.fill
        shapeNode.strokeColor = ColourPalette.LightMode.border
        self.addChild(shapeNode)
        
        self.size = calculateAccumulatedFrame().size
    }
}

class PointLabelNode: SKNode {

    var triangleNode: SKShapeNode?
    var buttonNode: ButtonNode!

    var point = CGPoint(x: 0, y: 0) {
        didSet {
            updateLabelNodePosition()
        }
    }
    
    var text: String = "" {
        didSet {
            buttonNode.text = text
            updateLabelNodePosition()
        }
    }
    
    override init() {
        super.init()
        
        self.buttonNode = ButtonNode()
        self.addChild(self.buttonNode)
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
        
        // We don't want to have the button "tail" to start from the corner
        // since it's more difficult to create the shape for the tail, and
        // it won't look good. Instead, the button tail will always start
        // from the horizontal or vertical side of the button border.
        let sceneWidth = scene.size.width
        let cornerRadius = buttonNode.cornerRadius
        let buttonWidth = buttonNode.size.width
        let tailWidth: CGFloat = 20.0
        let tailHeight: CGFloat = 20.0
        let ratioX = (sceneWidth <= 0.0) ? 0.0 : (point.x / sceneWidth)
        let deltaX = min(max(0.0, tailWidth * ratioX), tailWidth)
        let buttonY = point.y + tailHeight
        buttonNode.position = CGPoint(x: point.x - cornerRadius - (ratioX * (buttonWidth - (cornerRadius * 2))), y: buttonY)
        
        if let oldNode = self.triangleNode {
            self.removeChildren(in: [oldNode])
        }
        
        var points = [point,
                      CGPoint(x: point.x + tailWidth - deltaX, y: buttonY),
                      CGPoint(x: point.x - deltaX, y: buttonY),
                      point]
        self.triangleNode = SKShapeNode(points: &points, count: points.count)
        self.triangleNode!.strokeColor = ButtonNode.ColourPalette.LightMode.border
        self.triangleNode!.fillColor = ButtonNode.ColourPalette.LightMode.fill
        self.addChild(self.triangleNode!)
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
