/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Main view controller for the AR experience.
*/

import ARKit
import SceneKit
import UIKit
import CoreLocation

struct Texts {
    static let moveModel = "Move model there"
    static let rescan = "Rescan location"
}

enum LabelIcons: String {
    case geolocationAnchor = "pin.circle"
    case viewpoint = "eye.circle"
    case information = "info.circle"
}

class ViewController: UIViewController, ARSessionDelegate, LocationServiceDelegate {
    
    let geomarkerLabelName = "Geomarker Label"
    let geomarkerNodeName = "Geomarker Node"
    let viewpointLabelName = "Viewpoint Label"
    
    // Datasets
    // When the dataset is ready to be added to the scene, we add the dataset url to
    // this array. When it's time to update the frame, we look at this array and add
    // the dataset model to the scene.
    var datasetsReady: [URL: Dataset] = [:]
    
    // The current reader that opens the current dataset
    var reader: FMEARReader?
    var datasets: [URL: Dataset] = [:]
    var errors: [Error] = []
    
    //var modelPath: URL?
    var lights = [SCNLight]()
    var lightIntensity: CGFloat = 1000
    var lightTemperature: CGFloat = 6500
    var planes = [ARPlaneAnchor: Plane]()
    
    // Cache the view bounds so that we don't need to access the view object
    // in the main thread all the time. This help avoiding using
    // DispatchQueue.main.async. However, we should keep viewBounds up to
    // date when the view has a transition. See willTransition(to:with:)
    var viewSize = CGSize()
    
    // Settings from JSON settings file
    //var settings: Settings?
    
    // Scale properties
    var scaleMode: ScaleMode = .customScale
    var scaleLockEnabled: Bool = false
    var scaling: Double?
    
    // Location properties
    var updateUserLocationEnabled = true
    var latestLocation = CLLocation(latitude: 0.0, longitude: 0.0)
    
    // MARK: - Init
    override init(nibName: String?, bundle: Bundle?) {
        super.init(nibName: nibName, bundle: bundle)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        // Synchronize updates via the `serialQueue`.
        virtualObjectManager = VirtualObjectManager(updateQueue: serialQueue)
        virtualObjectManager.delegate = self
    }
    
    // MARK: - ARKit Config Properties
    
    var screenCenter: CGPoint?

    let session = ARSession()
    var standardConfiguration: ARWorldTrackingConfiguration = {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.worldAlignment = ARConfiguration.WorldAlignment.gravity // This gravityAndHeading keeps updating the heading causing the model to rotate
        configuration.isLightEstimationEnabled = true
        initSceneReconstruction(configuration: configuration)
        return configuration
    }()
    
