//
//  Compass.swift
//  FMEAR
//
//  Created by Angus Lau on 2020-08-19.
//  Copyright © 2020 Safe Software Inc. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

class Compass: SKNode {
    
    let size = CGSize(width: 100.0, height: 100.0)
    private var outerRing: SKShapeNode!
    private var innerRing: SKShapeNode!
    private var northLabel: SKLabelNode!
    private var indicator: SKShapeNode!
    private var imageNode: SKSpriteNode!
    
    private var axes: SKNode!

    var image: UIImage? {
        didSet {
            if let image = image {
                let texture = SKTexture(image: image)
                imageNode.texture = texture
            } else {
                imageNode.texture = nil
            }
        }
    }
    
    var imageRotation: CGFloat = 0.0 {
        didSet {
            if imageNode.zRotation != imageRotation {
                if imageRotation == 0.0 {
                    indicator.strokeColor = outerRing.strokeColor
                    
                    let impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .light)
                    impactFeedbackgenerator.prepare()
                    impactFeedbackgenerator.impactOccurred()
                } else {
                    indicator.strokeColor = .clear
                }
                
                imageNode.zRotation = imageRotation
                axes.zRotation = imageRotation
            }
        }
    }

    override init() {
        super.init()
        
        outerRing = SKShapeNode(ellipseOf: size)
        outerRing.fillColor = DesignSystem.Colour.NeutralPalette.offWhite.withAlphaComponent(0.4)
        self.addChild(outerRing)
        
        let innerSize = CGSize(width: size.width * 0.8, height: size.height * 0.8)
        innerRing = SKShapeNode(ellipseOf: innerSize)
        innerRing.fillColor = .clear
        self.addChild(innerRing)
        
        // TODO: Localize "N"
        northLabel = SKLabelNode(text: "N")
        northLabel.fontSize = 14
        northLabel.fontName = "Verdana-Bold"
        northLabel.position = CGPoint(x: 0.0, y: 45)
        northLabel.verticalAlignmentMode = .center
        northLabel.horizontalAlignmentMode = .center
        self.addChild(northLabel)
        
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 4.0, y: 30.0))
        path.addLine(to: CGPoint(x: 0.0, y: 36.0))
        path.addLine(to: CGPoint(x: -4.0, y: 30.0))
        path.addLine(to: CGPoint(x: 4.0, y: 30.0))
        indicator = SKShapeNode(path: path)
        indicator.fillColor = DesignSystem.Colour.SemanticPalette.redLight10
        indicator.strokeColor = outerRing.strokeColor
        indicator.zPosition = 2
        self.addChild(indicator)

        // We want to calculate the image size within the inner circle. We know the
        // length of the square in the inner circle is innerSize.width / sqrt(2), but
        // we don't have to do the sqrt since we don't really need an exact size in the
        // circle. A slightly smaller image size is good. Square root of 2 is about 1.41.
        // If we use 1.5, then the image can be not touching the inner circle.
        let imageSize = innerSize.width / 1.5
        imageNode = SKSpriteNode()

        imageNode.size = CGSize(width: imageSize, height: imageSize)
        self.addChild(imageNode)
        
        axes = SKNode()
        self.addChild(axes)
        let axisLength = 28.0
        let southPath = CGMutablePath()
        southPath.move(to: CGPoint(x: 0.0, y: 0.0))
        southPath.addLine(to: CGPoint(x: 0.0, y: -axisLength))
        let southAxis = SKShapeNode(path: southPath)
        southAxis.strokeColor = DesignSystem.Colour.NeutralPalette.grey.withAlphaComponent(0.5)
        southAxis.zPosition = 1
        southAxis.lineWidth = 2
        axes.addChild(southAxis)

        let westPath = CGMutablePath()
        westPath.move(to: CGPoint(x: 0.0, y: 0.0))
        westPath.addLine(to: CGPoint(x: -axisLength, y: 0.0))
        let westAxis = SKShapeNode(path: westPath)
        westAxis.strokeColor = DesignSystem.Colour.NeutralPalette.grey.withAlphaComponent(0.5)
        westAxis.zPosition = 1
        westAxis.lineWidth = 2
        axes.addChild(westAxis)

        let northPath = CGMutablePath()
        northPath.move(to: CGPoint(x: 0.0, y: 0.0))
        northPath.addLine(to: CGPoint(x: 0.0, y: axisLength))
        let northAxis = SKShapeNode(path: northPath)
        northAxis.strokeColor = DesignSystem.Colour.SemanticPalette.greenLight10.withAlphaComponent(0.8)
        northAxis.zPosition = 1
        northAxis.lineWidth = 2
        axes.addChild(northAxis)
        
        let eastPath = CGMutablePath()
        eastPath.move(to: CGPoint(x: 0.0, y: 0.0))
        eastPath.addLine(to: CGPoint(x: axisLength, y: 0.0))
        let eastAxis = SKShapeNode(path: eastPath)
        eastAxis.strokeColor = DesignSystem.Colour.SemanticPalette.redLight10.withAlphaComponent(0.8)
        eastAxis.zPosition = 1
        eastAxis.lineWidth = 2
        axes.addChild(eastAxis)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
