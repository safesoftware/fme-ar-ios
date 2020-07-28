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
            static let text = DesignSystem.Colour.NeutralPalette.greyLight30
            static let secondaryText = DesignSystem.Colour.NeutralPalette.offBlack
            static let callToActionText = DesignSystem.Colour.ExtendedPalette.orangeLight10
            static let fill = DesignSystem.Colour.NeutralPalette.offWhite.withAlphaComponent(0.95)
            static let border = UIColor.clear
        }
        
        struct DarkMode {
            static let text = DesignSystem.Colour.NeutralPalette.white
            static let secondaryText = DesignSystem.Colour.NeutralPalette.offWhite
            static let callToActionText = DesignSystem.Colour.ExtendedPalette.blueLight30
            static let fill = DesignSystem.Colour.NeutralPalette.grey.withAlphaComponent(0.99)
            static let border = UIColor.clear
        }
    }
    
    var iconNode: SKSpriteNode?
    
    var labelNode: SKLabelNode
    var shapeNode: SKShapeNode
    let cornerRadius: CGFloat = 10.0
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
            
            var str: String = ""
            if secondaryText.isEmpty {
                str = text
            } else {
                if !text.isEmpty {
                    str = "\(text)\(newline)\(secondaryText)"
                } else {
                    str = secondaryText
                }
            }
            
            let attrString = NSMutableAttributedString(string: str)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            paragraphStyle.paragraphSpacing = 3
            
            var textLocation = 0
            if !text.isEmpty {
                // Text
                let textRange = NSRange(location: 0, length: text.count)
                attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle,
                                        range: textRange)
                attrString.addAttributes([NSAttributedString.Key.foregroundColor : ColourPalette.LightMode.text,
                                          NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: .caption2)],
                                         range: textRange)
            }
            
            if !secondaryText.isEmpty {
                if !text.isEmpty {
                    textLocation = text.count + newline.count
                } else {
                    textLocation = text.count
                }
            
                // Secondary Text
                let secondaryTextRange = NSRange(location: textLocation, length: secondaryText.count)
                attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle,
                                        range: secondaryTextRange)
                attrString.addAttributes([NSAttributedString.Key.foregroundColor : ColourPalette.LightMode.secondaryText,
                                          NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: .footnote)],
                                         range: secondaryTextRange)
            }
            
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
        
        if let iconNode = iconNode {
            self.addChild(iconNode)
        }
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

extension UIImage {
    func withColor(_ color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        guard let ctx = UIGraphicsGetCurrentContext(), let cgImage = cgImage else { return self }
        color.setFill()
        ctx.translateBy(x: 0, y: size.height)
        ctx.scaleBy(x: 1.0, y: -1.0)
        ctx.clip(to: CGRect(x: 0, y: 0, width: size.width, height: size.height), mask: cgImage)
        ctx.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        guard let colored = UIGraphicsGetImageFromCurrentImageContext() else { return self }
        UIGraphicsEndImageContext()
        return colored
    }
}

class PointLabelNode: SKNode {

//    var triangleNode: SKShapeNode?
    var buttonNode: ButtonNode!
    var pointNode: SKShapeNode!
    var ellipseNode: SKShapeNode!
    var lineNode: SKShapeNode!
    var userInteractionNode: SKShapeNode!
    
    var alwaysVisibleOnScreen: Bool = false
    
    var callToAction: Bool = false {
        didSet {
            let anim = CABasicAnimation.init(keyPath: "path")
            anim.duration = 10.0
            anim.isRemovedOnCompletion  = false
            
            if callToAction {
                ellipseNode.run(SKAction.scale(to: 1.0, duration: 1))

                ellipseNode.run(SKAction.customAction(withDuration: 5, actionBlock: { (node, timeDuration) in
                    let shapeNode = node as! SKShapeNode
                    shapeNode.fillColor = DesignSystem.Colour.ExtendedPalette.orangeLight20.withAlphaComponent(0.5)
                    shapeNode.strokeColor = DesignSystem.Colour.ExtendedPalette.orange
                }))
                pointNode.fillColor = DesignSystem.Colour.ExtendedPalette.orange
                pointNode.strokeColor = pointNode.fillColor
            } else {
                ellipseNode.run(SKAction.scale(to: 0.1, duration: 1))
                ellipseNode.run(SKAction.customAction(withDuration: 5, actionBlock: { (node, timeDuration) in
                    let shapeNode = node as! SKShapeNode
                    shapeNode.fillColor = DesignSystem.Colour.NeutralPalette.greyLight50.withAlphaComponent(0.5)
                    shapeNode.strokeColor = DesignSystem.Colour.NeutralPalette.offWhite.withAlphaComponent(0.5)
                }))
                pointNode.fillColor = DesignSystem.Colour.NeutralPalette.greyLight50.withAlphaComponent(0.5)
                pointNode.strokeColor = pointNode.fillColor
            }
        }
    }

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