    func setFrameSemantics(configuration: ARWorldTrackingConfiguration) {
        if #available(iOS 13, *) {
            if ARWorldTrackingConfiguration.supportsFrameSemantics(ARConfiguration.FrameSemantics.personSegmentationWithDepth) {
                let userDefaults = UserDefaults.standard
                if userDefaults.bool(for: .enablePeopleOcclusion) {
                    configuration.frameSemantics.insert(.personSegmentationWithDepth)
                } else {
                    configuration.frameSemantics.remove(.personSegmentationWithDepth)
                }
            }
        }
    }
    
    class func initSceneReconstruction(configuration: ARWorldTrackingConfiguration) {
        if #available(iOS 13.4, *) {
            if ARWorldTrackingConfiguration.supportsSceneReconstruction(ARConfiguration.SceneReconstruction.meshWithClassification) {
                configuration.sceneReconstruction = .meshWithClassification
            }
        }
    }
    
    // MARK: - Virtual Object Manipulation Properties
    
    //var dragOnInfinitePlanesEnabled = false
    var virtualObjectManager: VirtualObjectManager!
    
    var isLoadingObject: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.settingsButton.isEnabled = !self.isLoadingObject
                self.showAssetsButton.isEnabled = !self.isLoadingObject
                self.restartExperienceButton.isEnabled = !self.isLoadingObject
                self.scaleLabel.isHidden = self.isLoadingObject
            }
        }
    }
    
    // SCNSceneRenderer time
    var lastUpdateTime: TimeInterval?
    
    // MARK: - Other Properties
    
    var textManager: TextManager!
    var restartExperienceButtonIsEnabled = true
    
    // MARK: - UI Elements
    
    var spinner: UIActivityIndicatorView?
    
    @IBOutlet var sceneView: ARSCNView!
    var overlayView: OverlaySKScene!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var showAssetsButton: UIButton!
    @IBOutlet weak var showScaleOptionsButton: UIButton!
    @IBOutlet weak var restartExperienceButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var scaleLabel: UILabel!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var expirationDateLabel: RoundButton!
    @IBOutlet weak var centerObjectDistanceLabel: UILabel!
    @IBOutlet weak var centerMarker: UILabel!
    
    // Indicators to show the direction to the model when the model
    // is outside the screen area.
    @IBOutlet weak var modelIndicatorUp: UILabel!
    @IBOutlet weak var modelIndicatorDown: UILabel!
    @IBOutlet weak var modelIndicatorLeft: UILabel!
    @IBOutlet weak var modelIndicatorRight: UILabel!

    
    // MARK: - Location Service
    var locationService: LocationService?
    
    // We try to get the best heading for the camera pointing to the -z axis of the AR
    // coordinate system (i.e. pointing forward initially). Since the heading is more
    // accurate when the device is pointing forward instead of facing up, we will try to
    // update the initial heading until the model needs it. We keep track of the camera
    // euler angles when we record the initial heading. The x value of the camera euler
    // angles represents whether the camera is pointing forward (0.0), face up (-90.0), or
    // face down (90.0). Pointing backward is also (0.0) but I am not sure if it's because
    // we don't allow the app to be upside down.
    var initialHeading: CLLocationDirection?
    
    // In debug, we saw that the first few camera orientation readings are fluctuating a
    // lot, even when the tracking is normal. We should drop the first few readings. We
    // will calculate the median of the first few headings to eliminate the abnormal readings.
    // We will use an odd number to simplify the median calculation. We cannot use a very
    // large collection (e.g. 101) since it's possible that the camera already detects an
    // anchor plane. If we apply the heading AFTER the anchor plane is added, the plane
    // will be rotated around the new origin and will appear out of place.
    var numHeadingUpdates: UInt32 = 0
    let numHeadingsToCollect: UInt32 = 11
    var firstHeadings: [Double] = []
    
    func didUpdateDescription(_ locationService: LocationService, description: String) {
        headingLabel.text = description
    }
    
    func didUpdateLocation(_ locationService: LocationService, location: CLLocation) {
        latestLocation = location
        
        if !updateUserLocationEnabled {
            return   // Skip the location
        }
     
        updateGeolocationAnchor()
    }
    
    func didUpdateHeading(_ locationService: LocationService, heading: CLHeading) {
        // Initialize the initialHeading based on the current camera orientation and
        // match that to the current true heading
        if initialHeading == nil {
            if let currentFrame = self.sceneView.session.currentFrame, let trueHeading = locationService.heading?.trueHeading {
                switch currentFrame.camera.trackingState {
                    case .normal:
                        if numHeadingUpdates < numHeadingsToCollect {
                            // Set the initial heading based on the current true heading
                            // and the angle between the world orientation and the
                            // camera. Then we rotate the world origin so that we hope
                            // the negative z axis is pointing toward the True North.
                            // However, since the camera orientation is changing a lot,s
                            // the calculation may be inaccurate sometimes. We will try
                            // to use the median of the first few headings to eliminate
                            // abnormal readings.
                            let heading = trueHeading + Double(currentFrame.camera.eulerAngles.y * 180.0 / Float.pi)
                            firstHeadings.append(heading)
                            numHeadingUpdates += 1
                        } else {
                            // Calculate the median
                            let median = firstHeadings.sorted(by: <)[firstHeadings.count / 2]
                            initialHeading = median
                            let rotationMatrix = SCNMatrix4MakeRotation(Float(initialHeading! * Double.pi / 180.0), 0.0, 1.0, 0.0)
                            sceneView.session.setWorldOrigin(relativeTransform: simd_float4x4(rotationMatrix))
                        }
                case .notAvailable:
                    break
                case .limited(_):
                    break
                }
            }
        }
    }
    
    func updateGeolocationAnchor() {
        self.serialQueue.async {
            if let geomarker = self.geolocationNode() {
                
                geomarker.userLocation = self.latestLocation
                
                // Calculate the new geolocation anchor position
                if let anchorLocation = geomarker.geolocation {
                    // Calculate bearing from the user location to the geolocation anchor
                    let lat1 = self.latestLocation.coordinate.latitude * Double.pi / 180.0
                    let lng1 = self.latestLocation.coordinate.longitude * Double.pi / 180.0
                    let lat2 = anchorLocation.coordinate.latitude * Double.pi / 180.0
                    let lng2 = anchorLocation.coordinate.longitude * Double.pi / 180.0
                    let dLon = (lng2 - lng1);
                    let x = sin(dLon) * cos(lat2);
                    let y = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
                    var bearing = atan2(x, y) * 180.0 / Double.pi;
                    bearing = (bearing + 360).truncatingRemainder(dividingBy: 360.0);
                    
                    // Calculate the heading of the device
                    let userHeading = self.locationService?.heading?.trueHeading
                    
                    // Calculate the roll (rotation around the y axis) of the device
                    // relative to the startup orientation. If we are using the
                    // gravity world alignment configuration, the startup orientation
                    // doesn't align with the True North.
                    var roll: Float?
                    var userPosition: SCNVector3?
                    if let currentFrame = self.sceneView.session.currentFrame {
                        roll = currentFrame.camera.eulerAngles.y * 180.0 / Float.pi
                        
                        // Calculate the user position
                        let c = currentFrame.camera.transform.columns.3
                        userPosition = SCNVector3(c.x, c.y, c.z)
                    }
                    
                    // Calculate the distance between the anchor and the user
                    let distance = self.latestLocation.distance(from: anchorLocation)
                    
                    
                    if let userHeading = userHeading, let roll = roll, let userPosition = userPosition {
                        // Calculate the angle between the negative z-axis and the
                        // anchor with the user location as the center.
                        // The roll is -ve when clockwise, so we need to negate it
                        // to match the compass rotation.
                        let angle = (bearing - (userHeading - Double(-roll))) * Double.pi / 180.0
                        
                        // Calculate the relative anchor position from the user
                        // location
                        let deltaX = distance * sin(angle)
                        let deltaZ = -distance * cos(angle)
                        
                        // Calculate the anchor position relative to the current
                        // coordinate system
                        let x = userPosition.x + Float(deltaX)
                        let z = userPosition.z + Float(deltaZ)
                        
                        self.virtualObjectManager.updateQueue.async {
                            // Put the geolocation anchor at the same altitude as the model.
                            let altitude = self.virtualObject()?.position.y ?? 0.0
                            self.geolocationNode()?.move(to: SCNVector3(x, altitude, z))
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Queues
    
	let serialQueue = DispatchQueue(label: "com.apple.arkitexample.serialSceneKitQueue")
	
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        
        locationService = LocationService()
        locationService?.delegates.append(WeakRef(value: self))

        Setting.registerDefaults()
		setupUIControls()
        setupScene()
    }

    func setARWorldTrackingConfiguration(worldAlignment: ARConfiguration.WorldAlignment) {
        standardConfiguration = {
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = .horizontal
            configuration.worldAlignment = worldAlignment
            configuration.isLightEstimationEnabled = true
            return configuration
        }()
    }
    
    func virtualObject() -> VirtualObject? {
        return self.sceneView.scene.rootNode.childNode(withName: "VirtualObject", recursively: true) as? VirtualObject
    }

    func virtualObjectContent() -> SCNNode? {
        return self.sceneView.scene.rootNode.childNode(withName: "VirtualObjectContent", recursively: true)
    }

    func anchorNode() -> SCNNode? {
        return self.sceneView.scene.rootNode.childNode(withName: "Anchor Node", recursively: true)
    }
    
    func geolocationNode() -> GeolocationMarkerNode? {
        return self.sceneView.scene.rootNode.childNode(withName: geomarkerNodeName, recursively: true) as? GeolocationMarkerNode
    }
    
    func addGeolocationNode() -> GeolocationMarkerNode {
        let geomarker = GeolocationMarkerNode()
        geomarker.name = geomarkerNodeName
        geomarker.color = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.8)
        geomarker.userLocation = self.locationService?.locationManager?.location
        self.sceneView.scene.rootNode.addChildNode(geomarker)
        return geomarker
    }
    
    func removeGeolocationNode() {
        serialQueue.async {
            if let node = self.geolocationNode() {
                node.removeFromParentNode()
            }
        }
    }

    func currentScale() -> Float {
        if let virtualObjectNode = virtualObject() {
            return virtualObjectNode.scale.x
        } else {
            return 1.0
        }
    }
    
    func modelDimension() -> [Float] {
        if let virtualObjectNode = virtualObject() {
            let d = virtualObjectNode.dimension()
            return [d.x, d.y, d.z]
        } else {
            return []
        }
    }
    
    func moveModelToGeolocation() {
        guard let geomarker = geolocationNode(), let model = virtualObject() else {
            print("FAILED TO MOVE MODEL TO GEOLOCATION")
            return
        }
        
        // If the model content is not at the zero position, we should offset
        // it back to zero (center), and then we move to the anchor position.
        let newPosition = geomarker.position
        if let modelContent = virtualObjectContent() {
            let (minCoord, maxCoord) = modelContent.boundingBox
            let centerX = (minCoord.x + maxCoord.x) * 0.5
            let centerY = (minCoord.y + maxCoord.y) * 0.5
            let groundZ: Float = 0.0
            var anchorVector = SCNVector3Make(centerX, centerY, groundZ)
            if let anchor = geomarker.anchor {
                if let x = anchor.x {
                    anchorVector.x = Float(x)
                }
                if let y = anchor.y {
                    anchorVector.y = Float(y)
                }
                if let z = anchor.z {
                    anchorVector.z = Float(z)
                }
            }
            model.anchorAt(position: anchorVector)
        }
        
        let action = SCNAction.move(to: newPosition, duration: 1.0)
        action.timingMode = .easeInEaseOut
        model.runAction(action)
    }
    
    func setScale(scale: Float) {
        if let virtualObjectNode = virtualObject() {
            updateScaleLabel(scale: scale)
            let duration = max(1.0, min(3.0, scale / virtualObjectNode.scale.x))
            print("Animating scale from '\(virtualObjectNode.scale)' to '\(scale)' in a duration of '\(duration)'")
            let scaleAction = SCNAction.scale(to: CGFloat(scale), duration: Double(duration))
            scaleAction.timingMode = .easeInEaseOut
            virtualObjectNode.runAction(scaleAction)
        }
    }
    
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
        
        locationService?.startLocationService()

        // Get the current view size
        self.viewSize = self.sceneView.bounds.size
        
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
    
    override func didReceiveMemoryWarning() {
        print("didReceiveMemoryWarning")
    }
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
        
        locationService?.stopLocationService()
        
		session.pause()

//        if let document = self.document {
//            closeDocument(document: document)
//        }
        
//        documentOpened = false
	}

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.viewSize = size
        self.overlayView.updateCompassPosition()
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
		// set up scene view
		sceneView.setup()
		sceneView.delegate = self
		sceneView.session = session
		sceneView.showsStatistics = false
        setupLighting()
        session.delegate = self
		
        // set up overlay view
        overlayView = OverlaySKScene(size: self.view.bounds.size)
        overlayView.overlaySKSceneDelegate = self
        locationService?.delegates.append(WeakRef(value: overlayView))
        sceneView.overlaySKScene = overlayView
        
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
        messageLabel.isHidden = true
        messageLabel.text = ""
        messageLabel.layer.zPosition = 2

        // Scale Options
        showScaleOptionsButton.setTitle(self.scaleOptionsButtonText(mode: .customScale, lockOn: false), for: .normal)
        showScaleOptionsButton.isHidden = true
        
        // Expiration date label
        expirationDateLabel.isHidden = true
        expirationDateLabel.layer.zPosition = 1
        
        // Center marker and distance label
        self.centerObjectDistanceLabel.layer.cornerRadius = 10.0
        self.centerObjectDistanceLabel.layer.masksToBounds = true
        self.centerObjectDistanceLabel.backgroundColor = DesignSystem.Colour.SemanticPalette.mayaBlueDark10
        self.centerMarker.isHidden = !UserDefaults.standard.bool(for: .showCenterDistance)
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
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		virtualObjectManager.reactToTouchesMoved(touches, with: event)
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
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

//        if let document = self.document {
//            if !documentOpened {
//                openDocument(document: document)
//            }
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
	
    func updateFrameSemantics() {
        setFrameSemantics(configuration: standardConfiguration)
        session.run(standardConfiguration)
    }
    
	func resetTracking() {
        setFrameSemantics(configuration: standardConfiguration)
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
            self.focusSquare?.update(for: worldPos, planeAnchor: planeAnchor, camera: self.session.currentFrame?.camera)
            self.textManager.cancelScheduledMessage(forType: .focusSquare)
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
//        
//        if let path = modelPath {
//            loadModel(path: path)
//        }
     
        updateCenterDistance(frame: frame)
    }
    
    func updateCenterDistance(frame: ARFrame) {
        if UserDefaults.standard.bool(for: .showCenterDistance) {
            if let screenCenter = self.screenCenter, let sceneView = self.sceneView {
                let hitResult = sceneView.hitTest(screenCenter, options: [:])
                if !hitResult.isEmpty {
                    let objectPosition = hitResult.first!.worldCoordinates
                    let translation = frame.camera.transform.translation
                    let cameraPosition = SCNVector3(translation.x, translation.y, translation.z)
                    var length = SCNVector3.distanceFrom(vector: cameraPosition, toVector: objectPosition)
                    var unit = ""
                    var distance = ""
                    
                    if length < 1.0 {
                        // Display as centimeter
                        unit = "cm"
                        length *= 100
                        distance = String(format: "%.0f", length)
                    } else if length < 10.0 {
                        // Display as meter
                        unit = "m"
                        distance = String(format: "%.1f", length)
                    }
                    else {
                        // Display as meter
                        unit = "m"
                        distance = String(format: "%.0f", length)
                    }
                                    
                    self.centerObjectDistanceLabel.text = "\(distance)\(unit)"
                    self.centerObjectDistanceLabel.isHidden = false
                    self.centerMarker.textColor = DesignSystem.Colour.SemanticPalette.mayaBlueDark10
                } else {
                    self.centerObjectDistanceLabel.isHidden = true
                    self.centerMarker.textColor = DesignSystem.Colour.NeutralPalette.grey
                }
            }
        }
    }
    
    // MARK: - Log
    
    func logSCNHitTestResult(_ result: SCNHitTestResult) {
        print("SCNHitTestResult: node = \(result.node)")
        print("SCNHitTestResult: geometryIndex = \(result.geometryIndex)")
        print("SCNHitTestResult: faceIndex = \(result.faceIndex)")
    }
    
    // MARK: - View Model
    func lengthText(_ length: Float) -> String {
        let formatter = NumberFormatter()
        formatter.usesSignificantDigits = true
        formatter.maximumSignificantDigits = 3
        formatter.minimumSignificantDigits = 2
        
        var adjustedLength = length
        var lengthText = "--"
        var unit = ""
        if (length >= 1000.0) {
            adjustedLength = length / 1000.0
            unit = "km"
        } else if (length < 1.0) {
            adjustedLength = length * 100.0
            unit = "cm"
        } else {
            adjustedLength = length
            unit = "m"
        }

        if let roundedLength = formatter.string(from: NSNumber(value: adjustedLength)) {
            lengthText = roundedLength + unit
        }

        return lengthText
    }
    
    func ratioText(_ scale: Float) -> String {
        let formatter = NumberFormatter()
        formatter.usesSignificantDigits = true
        formatter.maximumSignificantDigits = 3
        formatter.minimumSignificantDigits = 1

        var ratio = "-:-"
        if (scale > 1.0) {
            var adjustedScale = scale
            var unit = ""
            if scale >= 1000.0 {
                adjustedScale = scale / 1000.0
                unit = "k"
            }
            if let roundedScale = formatter.string(from: NSNumber(value: adjustedScale)) {
                ratio = "\(roundedScale)\(unit):1"
            }
        } else if (scale <= 0.0) {
            ratio = "∞"
        } else if (scale <= 1.0) {
            var adjustedScale = 1.0 / scale
            var unit = ""
            if adjustedScale >= 1000.0 {
                adjustedScale = adjustedScale / 1000.0
                unit = "k"
            }

            //let roundedScale = (1.0 / objectScale).rounded().format(f: ".0")
            if let roundedScale = formatter.string(from: NSNumber(value: adjustedScale)) {
                ratio = "1:\(roundedScale)\(unit)"
            }
        }
        
        return ratio
    }
    
    func dimensionAndScaleText(scale: Float, node: SCNNode) -> String {
        let (minBounds, maxBounds) = node.boundingBox
        return dimensionAndScaleText(scale: scale, boundingBoxMin: minBounds, boundingBoxMax: maxBounds)
    }
    
    func dimensionAndScaleText(scale: Float, boundingBoxMin: SCNVector3, boundingBoxMax: SCNVector3) -> String {
        let xInMeter = (boundingBoxMax.x - boundingBoxMin.x) * scale
        let yInMeter = (boundingBoxMax.y - boundingBoxMin.y) * scale
        let zInMeter = (boundingBoxMax.z - boundingBoxMin.z) * scale
        
        return "❑ \(lengthText(xInMeter)) x \(lengthText(yInMeter)) x \(lengthText(zInMeter)) (\(ratioText(scale)))"
    }
    
    func scaleOptionsButtonText(mode: ScaleMode, lockOn: Bool) -> String {
        // Put extra space to make the lock appear on a separate line
        let lock = (lockOn) ? "  🔒  " : ""
        let scaleText = (mode == .fullScale) ? "Full Scale" : "Custom Scale"
        return scaleText + lock
    }
    
    
    // MARK: - UI
    func updateScaleLabel(scale: Float) {
        DispatchQueue.main.async {
            if let virtualObjectNode = self.virtualObject() {
                self.scaleLabel.text = self.dimensionAndScaleText(scale: scale, node: virtualObjectNode)
            } else {
                self.scaleLabel.text = ""
            }
        }
    }
    
    @IBAction func userLocationTapped(_ sender: Any) {
        if let geomarker = geolocationNode() {
            if let userLocation = geomarker.userLocation {
                
                let urlString = "http://maps.apple.com/?ll=\(userLocation.coordinate.latitude),\(userLocation.coordinate.longitude)"
                if let url = URL(string: urlString) {
                    
                    let alert = UIAlertController(title: "Open Device Location in Maps",
                                                  message: "Do you want to open the current device location in the Maps app?",
                                                  preferredStyle: .alert)
                    
                    // Create OK button with action handler
                    let ok = UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
                        print("Ok button tapped")
                        UIApplication.shared.open(url)
                    })
                    
                    // Create Cancel button with action handlder
                    let cancel = UIAlertAction(title: "No", style: .cancel) { (action) -> Void in
                        print("Cancel button tapped")
                    }
                    
                    //Add OK and Cancel button to dialog message
                    alert.addAction(ok)
                    alert.addAction(cancel)
                    
                    // Present dialog message to user
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
}
