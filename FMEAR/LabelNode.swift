//
//  LabelNode.swift
//  FMEAR
//
//  Created by Angus Lau on 2020-07-25.
//  Copyright © 2020 Safe Software Inc. All rights reserved.
//

import Foundation
import SpriteKit


class LabelNode: SKNode {
        
    var iconNode: SKSpriteNode?
    let iconSize = CGSize(width: 20.0, height: 20.0)

    var labelNode: SKLabelNode
    var shapeNode: SKShapeNode
    let cornerRadius: CGFloat = 10.0
    let maxWidth: CGFloat = 150
    let padding: CGFloat = 20.0
    
    var primaryText: String = "" {
        didSet {
            updateLabelNode()
        }
    }
    
    var secondaryText: String = "" {
        didSet {
            updateLabelNode()
        }
    }
    
    var callToActionText: String = "" {
        didSet {
            updateLabelNode()
        }
    }
    
    func updateLabelNode() {
        // 2020-07-10: As of today, SKLabelNode is not able to properly
        // center the text. Attributed string can workaround the issue
        let newline = "\n"
        
        var str: String = ""
        if primaryText.isEmpty {
            str = secondaryText
        } else {
            if !secondaryText.isEmpty {
                str = "\(secondaryText)\(newline)\(primaryText)"
            } else {
                str = primaryText
            }
        }
        
        if str.isEmpty {
            str = callToActionText
        } else {
            str = "\(str)\(newline)\(callToActionText)"
        }
        
        if !str.isEmpty {
            let attrString = NSMutableAttributedString(string: str)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            paragraphStyle.paragraphSpacing = 3
            
            var textLocation = 0
            
            // Secondary Text first
            if !secondaryText.isEmpty {
                let textRange = NSRange(location: textLocation, length: secondaryText.count)
                attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle,
                                        range: textRange)
                attrString.addAttributes([
                    NSAttributedString.Key.foregroundColor : Colors.secondaryText,
                    NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: .caption2)],
                    range: textRange)
                
                textLocation = textLocation + secondaryText.count + newline.count
            }
            
            // Primary Text next
            if !primaryText.isEmpty {
                let textRange = NSRange(location: textLocation, length: primaryText.count)
                attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle,
                                        range: textRange)
                attrString.addAttributes([
                    NSAttributedString.Key.foregroundColor : Colors.primaryText,
                    NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: .footnote)],
                    range: textRange)
                
                textLocation = textLocation + primaryText.count + newline.count
            }
            
            if !callToActionText.isEmpty {
                let textRange = NSRange(location: textLocation, length: callToActionText.count)
                attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle,
                                        range: textRange)
                attrString.addAttributes([
                    NSAttributedString.Key.foregroundColor : Colors.callToActionText,
                    NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: .footnote)],
                    range: textRange)
                
                textLocation = textLocation + callToActionText.count + newline.count
            }
        
            labelNode.attributedText = attrString
            updateShape()
        }
    }
        
    init(iconNamed: String? = nil) {
        
        labelNode = SKLabelNode()
        
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

        if let iconNamed = iconNamed {
            let texture = SKTexture(imageNamed: iconNamed)
            iconNode = SKSpriteNode(texture: texture, size: iconSize)
            iconNode?.zPosition = 1
            self.addChild(iconNode!)
        }
    }
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateShape() {
        self.removeChildren(in: [shapeNode])
        
        let iconWidth = (iconNode == nil) ? 0.0 : iconSize.width
        let iconHeight = (iconNode == nil) ? 0.0 : iconSize.height
        
        let buttonOrigin = CGPoint(x: -iconWidth, y: 0.0)
        let buttonSize = CGSize(width: labelNode.frame.size.width + (padding * 2) + iconWidth,
                                height: labelNode.frame.size.height + (padding * 2))
        let rect = CGRect(origin: buttonOrigin, size: buttonSize)
        shapeNode = SKShapeNode(rect: rect, cornerRadius: cornerRadius)
        shapeNode.fillColor =  Colors.labelFill
        shapeNode.strokeColor =  Colors.labelBorder
        self.addChild(shapeNode)

        iconNode?.position = CGPoint(x: 0.0, y: buttonSize.height - padding - (iconHeight * 0.5))
    }
}
