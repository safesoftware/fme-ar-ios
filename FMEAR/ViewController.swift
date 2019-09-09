/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Main view controller for the AR experience.
*/

import ARKit
import SceneKit
import UIKit

class ViewController: UIViewController, ARSessionDelegate {
    
    var document: UIDocument?
    var documentOpened = false
    var modelPath: URL?
    var lights = [SCNLight]()
    var lightIntensity: CGFloat = 1000
    var lightTemperature: CGFloat = 6500
    var planes = [ARPlaneAnchor: Plane]()
    
    // MARK: - ARKit Config Properties
    
    var screenCenter: CGPoint?

    let session = ARSession()
    let standardConfiguration: ARWorldTrackingConfiguration = {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.isLightEstimationEnabled = true
        return configuration
    }()
    
    // MARK: - Virtual Object Manipulation Properties
    
    //var dragOnInfinitePlanesEnabled = false
    var virtualObjectManager: VirtualObjectManager!
    
    var isLoadingObject: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.settingsButton.isEnabled = !self.isLoadingObject
                self.showAssetsButton.isEnabled = !self.isLoadingObject
                self.restartExperienceButton.isEnabled = !self.isLoadingObject
            }
        }
    }
    
    // MARK: - Other Properties
    
    var textManager: TextManager!
    var restartExperienceButtonIsEnabled = true
    
    // MARK: - UI Elements
    
    var spinner: UIActivityIndicatorView?
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var messagePanel: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var showAssetsButton: UIButton!
    @IBOutlet weak var showScaleOptionsButton: UIButton!
    @IBOutlet weak var restartExperienceButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    // Indicators to show the direction to the model when the model
    // is outside the screen area.
    @IBOutlet weak var modelIndicatorUp: UILabel!
    @IBOutlet weak var modelIndicatorDown: UILabel!
    @IBOutlet weak var modelIndicatorLeft: UILabel!
    @IBOutlet weak var modelIndicatorRight: UILabel!
    
    
    // MARK: - Queues
    
	let serialQueue = DispatchQueue(label: "com.apple.arkitexample.serialSceneKitQueue")
	
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Setting.registerDefaults()
		setupUIControls()
        setupScene()
    }

    func currentScale() -> Float {
        if let virtualObjectNode = self.sceneView.scene.rootNode.childNode(withName: "VirtualObject", recursively: true) {
            return virtualObjectNode.scale.x
        } else {
            return 1.0
        }
    }
    
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		// Prevent the screen from being dimmed after a while.
		UIApplication.shared.isIdleTimerDisabled = true
		
		if ARWorldTrackingConfiguration.isSupported {
			// Start the ARSession.
			resetTracking()
		} else {
			// This device does not support 6DOF world tracking.
			let sessionErrorMsg = "This app requires world tracking. World tracking is only available on iOS devices with A9 processor or newer. " +
			"Please quit the application."
			displayErrorMessage(title: "Unsupported platform", message: sessionErrorMsg, allowRestart: false)
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		session.pause()
        
        print("viewWillDisappear")
        if let document = self.document {
            closeDocument(document: document)
        }
	}
	
    // MARK: - Setup

    func createLightNode(type: SCNLight.LightType, position: SCNVector3 = SCNVector3(0,0,0), intensity: CGFloat = 1000) -> SCNNode {
        let light = SCNLight()
        light.type = type
        light.intensity = intensity
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = position
        lights.append(light)
        return lightNode
    }
    
    func setupLighting() {
        
        // Ambient light
        sceneView.scene.rootNode.addChildNode(createLightNode(type: .ambient,
                                                              position: SCNVector3(0.0, 0.0, 0.0),
                                                              intensity: lightIntensity))

        // Directional lights
        for position in [SCNVector3(-2, 0, 0), SCNVector3(2, 0, 0), SCNVector3(0, 0, -2), SCNVector3(0, 0, 2)] {
            let node = createLightNode(type: .directional, position: position, intensity: lightIntensity)
            sceneView.scene.rootNode.addChildNode(node)
        }
    }
    
	func setupScene() {
        // Synchronize updates via the `serialQueue`.
        virtualObjectManager = VirtualObjectManager(updateQueue: serialQueue)
        virtualObjectManager.delegate = self
		
		// set up scene view
		sceneView.setup()
		sceneView.delegate = self
		sceneView.session = session
		sceneView.showsStatistics = false
        setupLighting()
        session.delegate = self
		
        
        
		//sceneView.scene.enableEnvironmentMapWithIntensity(25, queue: serialQueue)
        
        
		
        // Debug visualizations
//        sceneView.debugOptions =  [
//            SCNDebugOptions.showBoundingBoxes,
//            SCNDebugOptions.showWireframe,
//            SCNDebugOptions.showLightExtents,
//            ARSCNDebugOptions.showWorldOrigin,
//            ARSCNDebugOptions.showFeaturePoints
//        ]
        
		setupFocusSquare()
		
		DispatchQueue.main.async {
			self.screenCenter = self.sceneView.bounds.mid
		}
	}
    
    func setupUIControls() {
        textManager = TextManager(viewController: self)
        
        // Set appearance of message output panel
        messagePanel.layer.cornerRadius = 3.0
        messagePanel.clipsToBounds = true
        messagePanel.isHidden = true
        messageLabel.text = ""
    }
	
    // MARK: - Gesture Recognizers
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		virtualObjectManager.reactToTouchesBegan(touches, with: event, in: self.sceneView)
        
        let location = touches.first!.location(in: sceneView)
        let hitResultsFeaturePoints: [ARHitTestResult] =
            sceneView.hitTest(location, types: .featurePoint)
        if let hit = hitResultsFeaturePoints.first {
            sceneView.session.add(anchor: ARAnchor(transform: hit.worldTransform))
        }
        
        for result in hitResultsFeaturePoints {
            print("hit result = \(result)")
        }
        
        let hitResults = sceneView.hitTest(location, options: nil)
        for result in hitResults {
            logSCNHitTestResult(result)
        }
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		virtualObjectManager.reactToTouchesMoved(touches, with: event)
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        let location = touches.first!.location(in: sceneView)
//        if addObjectButton.point(inside: location, with: nil) {
//            chooseObject(addObjectButton)
//            return
//        }
        
		virtualObjectManager.reactToTouchesEnded(touches, with: event)
	}
	
	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		virtualObjectManager.reactToTouchesCancelled(touches, with: event)
	}
	
    // MARK: - Planes
    func addPlane(node: SCNNode, anchor: ARPlaneAnchor) {
        
        // Create a custom object to visualize the plane geometry and extent.
        let plane = Plane(anchor: anchor, in: sceneView)
        
        // Remember the anchor and the node
        planes[anchor] = plane

        // Initial visibility of the plane
        plane.isHidden = !(UserDefaults.standard.bool(for: .drawDetectedPlane))
        
        // Add the visualization to the ARKit-managed node so that it tracks
        // changes in the plane anchor as plane estimation continues.
        node.addChildNode(plane)
        
		textManager.cancelScheduledMessage(forType: .planeEstimation)
		textManager.showMessage("SURFACE DETECTED")

        if let document = self.document {
            if !documentOpened {
                openDocument(document: document)
                documentOpened = true
            }
        }

//        if virtualObjectManager.virtualObjects.isEmpty {
//            textManager.scheduleMessage("TAP + TO PLACE AN OBJECT", inSeconds: 7.5, messageType: .contentPlacement)
//        }
	}
		
    func updatePlane(node: SCNNode, anchor: ARPlaneAnchor) {
        // Update only anchors and nodes set up by `renderer(_:didAdd:for:)`.
        guard let plane = node.childNodes.first as? Plane else {
            return
        }
        
        // Update ARSCNPlaneGeometry to the anchor's new estimated shape.
        if let planeGeometry = plane.meshNode.geometry as? ARSCNPlaneGeometry {
            planeGeometry.update(from: anchor.geometry)
        }
        
        // Update extent visualization to the anchor's new bounding rectangle.
        if let extentGeometry = plane.extentNode.geometry as? SCNPlane {
            extentGeometry.width = CGFloat(anchor.extent.x)
            extentGeometry.height = CGFloat(anchor.extent.z)
            plane.extentNode.simdPosition = anchor.center
        }
        
//        // Update the plane's classification and the text position
//        if #available(iOS 12.0, *),
//            let classificationNode = plane.classificationNode,
//            let classificationGeometry = classificationNode.geometry as? SCNText {
//            let currentClassification = anchor.classification.description
//            if let oldClassification = classificationGeometry.string as? String, oldClassification != currentClassification {
//                classificationGeometry.string = currentClassification
//                classificationNode.centerAlign()
//            }
//        }
	}
    
    func removePlane(node: SCNNode, anchor: ARPlaneAnchor) {
        planes.removeValue(forKey: anchor)
    }
	
	func resetTracking() {
		session.run(standardConfiguration, options: [.resetTracking, .removeExistingAnchors])
		
		textManager.scheduleMessage("FIND A SURFACE TO PLACE AN OBJECT",
		                            inSeconds: 7.5,
		                            messageType: .planeEstimation)
	}

    // MARK: - Focus Square
    
    var focusSquare: FocusSquare?
	
    func setupFocusSquare() {
		serialQueue.async {
			self.focusSquare?.isHidden = true
			self.focusSquare?.removeFromParentNode()
			self.focusSquare = FocusSquare()
			self.sceneView.scene.rootNode.addChildNode(self.focusSquare!)
		}
		
		textManager.scheduleMessage("TRY MOVING LEFT OR RIGHT", inSeconds: 5.0, messageType: .focusSquare)
    }
	
	func updateFocusSquare() {
		guard let screenCenter = screenCenter else { return }
		
		DispatchQueue.main.async {
			var objectVisible = false
			for object in self.virtualObjectManager.virtualObjects {
				if self.sceneView.isNode(object, insideFrustumOf: self.sceneView.pointOfView!) {
					objectVisible = true
					break
				}
			}
			
			if objectVisible {
				self.focusSquare?.hide()
			} else {
				self.focusSquare?.unhide()
			}
			
            let (worldPos, planeAnchor, _) = self.virtualObjectManager.worldPositionFromScreenPosition(screenCenter,
                                                                                                       in: self.sceneView,
                                                                                                       objectPos: self.focusSquare?.simdPosition)
			if let worldPos = worldPos {
				self.serialQueue.async {
					self.focusSquare?.update(for: worldPos, planeAnchor: planeAnchor, camera: self.session.currentFrame?.camera)
				}
				self.textManager.cancelScheduledMessage(forType: .focusSquare)
			}
		}
	}
    
	// MARK: - Error handling
	
	func displayErrorMessage(title: String, message: String, allowRestart: Bool = false) {
		// Blur the background.
		textManager.blurBackground()
		
		if allowRestart {
			// Present an alert informing about the error that has occurred.
			let restartAction = UIAlertAction(title: "Reset", style: .default) { _ in
				self.textManager.unblurBackground()
				self.restartExperience(self)
			}
			textManager.showAlert(title: title, message: message, actions: [restartAction])
		} else {
			textManager.showAlert(title: title, message: message, actions: [])
		}
	}
    
    // MARK: - ARSessionDelegate
    
    func session(_ session : ARSession, didUpdate frame: ARFrame) {
        
        if let path = modelPath {
            loadModel(path: path)
        }
        
    }
    
    // MARK: - Log
    
    func logSCNHitTestResult(_ result: SCNHitTestResult) {
        print("SCNHitTestResult: node = \(result.node)")
        print("SCNHitTestResult: geometryIndex = \(result.geometryIndex)")
        print("SCNHitTestResult: faceIndex = \(result.faceIndex)")
    }
}
