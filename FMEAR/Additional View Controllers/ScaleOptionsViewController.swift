/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Popover view controller for app settings.
*/

import UIKit

// MARK: - Constants
let kScaleModeFullSegmentIndex = 0
let kScaleModeCustomSegmentIndex = 1

let kSectionScaleOptions = 0
let kSectionCustomScaleRatios = 1

let kRowScaleMode = 0
let kRowScaleLock = 1

let kRowCurrentScale = 0

let kTableViewCellIDScaleRatio = "ScaleRatioTableViewCell"



protocol ScaleOptionsViewControllerDelegate: class {
    func scaleOptionsViewControllerDelegate(_: ScaleOptionsViewController, didChangeScaleMode mode: ScaleMode, lockOn: Bool)
    func scaleOptionsViewControllerDelegate(_: ScaleOptionsViewController, didChangeScale scale: Float)
}

class ScaleOptionsViewController: UITableViewController {
    
    weak var delegate: ScaleOptionsViewControllerDelegate?
    
    var dimension: [Float] = [0.0, 0.0, 0.0] {
        didSet {
            self.viewModel = ScaleOptionViewModel(dimension: dimension, currentScale: currentScale)
        }
    }
    var currentScale: Float = 1.0 {
        didSet {
            self.viewModel = ScaleOptionViewModel(dimension: dimension, currentScale: currentScale)
        }
    }
    private var viewModel: ScaleOptionViewModel
    
    required init?(coder aDecoder: NSCoder) {
        self.viewModel = ScaleOptionViewModel(dimension: dimension, currentScale: currentScale)
        super.init(coder: aDecoder)
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!) {
        self.viewModel = ScaleOptionViewModel(dimension: dimension, currentScale: currentScale)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
//    convenience init() {
//        self.init(nibName: nil, bundle: nil)
//        viewModel = ScaleOptionViewModel(dimension: dimension, currentScale: currentScale)
//    }
    
    override func viewDidLoad() {
        tableView.dataSource = viewModel
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.selectRow(at: IndexPath(row: kRowCurrentScale, section: kSectionCustomScaleRatios), animated: false, scrollPosition: .bottom)
    }
    
    func scaleMode(scaleModeSegmentedControl: UISegmentedControl) -> ScaleMode {
        switch scaleModeSegmentedControl.selectedSegmentIndex {
        case kScaleModeFullSegmentIndex:
            return ScaleMode.fullScale
        case kScaleModeCustomSegmentIndex:
            fallthrough
        default:
            return ScaleMode.customScale
        }
    }
    
    func reloadScaleLockRow() {
        let indexPath = IndexPath(row: kRowScaleLock, section: kSectionScaleOptions)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func updateTableViewFor(scaleMode: ScaleMode) {
        tableView.beginUpdates()
        if (scaleMode == .fullScale) {

            viewModel.scaleLockEnabled = true
            
            // Scale Lock row
            let scaleLockIndexPath = IndexPath(row: kRowScaleLock, section: kSectionScaleOptions)
            if let cell = tableView.cellForRow(at: scaleLockIndexPath) {
                cell.isUserInteractionEnabled = false
                cell.alpha = 0.3
            }
        } else {
            // Scale Lock row
            let scaleLockIndexPath = IndexPath(row: kRowScaleLock, section: kSectionScaleOptions)
            if let cell = tableView.cellForRow(at: scaleLockIndexPath) {
                cell.isUserInteractionEnabled = true
                cell.alpha = 1.0
            }
        }
        tableView.endUpdates()
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        let mode = scaleMode(scaleModeSegmentedControl: sender)
        viewModel.scaleMode = mode
        tableView.reloadData()
        
        if delegate != nil {
            delegate?.scaleOptionsViewControllerDelegate(self, didChangeScaleMode: mode, lockOn: viewModel.scaleLockEnabled)
            if mode == ScaleMode.fullScale {
                delegate?.scaleOptionsViewControllerDelegate(self, didChangeScale: 1.0)
            }
        }
    }
    
    @IBAction func didToggleScaleLock(_ sender: UISwitch) {
        viewModel.scaleLockEnabled = sender.isOn
        if delegate != nil {
            delegate?.scaleOptionsViewControllerDelegate(self, didChangeScaleMode: viewModel.scaleMode, lockOn: viewModel.scaleLockEnabled)
        }
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (viewModel.scaleMode == .fullScale &&
            ((indexPath.section == kSectionScaleOptions && indexPath.row == kRowScaleLock) ||
            (indexPath.section == kSectionCustomScaleRatios))) {
            cell.alpha = 0.3
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if (indexPath.section == kSectionScaleOptions) {
            return nil
        }
        
        return indexPath
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == kSectionCustomScaleRatios) {
            if let cell = tableView.cellForRow(at: indexPath) as? ScalePresetTableViewCell {
                if let item = cell.item {
                    delegate?.scaleOptionsViewControllerDelegate(self, didChangeScale: item.scale)
                }
            }
        }
    }
}

class ScaleModeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var scaleModeSegmentedControl: UISegmentedControl!
    
    var item: ScaleOptionViewModelItem? {
        didSet {
            guard let item = item as? ScaleOptionViewModelScaleModeItem else {
                return
            }
            
            switch item.scaleMode {
            case .fullScale:
                scaleModeSegmentedControl.selectedSegmentIndex = kScaleModeFullSegmentIndex
            case .customScale:
                scaleModeSegmentedControl.selectedSegmentIndex = kScaleModeCustomSegmentIndex
            }
            
            self.selectionStyle = .none
        }
    }
    
    static var identifier: String {
        return String(describing: self)
    }
}

class ScaleLockTableViewCell: UITableViewCell {
    
    @IBOutlet weak var scaleLockSwitch: UISwitch!
    
    var item: ScaleOptionViewModelItem? {
        didSet {
            guard let item = item as? ScaleOptionViewModelScaleModeItem else {
                return
            }
            
            if (item.scaleMode == .fullScale) {
                scaleLockSwitch.isOn = true
            } else {
                scaleLockSwitch.isOn = item.scaleLockEnabled
            }
            
            self.selectionStyle = .none
        }
    }
    
    static var identifier: String {
        return String(describing: self)
    }
}

class ScalePresetTableViewCell: UITableViewCell {
    var item: ScalePreset? {
        didSet {
            guard let item = item else {
                return
            }
            
            textLabel?.text = item.ratio
            detailTextLabel?.text = item.dimension
        }
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textLabel?.text = ""
        detailTextLabel?.text = ""
    }
}
