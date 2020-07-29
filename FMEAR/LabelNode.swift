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
    
    var labelNode: SKLabelNode
    var shapeNode: SKShapeNode
    let cornerRadius: CGFloat = 10.0
    let maxWidth: CGFloat = 150
    private(set) var size: CGSize = CGSize()
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
        
        let attrString = NSMutableAttributedString(string: str)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.paragraphSpacing = 3
        
        var textLocation = 0
        if !secondaryText.isEmpty {
            // Text
            let textRange = NSRange(location: 0, length: secondaryText.count)
            attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle,
                                    range: textRange)
            attrString.addAttributes([
                NSAttributedString.Key.foregroundColor : Colors.secondaryText,
                NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: .caption2)],
                range: textRange)
        }
        
        if !primaryText.isEmpty {
            if !secondaryText.isEmpty {
                textLocation = secondaryText.count + newline.count
            } else {
                textLocation = secondaryText.count
            }
        
            // Secondary Text
            let secondaryTextRange = NSRange(location: textLocation, length: primaryText.count)
            attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle,
                                    range: secondaryTextRange)
            attrString.addAttributes([
                NSAttributedString.Key.foregroundColor : Colors.primaryText,
                NSAttributedString.Key.font : UIFont.preferredFont(forTextStyle: .footnote)],
                range: secondaryTextRange)
        }
        
        labelNode.attributedText = attrString
        updateShape()
    }
        
    override init() {
        
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
        shapeNode.fillColor =  Colors.labelFill
        shapeNode.strokeColor =  Colors.labelBorder
        self.addChild(shapeNode)
        
        self.size = calculateAccumulatedFrame().size
    }
}
