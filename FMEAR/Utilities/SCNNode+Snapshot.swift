//
//  SCNNode+Snapshot.swift
//  FMEAR
//
//  Created by Angus Lau on 2020-08-18.
//  Copyright © 2020 Safe Software Inc. All rights reserved.
//

import Foundation
import SceneKit

extension SCNNode {
    
    // This function doesn't work in an emulator
    func snapshot(size: CGSize) -> UIImage {
        
        // Create the scen with this node
        let scene = SCNScene()
        scene.rootNode.addChildNode(self)

        // Create bounding box node
        let (minBounds, maxBounds) = self.boundingBox
        let box = SCNBox(width: CGFloat(maxBounds.x - minBounds.x),
                        height: CGFloat(maxBounds.y - minBounds.y),
                        length: CGFloat(maxBounds.z - minBounds.z),
                        chamferRadius: 0.0)
        let material = SCNMaterial()
        material.diffuse.contents = DesignSystem.Colour.NeutralPalette.grey
        material.transparency = 0.1
        box.materials = [material]
        let boxNode = SCNNode(geometry: box)
        boxNode.position = SCNVector3((minBounds.x + maxBounds.x) * 0.5,
                                    (minBounds.y + maxBounds.y) * 0.5,
                                    (minBounds.z + maxBounds.z) * 0.5)
        scene.rootNode.addChildNode(boxNode)
        
//        if axes {
//            let (center, radius) = self.boundingSphere
//            let (minBounds, maxBounds) = self.boundingBox
//            let length: CGFloat = CGFloat(max(maxBounds.x - minBounds.x, maxBounds.y - minBounds.y) * 0.4)
//            let capRadius = CGFloat(length) * 0.03
            

            
//            if radius > 0.0 {
//                let southPoleNode: SCNNode = {
//                    let capsule = SCNCapsule(capRadius: capRadius, height: length)
//                    let material = SCNMaterial()
//                    material.diffuse.contents = DesignSystem.Colour.NeutralPalette.grey
//                    material.transparency = 0.3
//                    capsule.materials = [material]
//                    let node = SCNNode(geometry: capsule)
//                    let position = SCNVector3(x: center.x, y: center.y - Float(capsule.height * 0.5), z: center.z + radius)
//                    node.position = position
//                    node.eulerAngles.z = Float.pi
//                    return node
//                }()
//                scene.rootNode.addChildNode(southPoleNode)
//
//                let westPoleNode: SCNNode = {
//                    let capsule = SCNCapsule(capRadius: capRadius, height: length)
//                    let material = SCNMaterial()
//                    material.diffuse.contents = DesignSystem.Colour.NeutralPalette.grey
//                    material.transparency = 0.3
//                    capsule.materials = [material]
//                    let node = SCNNode(geometry: capsule)
//                    let position = SCNVector3(x: center.x - Float(capsule.height * 0.5), y: center.y, z: center.z + radius)
//                    node.position = position
//                    node.eulerAngles.z = 270.0 * Float.pi / 180.0
//                    return node
//                }()
//                scene.rootNode.addChildNode(westPoleNode)
//
//                let northPoleNode: SCNNode = {
//                    let capsule = SCNCapsule(capRadius: capRadius, height: length)
//                    let material = SCNMaterial()
//                    material.diffuse.contents = DesignSystem.Colour.SemanticPalette.green
//                    capsule.materials = [material]
//                    let node = SCNNode(geometry: capsule)
//                    let position = SCNVector3(x: center.x, y: center.y + Float(capsule.height * 0.5), z: center.z + radius)
//                    node.position = position
//                    return node
//                }()
//                scene.rootNode.addChildNode(northPoleNode)
//
//                let eastPoleNode: SCNNode = {
//                    let capsule = SCNCapsule(capRadius: capRadius, height: length)
//                    let material = SCNMaterial()
//                    material.diffuse.contents = DesignSystem.Colour.SemanticPalette.redDark20
//                    capsule.materials = [material]
//                    let node = SCNNode(geometry: capsule)
//                    let position = SCNVector3(x: center.x + Float(capsule.height * 0.5), y: center.y, z: center.z + radius)
//                    node.position = position
//                    node.eulerAngles.z = 90.0 * Float.pi / 180.0
//                    return node
//                }()
//                scene.rootNode.addChildNode(eastPoleNode)
//            }
//        }
        
        // Light
        let omniLight = SCNLight()
        omniLight.type = .ambient
        let omniLightNode = SCNNode()
        omniLightNode.light = omniLight
        omniLightNode.position = SCNVector3Make(10, 10, 10)
        scene.rootNode.addChildNode(omniLightNode)
        
        
        // Create a renderer
        // This is nil in an emulator
        let renderer = SCNRenderer(device: MTLCreateSystemDefaultDevice(), options: nil)
        renderer.scene = scene

        // Render the image
        return renderer.snapshot(atTime: 0,
                               with: size,
                               antialiasingMode: SCNAntialiasingMode.multisampling4X)
    }
}