        self.pointNode = SKShapeNode(ellipseOf: CGSize(width: 6.0, height: 3.0))
        pointNode.fillColor = DesignSystem.Colour.ExtendedPalette.orange
        pointNode.strokeColor = pointNode.fillColor
        //pointNode.isUserInteractionEnabled = false
        self.addChild(self.pointNode)
        
        self.ellipseNode = SKShapeNode(ellipseOf: CGSize(width: 60.0, height: 30.0))
        ellipseNode.fillColor = DesignSystem.Colour.ExtendedPalette.orangeLight20.withAlphaComponent(0.5)
        ellipseNode.strokeColor = DesignSystem.Colour.ExtendedPalette.orange
        //ellipseNode.isUserInteractionEnabled = false
        self.addChild(self.ellipseNode)
        
        userInteractionNode = SKShapeNode(ellipseOf: CGSize(width: 120.0, height: 60.0))
        userInteractionNode.fillColor = ellipseNode.fillColor .withAlphaComponent(CGFloat.leastNonzeroMagnitude)
        userInteractionNode.strokeColor = ellipseNode.strokeColor .withAlphaComponent(CGFloat.leastNonzeroMagnitude)
        //userInteractionNode.isUserInteractionEnabled = true
        self.addChild(userInteractionNode)
        
        self.lineNode = SKShapeNode()
        lineNode.strokeColor = DesignSystem.Colour.NeutralPalette.offWhite
        //self.lineNode.isUserInteractionEnabled = false
        self.addChild(self.lineNode)
        
        self.buttonNode = ButtonNode()
        //self.buttonNode.isUserInteractionEnabled = false
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
        
        // Point Node
        pointNode.position = point
        ellipseNode.position = point
        userInteractionNode.position = point
        
        // We don't want to have the button "tail" to start from the corner
        // since it's more difficult to create the shape for the tail, and
        // it won't look good. Instead, the button tail will always start
        // from the horizontal or vertical side of the button border.
        let sceneWidth = scene.size.width
        let sceneHeight = scene.size.height
        let cornerRadius = buttonNode.cornerRadius
        let buttonWidth = buttonNode.size.width
        let buttonHeight = buttonNode.size.height
        let lineHeight: CGFloat = 100.0
        let ratioX = (sceneWidth <= 0.0) ? 0.0 : (point.x / sceneWidth)
        
        // Button position
        var buttonX = point.x - cornerRadius - (ratioX * (buttonWidth - (cornerRadius * 2)))
        var buttonY = point.y + lineHeight
        if alwaysVisibleOnScreen {
            buttonX = min(max(50.0, buttonX), sceneWidth - 50.0 - buttonWidth)
            buttonY = min(max(50.0, buttonY), sceneHeight - 50.0 - buttonHeight)
        }
        buttonNode.position = CGPoint(x: buttonX, y: buttonY)
        
        var secondEndPoint = CGPoint(x: buttonNode.position.x + (buttonNode.size.width * 0.5),
                                     y: buttonY)

        
        let path = CGMutablePath()
        path.move(to: point)
        path.addLine(to: secondEndPoint)
        
        // 2020-07-27: The dash line copy creates a memoryleak after many calls.
        // let pattern : [CGFloat] = [4.0, 4.0]
        //lineNode.path = path.copy(dashingWithPhase: 1, lengths: pattern)
        lineNode.path = path
    }


    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {

            let location = touch.location(in: self)

            if userInteractionNode.contains(location) {
                print("Point Label Touch Began")
            }
        }
    }


    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {

            let location = touch.location(in: self)

            if userInteractionNode.contains(location) {
                print("Point Label Touch Ended")
            } else {
                continue
            }
            
            if let overlaySKScene = scene as? OverlaySKScene {
                if let delegate = overlaySKScene.overlaySKSceneDelegate {
                    delegate.overlaySKSceneDelegate(overlaySKScene, didTapNode: self)
                }
            }
        }
    }
}
