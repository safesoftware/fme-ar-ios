/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Manages two finger gesture interactions with the AR scene.
*/

import ARKit
import SceneKit

/// - Tag: TwoFingerGesture
class TwoFingerGesture: Gesture {
    
    // MARK: - Properties
    
    var firstTouch = UITouch()
    var secondTouch = UITouch()
    
    let translationThreshold: CGFloat = 40
    let translationThresholdHarder: CGFloat = 70
    var translationThresholdPassed = false
    var allowTranslation = false
    var dragOffset = CGPoint()
    var initialMidPoint = CGPoint(x: 0, y: 0)
    
    let rotationThreshold: Float = .pi / 60 // (3°)
    let rotationThresholdHarder: Float = .pi / 30 // 6°)
    let snapThreshold: Float = .pi / 60 // (6° = +/- 3°)
    var rotationThresholdPassed = false
    var allowRotation = false
    var initialFingerAngle: Float = 0
    var initialObjectAngle: Float = 0
    var firstTouchedObject: VirtualObject?
    
    let scaleThreshold: CGFloat = 50
    let scaleThresholdHarder: CGFloat = 90
    var scaleThresholdPassed = false
    var allowScaling = false
    var initialDistanceBetweenFingers: CGFloat = 0
    var baseDistanceBetweenFingers: CGFloat = 0
    var objectBaseScale: Float = 1.0
    
    // MARK: - Initialization
    
    override init(_ touches: Set<UITouch>, _ sceneView: ARSCNView, _ lastUsedObject: VirtualObject?, _ objectManager: VirtualObjectManager) {
        super.init(touches, sceneView, lastUsedObject, objectManager)
        let touches = Array(touches)
        firstTouch = touches[0]
        secondTouch = touches[1]
        
        let firstTouchPoint = firstTouch.location(in: sceneView)
        let secondTouchPoint = secondTouch.location(in: sceneView)
        initialMidPoint = firstTouchPoint.midpoint(secondTouchPoint)
        
        // Compute the two other corners of the rectangle defined by the two fingers
        let thirdCorner = CGPoint(x: firstTouchPoint.x, y: secondTouchPoint.y)
        let fourthCorner = CGPoint(x: secondTouchPoint.x, y: firstTouchPoint.y)
        
        // Compute all midpoints between the corners and center of the rectangle.
        let midPoints = [
            thirdCorner.midpoint(firstTouchPoint),
            thirdCorner.midpoint(secondTouchPoint),
            fourthCorner.midpoint(firstTouchPoint),
            fourthCorner.midpoint(secondTouchPoint),
            initialMidPoint.midpoint(firstTouchPoint),
            initialMidPoint.midpoint(secondTouchPoint),
            initialMidPoint.midpoint(thirdCorner),
            initialMidPoint.midpoint(fourthCorner)
        ]
        
        // Check if any of the two fingers or their midpoint is touching the object.
        // Based on that, translation, rotation and scale will be enabled or disabled.
        let allPoints = [firstTouchPoint, secondTouchPoint, thirdCorner, fourthCorner, initialMidPoint] + midPoints
        firstTouchedObject = allPoints.lazy.compactMap { point in
            return self.virtualObject(at: point)
        }.first
        if let virtualObject = firstTouchedObject {
            objectBaseScale = virtualObject.scale.x
            
            allowTranslation = true
            allowRotation = true
            allowScaling = objectManager.allowScaling

            initialDistanceBetweenFingers = (firstTouchPoint - secondTouchPoint).length()
            
            initialFingerAngle = atan2(Float(initialMidPoint.x), Float(initialMidPoint.y))
            initialObjectAngle = virtualObject.eulerAngles.y
            
        } else {
            allowTranslation = false
            allowRotation = false
            allowScaling = false
        }
    }
    
    // MARK: - Gesture Handling
    
    override func updateGesture() {
        super.updateGesture()
        
        guard let virtualObject = firstTouchedObject else {
            return
        }
        
        // Two finger touch enables combined translation, rotation and scale.
        
        // First: Update the touches.
        let touches = Array(currentTouches)
        let newTouch1 = touches[0]
        let newTouch2 = touches[1]
        
        if newTouch1 == firstTouch {
            firstTouch = newTouch1
            secondTouch = newTouch2
        } else {
            firstTouch = newTouch2
            secondTouch = newTouch1
        }
        
        let loc1 = firstTouch.location(in: sceneView)
        let loc2 = secondTouch.location(in: sceneView)
        
        if allowTranslation {
            // 1. Translation using the midpoint between the two fingers.
            updateTranslation(of: virtualObject, midpoint: loc1.midpoint(loc2))
        }
        
        let spanBetweenTouches = loc1 - loc2
        if allowRotation {
            // 2. Rotation based on the relative rotation of the fingers on a unit circle.
            updateRotation(of: virtualObject, span: spanBetweenTouches)
        }
        if allowScaling {
            // 3. Scale based on the distance between the fingers relative to initial distance.
            updateScaling(of: virtualObject, span: spanBetweenTouches)
        }
    }
    
