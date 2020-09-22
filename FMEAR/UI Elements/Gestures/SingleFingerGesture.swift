/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Manages single finger gesture interactions with the AR scene.
*/

import ARKit
import SceneKit

class SingleFingerGesture: Gesture {
    
    // MARK: - Properties
    
    var initialTouchLocation = CGPoint()
    var latestTouchLocation = CGPoint()
    
    var firstTouchedObject: VirtualObject?

    let translationThreshold: CGFloat = 30
    var translationThresholdPassed = false
    var hasMovedObject = false
    
    var dragOffset = CGPoint()
    
    // MARK: - Initialization
    
    override init(_ touches: Set<UITouch>, _ sceneView: ARSCNView, _ lastUsedObject: VirtualObject?, _ objectManager: VirtualObjectManager) {
        super.init(touches, sceneView, lastUsedObject, objectManager)
        
        let touch = currentTouches.first!
        initialTouchLocation = touch.location(in: sceneView)
        latestTouchLocation = initialTouchLocation
        
        firstTouchedObject = virtualObject(at: initialTouchLocation)
    }
    
    // MARK: - Gesture Handling
    
    override func updateGesture() {
        super.updateGesture()
        
        guard let virtualObject = firstTouchedObject else {
            return
        }
        
        latestTouchLocation = currentTouches.first!.location(in: sceneView)
        
        objectManager.translate(
            virtualObject,
            in: sceneView,
            screenStartPos: initialTouchLocation,
            screenEndPos: latestTouchLocation,
            instantly: false,
            infinitePlane: true)
        hasMovedObject = true
        lastUsedObject = virtualObject
        initialTouchLocation = latestTouchLocation

//        let initialLocationToCurrentLocation = latestTouchLocation - initialTouchLocation
//        let distanceFromStartLocation = initialLocationToCurrentLocation.length()
//        if !translationThresholdPassed {
//
//            if distanceFromStartLocation >= translationThreshold {
//                translationThresholdPassed = true
//                
//                let currentObjectLocation = CGPoint(sceneView.projectPoint(virtualObject.position))
//                dragOffset = latestTouchLocation - currentObjectLocation
//                print("new dragOffset = \(dragOffset)")
//            }
//        }
//        
//        // A single finger drag will occur if the drag started on the object and the threshold has been passed.
//        if translationThresholdPassed {
//            print("dragOffset = \(dragOffset)")
//            print("latestTouchLocation = \(latestTouchLocation)")
//            let offsetPos = latestTouchLocation - dragOffset
//            print("translate: \(offsetPos)")
//            objectManager.translate(virtualObject, in: sceneView, basedOn: offsetPos, instantly: false, infinitePlane: true)
//            hasMovedObject = true
//            lastUsedObject = virtualObject
//        }
    }
    
    func finishGesture() {
        // Single finger touch allows teleporting the object or interacting with it.
        
        // Do not do anything if this gesture is being finished because
        // another finger has started touching the screen.
        if currentTouches.count > 1 {
            return
        }
        
        // Do not do anything either if the touch has dragged the object around.
        if hasMovedObject {
            return
        }
        
        if lastUsedObject != nil {
            // If this gesture hasn't moved the object then perform a hit test against
            // the geometry to check if the user has tapped the object itself.
            // - Note: If the object covers a significant
            // percentage of the screen then we should interpret the tap as repositioning
            // the object.
            let isObjectHit = virtualObject(at: latestTouchLocation) != nil
            
            if !isObjectHit {
                // Teleport the object to whereever the user touched the screen - as long as the
                // drag threshold has not been reached.
                if !translationThresholdPassed {
                    objectManager.translate(lastUsedObject!, in: sceneView, basedOn: latestTouchLocation, instantly: true, infinitePlane: false)
                }
            }
        }
    }
    
}
