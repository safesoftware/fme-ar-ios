/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Popover view controller for app settings.
*/

import UIKit

enum Setting: String {
//    case scaleWithPinchGesture
//    case dragOnInfinitePlanes
    case estimateLight
    case drawDetectedPlane
    case drawAnchor
    case drawGeomarker
    case showCenterDistance
    case enablePeopleOcclusion
    case labelFontSize
    
    static func registerDefaults() {
        UserDefaults.standard.register(defaults: [
//            Setting.dragOnInfinitePlanes.rawValue: true,
//            Setting.scaleWithPinchGesture.rawValue: true,
            Setting.estimateLight.rawValue: false,
            Setting.drawDetectedPlane.rawValue: true,
            Setting.drawAnchor.rawValue: true,
            Setting.drawGeomarker.rawValue: true,
            Setting.showCenterDistance.rawValue: true,
            Setting.enablePeopleOcclusion.rawValue: true,
            Setting.labelFontSize.rawValue: 12.0
        ])
    }
}

extension UserDefaults {
    func bool(for setting: Setting) -> Bool {
        return bool(forKey: setting.rawValue)
    }
    func set(_ bool: Bool, for setting: Setting) {
        set(bool, forKey: setting.rawValue)
    }
    
    func float(for setting: Setting) -> Float {
        return float(forKey: setting.rawValue)
    }
    func set(_ float: Float, for setting: Setting) {
        set(float, forKey: setting.rawValue)
    }
}

protocol SettingsViewControllerDelegate: class {
    func settingsViewControllerDelegate(_: SettingsViewController, didToggleLightEstimation on: Bool)
    func settingsViewControllerDelegate(_: SettingsViewController, didToggleDrawDetectedPlane on: Bool)
    func settingsViewControllerDelegate(_: SettingsViewController, didToggleDrawAnchor on: Bool)
    func settingsViewControllerDelegate(_: SettingsViewController, didToggleDrawGeomarker on: Bool)
    func settingsViewControllerDelegate(_: SettingsViewController, didToggleShowCenterDistance on: Bool)
    func settingsViewControllerDelegate(_: SettingsViewController, didToggleEnablePeopleOcclusion on: Bool)
    func settingsViewControllerDelegate(_: SettingsViewController, didChangeScale scale: Float)
    func settingsViewControllerDelegate(_: SettingsViewController, didChangeIntensity intensity: Float)
    func settingsViewControllerDelegate(_: SettingsViewController, didChangeTemperature temperature: Float)
}

class SettingsViewController: UITableViewController {
        
    // MARK: - UI Elements
    
//	@IBOutlet weak var scaleWithPinchGestureSwitch: UISwitch!
//	@IBOutlet weak var dragOnInfinitePlanesSwitch: UISwitch!
    @IBOutlet weak var lightEstimationSwitch: UISwitch!
    @IBOutlet weak var scaleLabel: UILabel!
    @IBOutlet weak var fullScaleButton: UIButton!
    @IBOutlet weak var intensitySlider: UISlider!
    @IBOutlet weak var temperatureSlider: UISlider!
    @IBOutlet weak var drawDetectedPlaneSwitch: UISwitch!
    @IBOutlet weak var drawAnchorSwitch: UISwitch!
    @IBOutlet weak var drawGeomarkerSwitch: UISwitch!
    @IBOutlet weak var showCenterDistanceSwitch: UISwitch!
    @IBOutlet weak var enablePeopleOcclusionSwitch: UISwitch!
    @IBOutlet weak var enablePeopleOcclusionLabel: UILabel!
    
    
    weak var delegate: SettingsViewControllerDelegate?
    var scale: Float = 1.0
    var intensity: Float = 1000
    var temperature: Float = 6500
    
    // Sections
    let kLightEstimationSection = 0
    let kRenderingSection = 1
    let kScaleSection = 2
    
    // Section: Light Estimation
    let kLightEstimationRow = 0
    let kIntensityRow = 1
    let kTemperatureRow = 2
    
    // Section: Rendering
    let kDrawDetectedPlanRow = 0
    
    // Section: Scaling
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        intensitySlider.value = intensity
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let defaults = UserDefaults.standard
//        scaleWithPinchGestureSwitch.isOn = defaults.bool(for: .scaleWithPinchGesture)
//        dragOnInfinitePlanesSwitch.isOn = defaults.bool(for: .dragOnInfinitePlanes)
        lightEstimationSwitch.isOn = defaults.bool(for: .estimateLight)
        drawDetectedPlaneSwitch.isOn = defaults.bool(for: .drawDetectedPlane)
        drawAnchorSwitch.isOn = defaults.bool(for: .drawAnchor)
        drawGeomarkerSwitch.isOn = defaults.bool(for: .drawGeomarker)
        showCenterDistanceSwitch.isOn = defaults.bool(for: .showCenterDistance)
        enablePeopleOcclusionSwitch.isOn = defaults.bool(for: .enablePeopleOcclusion)
        
