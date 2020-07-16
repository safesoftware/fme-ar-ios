/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Wrapper SceneKit node for virtual objects placed into the AR scene.
*/

import Foundation
import SceneKit
import ARKit

struct Asset: Codable, Equatable, Comparable {
    var name: String
    var selected: Bool
    
    init(name: String, selected: Bool) {
        self.name = name
        self.selected = selected
    }
    
    static func ==(lhs: Asset, rhs: Asset) -> Bool {
        return lhs.name == rhs.name
            && lhs.selected == rhs.selected
    }
    
    static func <(lhs: Asset, rhs: Asset) -> Bool {
        return lhs.name < rhs.name
    }
}

struct VirtualObjectDefinition: Codable, Equatable {
    let modelName: String
    let displayName: String
    let particleScaleInfo: [String: Float]
    
    lazy var thumbImage: UIImage = UIImage(named: self.modelName)!
    
    init(modelName: String, displayName: String, particleScaleInfo: [String: Float] = [:]) {
        self.modelName = modelName
        self.displayName = displayName
        self.particleScaleInfo = particleScaleInfo
    }
    
    static func ==(lhs: VirtualObjectDefinition, rhs: VirtualObjectDefinition) -> Bool {
        return lhs.modelName == rhs.modelName
            && lhs.displayName == rhs.displayName
            && lhs.particleScaleInfo == rhs.particleScaleInfo
    }
}

class VirtualObject: SCNReferenceNode, ReactsToScale {
    
    static let viewpointParentNodeName = "Viewpoints"
    
    let definition: VirtualObjectDefinition
    var viewpoints: [Viewpoint]
    let modelNode: SCNNode?
    var currentViewpoint: UUID?
    let currentViewpointMarker: SCNNode? = nil
    var viewpointNodes: [UUID:SCNNode] = [:]
    
    init(definition: VirtualObjectDefinition) {
        self.definition = definition
        self.modelNode = nil
        self.viewpoints = []
        self.currentViewpoint = nil
        
        if let url = Bundle.main.url(forResource: "SceneAssets.scnassets/\(definition.modelName)/\(definition.modelName)", withExtension: "scn") {
            super.init(url: url)!
        } else if let url = Bundle.main.url(forResource: "IfcProject.scnassets/\(definition.modelName)", withExtension: "dae") {
            super.init(url: url)!
        }
        else {
            fatalError("can't find expected virtual object bundle resources") }
    }
    
    init(definition: VirtualObjectDefinition,
         modelNode: SCNNode,
         viewpoints: [Viewpoint]) {
        self.definition = definition
        self.modelNode = modelNode
        self.viewpoints = viewpoints
        self.currentViewpoint = nil
        
        if let url = Bundle.main.url(forResource: "SceneAssets.scnassets/model/model", withExtension: "scn") {
            super.init(url: url)!
            addChildNode(modelNode)
            
            
        }
        else {
            fatalError("can't find expected virtual object bundle resources")
        }
        
        initViewpointNodes(modelNode: modelNode, viewpoints: viewpoints)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Use average of recent virtual object distances to avoid rapid changes in object scale.
    var recentVirtualObjectDistances = [Float]()
    
    func reactToScale() {
        for (nodeName, particleSize) in definition.particleScaleInfo {
            guard let node = self.childNode(withName: nodeName, recursively: true), let particleSystem = node.particleSystems?.first
                else { continue }
            particleSystem.reset()
            particleSystem.particleSize = CGFloat(scale.x * particleSize)
        }
    }
    
    func containsViewpoint(id: UUID) -> Bool {
        return viewpointNodes[id] != nil;
    }
    
    func viewpoint(id: UUID) -> Viewpoint? {
        for viewpoint in viewpoints {
            if viewpoint.id == id {
                return viewpoint
            }
        }
        
        return nil
    }
    
    // The position is in FME coordinate system, i.e. y is the elevation
    func anchorAt(position: SCNVector3) {
        // The FME coordinate z axis = ARKit y axis
        // The FME coordinate y axis = ARKit -z axis
        // We need to offset/subtract the position from the model position to
        // make the position appear as the center of the anchor.
        modelNode?.position = SCNVector3Make(-position.x, -position.z, position.y)
        currentViewpoint = nil
    }
    
    // This function initializes the viewpoint scene nodes and adds them to
    // the model node as child nodes. We add the invisible viewpoint nodes
    // so that the location of the viewpoints can be transformed together
    // with the model node.
    func initViewpointNodes(modelNode: SCNNode, viewpoints: [Viewpoint]) {
        if viewpoints.isEmpty {
            return
        }
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        let geometry = SCNSphere(radius: 1.0)
        geometry.firstMaterial = material

        let viewpointParentNode = SCNNode()
        viewpointParentNode.name = VirtualObject.viewpointParentNodeName
        modelNode.addChildNode(viewpointParentNode)
        
        for viewpoint in viewpoints {
            if let position = viewpointPosition(viewpoint: viewpoint) {
                let node = SCNNode(geometry: geometry)
                node.name = viewpoint.id.uuidString
                node.simdPosition = SIMD3<Float>(x: position.x,
                                                 y: position.y,
                                                 z: position.z)
                viewpointNodes[viewpoint.id] = node
                viewpointParentNode.addChildNode(node)
                node.isHidden = !(UserDefaults.standard.bool(for: .drawAnchor))
            }
        }
    }
    
    // This function returns the position of the viewpoint relative to the
    // model
    func viewpointPosition(viewpoint: Viewpoint) -> SCNVector3? {
        if let modelNode = self.modelNode {
            let (minCoord, maxCoord) = modelNode.boundingBox
            let centerX = (minCoord.x + maxCoord.x) * 0.5
            let centerY = (minCoord.y + maxCoord.y) * 0.5
            let groundZ = 0.0
//            return SCNVector3Make(Float(viewpoint.x ?? Double(centerX)),
//                                  Float(viewpoint.z ?? groundZ),
//                                  -Float(viewpoint.y ?? Double(centerY)))
            return SCNVector3Make(Float(viewpoint.x ?? Double(centerX)),
                                  Float(viewpoint.y ?? Double(centerY)),
                                  Float(viewpoint.z ?? groundZ))
        } else {
            return nil
        }
    }

    // This function returns the world position of the viewpoint in the scene
    func viewpointWorldPosition(viewpointId: UUID) -> SCNVector3? {
        if let node = viewpointNodes[viewpointId] {
            return node.worldPosition
        } else {
            return nil
        }
    }
    
    func anchorAtViewpoint(viewpointId: UUID) {
        if let viewpoint = viewpoint(id: viewpointId) {
            if let position = viewpointPosition(viewpoint: viewpoint) {
                anchorAt(position: position)
                currentViewpoint = viewpoint.id
            }
        }
    }
}

extension VirtualObject {
	
	static func isNodePartOfVirtualObject(_ node: SCNNode) -> VirtualObject? {
		if let virtualObjectRoot = node as? VirtualObject {
			return virtualObjectRoot
		}
		
		if node.parent != nil {
			return isNodePartOfVirtualObject(node.parent!)
		}
		
		return nil
	}
    
}

// MARK: - Protocols for Virtual Objects

protocol ReactsToScale {
	func reactToScale()
}

extension SCNNode {
	
	func reactsToScale() -> ReactsToScale? {
		if let canReact = self as? ReactsToScale {
			return canReact
		}
		
		if parent != nil {
			return parent!.reactsToScale()
		}
		
		return nil
	}
}
