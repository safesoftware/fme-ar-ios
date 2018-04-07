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
    
    static func registerDefaults() {
        UserDefaults.standard.register(defaults: [
//            Setting.dragOnInfinitePlanes.rawValue: true,
//            Setting.scaleWithPinchGesture.rawValue: true,
            Setting.estimateLight.rawValue: false
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
}

protocol SettingsViewControllerDelegate: class {
    func settingsViewControllerDelegate(_: SettingsViewController, didToggleLightEstimation on: Bool)
    func settingsViewControllerDelegate(_: SettingsViewController, didChangeScale scale: Float)
    func settingsViewControllerDelegate(_: SettingsViewController, didChangeIntensity intensity: Float)
}

class SettingsViewController: UITableViewController {
        
    // MARK: - UI Elements
    
//	@IBOutlet weak var scaleWithPinchGestureSwitch: UISwitch!
//	@IBOutlet weak var dragOnInfinitePlanesSwitch: UISwitch!
    @IBOutlet weak var lightEstimationSwitch: UISwitch!
    @IBOutlet weak var scaleLabel: UILabel!
    @IBOutlet weak var fullScaleButton: UIButton!
    @IBOutlet weak var intensitySlider: UISlider!
    
    weak var delegate: SettingsViewControllerDelegate?
    var scale: Float = 1.0
    var intensity: Float = 1000
    
    let kLightEstimationSection = 0
    let kScaleSection = 1
    let kLightEstimationRow = 0
    let kIntensityRow = 1
    
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
        updateScaleSettings()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == kLightEstimationSection && indexPath.row == kIntensityRow && lightEstimationSwitch.isOn {
            return 0 // hide the intensity slider since light estimation is on
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
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
            default: break
		}
	}
    
    @IBAction func didChangeSlider(_ sender: UISlider) {
        switch sender {
        case intensitySlider:
            if delegate != nil {
                delegate?.settingsViewControllerDelegate(self, didChangeIntensity: sender.value)
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
