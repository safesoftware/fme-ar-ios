/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Popover view controller for app settings.
*/

import UIKit

// MARK: - Constants
let kScaleModeFull = 0
let kScaleModeCustom = 1

let kSectionScaleOptions = 0
let kSectionCustomScaleRatios = 1

let kTableViewCellIDScaleRatio = "ScaleRatioTableViewCell"

enum ScaleOption: String {
    case scaleMode
    case scaleLockEnabled
    
    static func registerDefaults() {
        UserDefaults.standard.register(defaults: [
            ScaleOption.scaleMode.rawValue: kScaleModeCustom,
            ScaleOption.scaleLockEnabled.rawValue: false
        ])
    }
}

extension UserDefaults {
    func bool(for scaleOption: ScaleOption) -> Bool {
        return bool(forKey: scaleOption.rawValue)
    }
    func set(_ bool: Bool, for scaleOption: ScaleOption) {
        set(bool, forKey: scaleOption.rawValue)
    }
    
    func integer(for scaleOption: ScaleOption) -> Int {
        return integer(forKey: scaleOption.rawValue)
    }
    
    func set(_ integer: Int, for scaleOption: ScaleOption) {
        set(integer, forKey: scaleOption.rawValue)
    }
}

protocol ScaleOptionsViewControllerDelegate: class {
    func scaleOptionsViewControllerDelegate(_: ScaleOptionsViewController, didChangeScale scale: Float)
    func scaleOptionsViewControllerDelegate(_: ScaleOptionsViewController, didToggleScaleLock on: Bool)
}

class ScaleOptionsViewController: UITableViewController {
    
    // MARK: - UI Elements
    @IBOutlet weak var scaleModeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var scaleLockSwitch: UISwitch!
    
    weak var delegate: ScaleOptionsViewControllerDelegate?
    
    func loadUserDefaults() {
        let defaults = UserDefaults.standard
        let scaleMode = defaults.integer(for: .scaleMode)
        scaleModeSegmentedControl.selectedSegmentIndex = max(min(scaleMode, 1), 0)
        scaleLockSwitch.isOn = defaults.bool(for: .scaleLockEnabled)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUserDefaults()
    }
    
    override func viewWillLayoutSubviews() {
        preferredContentSize.height = tableView.contentSize.height
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        let defaults = UserDefaults.standard
        switch sender {
            case scaleModeSegmentedControl:
                defaults.set(sender.selectedSegmentIndex, for: .scaleMode)
                tableView.reloadData()
            default: break
        }
    }
    