        // Disable People Occlusion option for iOS prior to 13.0
        if #available(iOS 13, *) {
            enablePeopleOcclusionSwitch.isEnabled = true
        } else {
            enablePeopleOcclusionLabel.text = "People Occlusion (iOS 13+)"
            enablePeopleOcclusionSwitch.isEnabled = false
            enablePeopleOcclusionSwitch.isOn = false
        }

        updateScaleSettings()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == kLightEstimationSection &&
            (indexPath.row == kIntensityRow || indexPath.row == kTemperatureRow) &&
            lightEstimationSwitch.isOn {
            return 0 // hide the intensity slider since light estimation is on
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Hide the scale section for now since the model doesn't scale from
        // the correct origin
        return 2
    }
    
    func updateScaleSettings() {
        scaleLabel.text = String(format: "%.3f", scale)

        if (scaleLabel.text == "1.000") {
            scaleLabel.text = "Full Scale"
            fullScaleButton.isEnabled = false
        } else if (scaleLabel.text == "0.000") {
            scaleLabel.text = "< 0.001"
            fullScaleButton.isEnabled = true
        } else {
            fullScaleButton.isEnabled = true
        }
    }
    
    override func viewWillLayoutSubviews() {
        preferredContentSize.height = tableView.contentSize.height
    }
    
    // MARK: - Actions
    
	@IBAction func didChangeSetting(_ sender: UISwitch) {
		let defaults = UserDefaults.standard
		switch sender {
//            case scaleWithPinchGestureSwitch:
//                defaults.set(sender.isOn, for: .scaleWithPinchGesture)
//            case dragOnInfinitePlanesSwitch:
//                defaults.set(sender.isOn, for: .dragOnInfinitePlanes)
            case lightEstimationSwitch:
                defaults.set(sender.isOn, for: .estimateLight)
                tableView.reloadData()
                if delegate != nil {
                    delegate?.settingsViewControllerDelegate(self, didToggleLightEstimation: sender.isOn)
                }
            case drawDetectedPlaneSwitch:
                defaults.set(sender.isOn, for: .drawDetectedPlane)
                tableView.reloadData()
                if delegate != nil {
                    delegate?.settingsViewControllerDelegate(self, didToggleDrawDetectedPlane: sender.isOn)
                }
            case drawAnchorSwitch:
                defaults.set(sender.isOn, for: .drawAnchor)
                tableView.reloadData()
                if delegate != nil {
                    delegate?.settingsViewControllerDelegate(self, didToggleDrawAnchor: sender.isOn)
                }
            case drawGeomarkerSwitch:
                defaults.set(sender.isOn, for: .drawGeomarker)
                tableView.reloadData()
                if delegate != nil {
                    delegate?.settingsViewControllerDelegate(self, didToggleDrawGeomarker: sender.isOn)
                }
            case showCenterDistanceSwitch:
                defaults.set(sender.isOn, for: .showCenterDistance)
                tableView.reloadData()
                if delegate != nil {
                    delegate?.settingsViewControllerDelegate(self, didToggleShowCenterDistance: sender.isOn)
                }
            case enablePeopleOcclusionSwitch:
                defaults.set(sender.isOn, for: .enablePeopleOcclusion)
                tableView.reloadData()
                if delegate != nil {
                    delegate?.settingsViewControllerDelegate(self, didToggleEnablePeopleOcclusion: sender.isOn)
                }
            default: break
		}
	}
    
    @IBAction func didChangeSlider(_ sender: UISlider) {
        switch sender {
        case intensitySlider:
            if delegate != nil {
                delegate?.settingsViewControllerDelegate(self, didChangeIntensity: sender.value)
            }
        case temperatureSlider:
            if delegate != nil {
                delegate?.settingsViewControllerDelegate(self, didChangeTemperature: sender.value)
            }
        default:
            break   // Do nothing
        }
    }

    @IBAction func clicked(_ sender: UIButton) {
        switch sender {
        case fullScaleButton:
            scale = 1.0
            updateScaleSettings()
            if delegate != nil {
                delegate?.settingsViewControllerDelegate(self, didChangeScale: scale)
            }
        default:
            break   // Do nothing
        }
    }
}