    func updateTranslation(of virtualObject: VirtualObject, midpoint: CGPoint) {
        if !translationThresholdPassed {
            
            let initialLocationToCurrentLocation = midpoint - initialMidPoint
            let distanceFromStartLocation = initialLocationToCurrentLocation.length()
            
            // Check if the translate gesture has crossed the threshold.
            // If the user is already rotating and or scaling we use a bigger threshold.
            
            var threshold = translationThreshold
            if rotationThresholdPassed || scaleThresholdPassed {
                threshold = translationThresholdHarder
            }
            
            if distanceFromStartLocation >= threshold {
                translationThresholdPassed = true
                
                let currentObjectLocation = CGPoint(sceneView.projectPoint(virtualObject.position))
                dragOffset = midpoint - currentObjectLocation
            }
        }
        
        if translationThresholdPassed {
            let offsetPos = midpoint - dragOffset
            objectManager.translate(virtualObject, in: sceneView, basedOn: offsetPos, instantly: false, infinitePlane: true)
            lastUsedObject = virtualObject
        }
    }
    
    func updateRotation(of virtualObject: VirtualObject, span: CGPoint) {
        let midpointToFirstTouch = span / 2
        let currentAngle = atan2(Float(midpointToFirstTouch.x), Float(midpointToFirstTouch.y))
        var currentAngleToInitialFingerAngle = initialFingerAngle - currentAngle
        
        var threshold : Float = rotationThreshold
        if translationThresholdPassed || scaleThresholdPassed {
            threshold = rotationThresholdHarder
        }
        
        if !rotationThresholdPassed {
            
            if abs(currentAngleToInitialFingerAngle) > threshold {
                
                // The angle change is larger than the threshold. We will start
                // the rotation. We need to reset the initialFingerAngle and the
                // currentAngleToInitialFingerAngle to prevent a sudden jump
                // after crossing the threshold
                
                rotationThresholdPassed = true
                initialFingerAngle = currentAngle
                
                if currentAngleToInitialFingerAngle > 0 {
                    currentAngleToInitialFingerAngle = threshold
                } else {
                    currentAngleToInitialFingerAngle = -threshold
                }
            }
        }
        
        if rotationThresholdPassed {
            // Note:
            // For looking down on the object (99% of all use cases), we need to subtract the angle.
            // To make rotation also work correctly when looking from below the object one would have to
            // flip the sign of the angle depending on whether the object is above or below the camera...
    
            // Calculate the delta angle change
            var deltaAngle : Float = 0
            if currentAngleToInitialFingerAngle > 0 {
                deltaAngle = max(0, currentAngleToInitialFingerAngle - threshold)
            } else {
                deltaAngle = min(0, currentAngleToInitialFingerAngle + threshold)
            }
            
            // Update the yaw angle. We want to snap the model to 0.0 if it's close enough
            var newAngle = (initialObjectAngle - deltaAngle).remainder(dividingBy: Float.pi * 2)
            if abs(newAngle) < snapThreshold {
                newAngle = 0.0
            }
            
            virtualObject.eulerAngles.y = newAngle
            lastUsedObject = virtualObject
        }
    }
    
    
    func updateScaling(of virtualObject: VirtualObject, span: CGPoint) {
        let distanceBetweenFingers = span.length()
        
        if !scaleThresholdPassed {
            
            let fingerSpread = abs(distanceBetweenFingers - initialDistanceBetweenFingers)
            
            var threshold = scaleThreshold
            
            if translationThresholdPassed || rotationThresholdPassed {
                threshold = scaleThresholdHarder
            }
            
            if fingerSpread > threshold {
                scaleThresholdPassed = true
                baseDistanceBetweenFingers = distanceBetweenFingers
            }
        }
        
        if scaleThresholdPassed {
            if baseDistanceBetweenFingers != 0 {
                let relativeScale = distanceBetweenFingers / baseDistanceBetweenFingers
                let newScale = objectBaseScale * Float(relativeScale)
                
                // Uncomment the block below to "snap" the 3D model to 100%.
                /*
                 if newScale >= 0.96 && newScale <= 1.04 {
                 newScale = 1.0 // Snap scale to 100% when getting close.
                 }*/
                
                virtualObject.simdScale = SIMD3<Float>(repeating: newScale)
                lastUsedObject = virtualObject
                
//                ViewController.serialQueue.async {
                    if let nodeWhichReactsToScale = virtualObject.reactsToScale() {
                        nodeWhichReactsToScale.reactToScale()
                    }
   //             }
            }
        }
    }
    
    func finishGesture() {
        // Nothing to do here for two finger gestures.
    }
}