    @IBAction func didToggleScaleLock(_ sender: UISwitch) {
        let defaults = UserDefaults.standard
        switch sender {
            case scaleLockSwitch:
                defaults.set(sender.isOn, for: .scaleLockEnabled)
                tableView.reloadData()
//                if delegate != nil {
//                    delegate?.settingsViewControllerDelegate(self, didToggleLightEstimation: sender.isOn)
//                }
            default: break
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if (section == kSectionCustomScaleRatios) {
//            return 4
//        }
//
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if (indexPath.section == kSectionCustomScaleRatios) {
//            var cell:UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: kTableViewCellIDScaleRatio)
//            if (cell == nil ) {
//                cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: kTableViewCellIDScaleRatio)
//            }
//
//            if let cell = cell {
//                cell.textLabel?.text = "\(indexPath.row)"
//                cell.detailTextLabel?.text = "\(indexPath.section)"
//                return cell
//            }
//        }
//        
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
}

//protocol SettingsViewControllerDelegate: class {
//    func settingsViewControllerDelegate(_: SettingsViewController, didToggleLightEstimation on: Bool)
//    func settingsViewControllerDelegate(_: SettingsViewController, didToggleDrawDetectedPlane on: Bool)
//    func settingsViewControllerDelegate(_: SettingsViewController, didChangeScale scale: Float)
//    func settingsViewControllerDelegate(_: SettingsViewController, didChangeIntensity intensity: Float)
//    func settingsViewControllerDelegate(_: SettingsViewController, didChangeTemperature temperature: Float)
//}
//
//class SettingsViewController: UITableViewController {
//
//    // MARK: - UI Elements
//l
////    @IBOutlet weak var scaleWithPinchGestureSwitch: UISwitch!
////    @IBOutlet weak var dragOnInfinitePlanesSwitch: UISwitch!
//    @IBOutlet weak var lightEstimationSwitch: UISwitch!
//    @IBOutlet weak var scaleLabel: UILabel!
//    @IBOutlet weak var fullScaleButton: UIButton!
//    @IBOutlet weak var intensitySlider: UISlider!
//    @IBOutlet weak var temperatureSlider: UISlider!
//    @IBOutlet weak var drawDetectedPlaneSwitch: UISwitch!
//
//    weak var delegate: SettingsViewControllerDelegate?
//    var scale: Float = 1.0
//    var intensity: Float = 1000
//    var temperature: Float = 6500
//
//    // Sections
//    let kLightEstimationSection = 0
//    let kRenderingSection = 1
//    let kScaleSection = 2
//
//    // Section: Light Estimation
//    let kLightEstimationRow = 0
//    let kIntensityRow = 1
//    let kTemperatureRow = 2
//
//    // Section: Rendering
//    let kDrawDetectedPlanRow = 0
//
//    // Section: Scaling
//
//    // MARK: - View Life Cycle
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        intensitySlider.value = intensity
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        let defaults = UserDefaults.standard
////        scaleWithPinchGestureSwitch.isOn = defaults.bool(for: .scaleWithPinchGesture)
////        dragOnInfinitePlanesSwitch.isOn = defaults.bool(for: .dragOnInfinitePlanes)
//        lightEstimationSwitch.isOn = defaults.bool(for: .estimateLight)
//        drawDetectedPlaneSwitch.isOn = defaults.bool(for: .drawDetectedPlane)
//        updateScaleSettings()
//    }
//
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.section == kLightEstimationSection &&
//            (indexPath.row == kIntensityRow || indexPath.row == kTemperatureRow) &&
//            lightEstimationSwitch.isOn {
//            return 0 // hide the intensity slider since light estimation is on
//        } else {
//            return super.tableView(tableView, heightForRowAt: indexPath)
//        }
//    }
//
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // Hide the scale section for now since the model doesn't scale from
//        // the correct origin
//        return 2
//    }
//
//    func updateScaleSettings() {
//        scaleLabel.text = String(format: "%.3f", scale)
//
//        if (scaleLabel.text == "1.000") {
//            scaleLabel.text = "Full Scale"
//            fullScaleButton.isEnabled = false
//        } else if (scaleLabel.text == "0.000") {
//            scaleLabel.text = "< 0.001"
//            fullScaleButton.isEnabled = true
//        } else {
//            fullScaleButton.isEnabled = true
//        }
//    }
//
//    override func viewWillLayoutSubviews() {
//        preferredContentSize.height = tableView.contentSize.height
//    }
//
//    // MARK: - Actions
//
//    @IBAction func didChangeSetting(_ sender: UISwitch) {
//        let defaults = UserDefaults.standard
//        switch sender {
////            case scaleWithPinchGestureSwitch:
////                defaults.set(sender.isOn, for: .scaleWithPinchGesture)
////            case dragOnInfinitePlanesSwitch:
////                defaults.set(sender.isOn, for: .dragOnInfinitePlanes)
//            case lightEstimationSwitch:
//                defaults.set(sender.isOn, for: .estimateLight)
//                tableView.reloadData()
//                if delegate != nil {
//                    delegate?.settingsViewControllerDelegate(self, didToggleLightEstimation: sender.isOn)
//                }
//            case drawDetectedPlaneSwitch:
//                defaults.set(sender.isOn, for: .drawDetectedPlane)
//                tableView.reloadData()
//                if delegate != nil {
//                    delegate?.settingsViewControllerDelegate(self, didToggleDrawDetectedPlane: sender.isOn)
//                }
//            default: break
//        }
//    }
//
//    @IBAction func didChangeSlider(_ sender: UISlider) {
//        switch sender {
//        case intensitySlider:
//            if delegate != nil {
//                delegate?.settingsViewControllerDelegate(self, didChangeIntensity: sender.value)
//            }
//        case temperatureSlider:
//            if delegate != nil {
//                delegate?.settingsViewControllerDelegate(self, didChangeTemperature: sender.value)
//            }
//        default:
//            break   // Do nothing
//        }
//    }
//
//    @IBAction func clicked(_ sender: UIButton) {
//        switch sender {
//        case fullScaleButton:
//            scale = 1.0
//            updateScaleSettings()
//            if delegate != nil {
//                delegate?.settingsViewControllerDelegate(self, didChangeScale: scale)
//            }
//        default:
//            break   // Do nothing
//        }
//    }
//}
