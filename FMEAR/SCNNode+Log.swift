//
//  SCNNode+Log.swift
//  FMEAR
//
//  Created by Angus Lau on 2020-08-30.
//  Copyright © 2020 Safe Software Inc. All rights reserved.
//

import Foundation
import SceneKit

extension SCNNode {
    
    func log() {
        logSceneNode(self, level: 0)
    }
    
    
    func logSceneNode(_ sceneNode: SCNNode, level: Int) {

        let currentLevel = max(0 as Int, level)
        let indentation = String(repeating: "    ", count: currentLevel)
        let childIndentation = String(repeating: "    ", count: currentLevel + 1)
        
        if let name = sceneNode.name {
            print("\(indentation)SCNNode name: \(name)")
        } else {
            print("\(indentation)SCNNode name: <none>")
        }
        
        let (minCoord, maxCoord) = sceneNode.boundingBox
        print("\(childIndentation)boundingBox = '\(minCoord)', '\(maxCoord)'")
        
        if let geometry = sceneNode.geometry {
            print("\(childIndentation)geometry: \(geometry)")
            logGeometry(geometry, level: currentLevel + 2)
        } else {
            print("\(childIndentation)geometry: <none>")
        }
        
        for childNode in sceneNode.childNodes {
            logSceneNode(childNode, level: currentLevel + 1)
        }
    }
    
    func logGeometry(_ geometry: SCNGeometry, level: Int) {
        let currentLevel = max(0 as Int, level)
        let indentation = String(repeating: "    ", count: currentLevel)
        
        if let name = geometry.name {
            print("\(indentation)SCNGeometry name: \(name)")
        } else {
            print("\(indentation)SCNGeometry name: <none>")
        }
        
        print("\(indentation)Geometry Elements: \(geometry.elements.count)")
        for (index, geometryElement) in geometry.elements.enumerated() {
            logGeometryElement(geometryElement, level: currentLevel + 1, prefix: "\(index)")
        }
        
        print("\(indentation)Materials: \(geometry.materials.count)")
        for (index, material) in geometry.materials.enumerated() {
            logMaterial(material, level: currentLevel + 1, prefix: "\(index)")
        }
    }
    
    func logGeometryElement(_ element: SCNGeometryElement, level: Int, prefix: String) {
        let currentLevel = max(0 as Int, level)
        let indentation = String(repeating: "    ", count: currentLevel)

        print("\(indentation)\(prefix): \(element)")
    }
    
    func logMaterial(_ material: SCNMaterial, level: Int, prefix: String) {
        let currentLevel = max(0 as Int, level)
        let indentation = String(repeating: "    ", count: currentLevel)
        let childIndentation = String(repeating: "    ", count: currentLevel + 1)
        
        if let materialName = material.name {
            print("\(indentation)\(prefix): name: \(materialName)")
        } else {
            print("\(indentation)\(prefix): name: <none>")
        }
        
        print("\(childIndentation)lightingModel: \(material.lightingModel)")
        print("\(childIndentation)shininess: \(material.shininess)")
        print("\(childIndentation)fresnelExponent: \(material.fresnelExponent)")
        print("\(childIndentation)isLitPerPixel: \(material.isLitPerPixel)")
        print("\(childIndentation)isDoubleSided: \(material.isDoubleSided)")
        print("\(childIndentation)cullMode: \(material.cullMode)")
        print("\(childIndentation)blendMode: \(material.blendMode)")
        print("\(childIndentation)locksAmbientWithDiffuse: \(material.locksAmbientWithDiffuse)")
        print("\(childIndentation)writesToDepthBuffer: \(material.writesToDepthBuffer)")
        print("\(childIndentation)readsFromDepthBuffer: \(material.readsFromDepthBuffer)")
        print("\(childIndentation)colorBufferWriteMask: \(material.colorBufferWriteMask)")
        print("\(childIndentation)fillMode: \(material.fillMode)")
        print("\(childIndentation)transparency: \(material.transparency)")
        logMaterialProperty(material.transparent, level: currentLevel + 1, prefix: "transparent")
        logMaterialProperty(material.diffuse, level: currentLevel + 1, prefix: "diffuse")
        logMaterialProperty(material.specular, level: currentLevel + 1, prefix: "specular")
        logMaterialProperty(material.ambient, level: currentLevel + 1, prefix: "ambient")
        logMaterialProperty(material.ambientOcclusion, level: currentLevel + 1, prefix: "ambientOcclusion")
        logMaterialProperty(material.selfIllumination, level: currentLevel + 1, prefix: "selfIllumination")
        logMaterialProperty(material.metalness, level: currentLevel + 1, prefix: "metalness")
        logMaterialProperty(material.roughness, level: currentLevel + 1, prefix: "roughness")
        logMaterialProperty(material.displacement, level: currentLevel + 1, prefix: "displacement")
        logMaterialProperty(material.normal, level: currentLevel + 1, prefix: "normal")
        logMaterialProperty(material.reflective, level: currentLevel + 1, prefix: "reflective")
        logMaterialProperty(material.emission, level: currentLevel + 1, prefix: "emission")
        
    }
    
    func logMaterialProperty(_ materialProperty: SCNMaterialProperty, level: Int, prefix: String) {
        let currentLevel = max(0 as Int, level)
        let indentation = String(repeating: "    ", count: currentLevel)
        
        print("\(indentation)\(prefix): \(materialProperty)")
        
    }
}
