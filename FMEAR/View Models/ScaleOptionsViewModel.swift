//
//  ScaleOptionsViewModel.swift
//  FMEAR
//
//  Created by Angus Lau on 2019-09-13.
//  Copyright © 2019 Safe Software Inc. All rights reserved.
//

import Foundation
import UIKit

// MARK: Row index
let kTableViewRowScaleModeRowIndex = 0
let kTableViewRowScaleLockRowIndex = 1

enum ScaleMode: String {
    case fullScale
    case customScale
}

enum ScaleOption: String {
    case scaleMode
    case scaleLockEnabled
    case scale
    
    static func registerDefaults() {
        UserDefaults.standard.register(defaults: [
            ScaleOption.scaleMode.rawValue: ScaleMode.customScale.rawValue,
            ScaleOption.scaleLockEnabled.rawValue: false,
            ScaleOption.scale.rawValue: 1.0,
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
    
    func float(for scaleOption: ScaleOption) -> Float {
        return float(forKey: scaleOption.rawValue)
    }
    
    func set(_ float: Float, for scaleOption: ScaleOption) {
        set(float, forKey: scaleOption.rawValue)
    }
    
    func string(for scaleOption: ScaleOption) -> String? {
        return string(forKey: scaleOption.rawValue)
    }
    
    func set(_ string: String, for scaleOption: ScaleOption) {
        set(string, forKey: scaleOption.rawValue)
    }
}

class ScalePreset {
    var ratio: String?
    var dimension: String?
    var scale: Float
    
    init(scale: Float, dimension: [Float]) {
        self.scale = scale
        self.ratio = scaleText(scale: scale)
        self.dimension = dimensionText(dimension: dimension, scale: scale)
    }
    
    func scaleText(scale: Float) -> String {
        let formatter = NumberFormatter()
        formatter.usesSignificantDigits = true
        formatter.maximumSignificantDigits = 3
        formatter.minimumSignificantDigits = 1
        
        var text = "- : -"
        if (scale > 1.0) {
            var adjustedScale = scale
            var unit = ""
            if scale >= 1000.0 {
                adjustedScale = scale / 1000.0
                unit = "k"
            }
            if let roundedScale = formatter.string(from: NSNumber(value: adjustedScale)) {
                text = "\(roundedScale)\(unit) : 1"
            }
        } else if (scale <= 0.0) {
            text = "∞"
        } else if (scale <= 1.0) {
            var adjustedScale = 1.0 / scale
            var unit = ""
            if adjustedScale >= 1000.0 {
                adjustedScale = adjustedScale / 1000.0
                unit = "k"
            }
            
            //let roundedScale = (1.0 / objectScale).rounded().format(f: ".0")
            if let roundedScale = formatter.string(from: NSNumber(value: adjustedScale)) {
                text = "1 : \(roundedScale)\(unit)"
            }
        }
        
        return text
    }
    
    func lengthText(_ length: Float) -> String {
        let formatter = NumberFormatter()
        formatter.usesSignificantDigits = true
        formatter.maximumSignificantDigits = 3
        formatter.minimumSignificantDigits = 2
        
        var adjustedLength = length
        var text = "--"
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
            text = roundedLength + unit
        }
        
        return text
    }
    
    func dimensionText(dimension: [Float], scale: Float) -> String {
        if dimension.isEmpty {
            return ""
        } else {
            return dimension.map { lengthText($0 * scale) }.joined(separator: " x ")
        }
    }
}

enum ScaleOptionViewModelItemType {
    case scaleMode
    case scalePreset
}

protocol ScaleOptionViewModelItem {
    var type: ScaleOptionViewModelItemType { get }
    var rowCount: Int { get }
    var sectionTitle: String { get }
}

extension ScaleOptionViewModelItem {
    var rowCount: Int {
        return 1
    }
}

class ScaleOptionViewModelScaleModeItem : ScaleOptionViewModelItem {
    init(scaleMode: ScaleMode, scaleLockEnabled: Bool) {
        self.scaleMode = scaleMode
        self.scaleLockEnabled = scaleLockEnabled
    }
    
    var type: ScaleOptionViewModelItemType {
        return .scaleMode
    }
    
    var rowCount: Int {
        return 2 // Scale (Full or Custom), and Scale Lock
    }
    
    var sectionTitle: String {
        return "Scale Mode"
    }
    
    var scaleMode: ScaleMode
    var scaleLockEnabled: Bool
}

class ScaleOptionViewModelScalePresetItem : ScaleOptionViewModelItem {
    var type: ScaleOptionViewModelItemType {
        return .scalePreset
    }
    
    var dimension: [Float] = []
    var scales: [Float] = []
    var currentScale: Float = 1.0
    
    init(dimension: [Float], scales: [Float], currentScale: Float) {
        self.dimension = dimension
        self.scales = scales
        self.currentScale = currentScale
    }
    
    var rowCount: Int {
        return scales.count + 1 // including the current scale
    }
    
    var sectionTitle: String {
        return "Custom Scale Presets"
    }
}

class ScaleOptionModel {
    
    func loadUserDefaults() {
        let defaults = UserDefaults.standard
        
        switch defaults.string(for: .scaleMode) {
        case ScaleMode.fullScale.rawValue:
            scaleMode = .fullScale
        case ScaleMode.customScale.rawValue:
            scaleMode = .customScale
        default:
            scaleMode = .customScale
        }
        
        scaleLockEnabled = defaults.bool(for: .scaleLockEnabled)

        //scaleModeSegmentedControl.selectedSegmentIndex = max(min(scaleMode, 1), 0)
        //scaleLockSwitch.isOn = defaults.bool(for: .scaleLockEnabled)
    }
    
    init() {
        loadUserDefaults()
    }
    
    let scales: [Float] = [
        100,
        10,
        5,
        2,
        1,
        1 / 2,
        1 / 5,
        1 / 10,
        1 / 20,
        1 / 50,
        1 / 100,
        1 / 200,
        1 / 400,
        1 / 1000
    ]
    
    var scaleMode = ScaleMode.customScale {
        didSet {
            UserDefaults.standard.set(scaleMode.rawValue, for: .scaleMode)
        }
    }
    
    var scaleLockEnabled = false {
        didSet {
            UserDefaults.standard.set(scaleLockEnabled, for: .scaleLockEnabled)
        }
    }
    
    var currentScale: Float = 1.0 {
        didSet {
            UserDefaults.standard.set(currentScale, for: .scale)
        }
    }
}

class ScaleOptionViewModel: NSObject {
    
    fileprivate let model = ScaleOptionModel()
    
    var items = [ScaleOptionViewModelItem]()
    var scaleModeItem: ScaleOptionViewModelScaleModeItem
    var scalePresetItem: ScaleOptionViewModelScalePresetItem

    required init(dimension: [Float], currentScale: Float) {
        self.scaleMode = model.scaleMode
        self.scaleLockEnabled = model.scaleLockEnabled
        self.currentScale = currentScale
        
        items.removeAll()
        scaleModeItem = ScaleOptionViewModelScaleModeItem(scaleMode: model.scaleMode, scaleLockEnabled: model.scaleLockEnabled)
        items.append(scaleModeItem)
        
        scalePresetItem = ScaleOptionViewModelScalePresetItem(dimension: dimension, scales: model.scales, currentScale: currentScale)
        items.append(scalePresetItem)
    }
    
    var scaleMode = ScaleMode.customScale {
        didSet {
            model.scaleMode = scaleMode
            scaleModeItem.scaleMode = scaleMode
        }
    }

    var scaleLockEnabled = false {
        didSet {
            model.scaleLockEnabled = scaleLockEnabled
            scaleModeItem.scaleLockEnabled = scaleLockEnabled
        }
    }
    
    var currentScale: Float = 1.0 {
        didSet {
            model.currentScale = currentScale
            scalePresetItem.currentScale = currentScale
        }
    }
}

extension ScaleOptionViewModel: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].rowCount
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return items[section].sectionTitle
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.section]
        
        switch item.type {
        case .scaleMode:
            if indexPath.row == kTableViewRowScaleModeRowIndex {
                if let cell = tableView.dequeueReusableCell(withIdentifier: ScaleModeTableViewCell.identifier, for: indexPath) as? ScaleModeTableViewCell {
                    cell.item = item
                    return cell
                }
            } else if indexPath.row == kTableViewRowScaleLockRowIndex {
                if let cell = tableView.dequeueReusableCell(withIdentifier: ScaleLockTableViewCell.identifier, for: indexPath) as? ScaleLockTableViewCell {
                    cell.item = item

                    if (scaleMode == .fullScale) {
                        cell.isUserInteractionEnabled = false
                    } else {
                        cell.isUserInteractionEnabled = true
                    }
                    
                    return cell
                }
            }
        case .scalePreset:
            if let item = item as? ScaleOptionViewModelScalePresetItem, let cell = tableView.dequeueReusableCell(withIdentifier: ScalePresetTableViewCell.identifier, for: indexPath) as? ScalePresetTableViewCell {
                
                if (indexPath.row == 0) {
                    // Show the current scale
                    cell.item = ScalePreset(scale: item.currentScale, dimension: item.dimension)
                } else {
                    cell.item = ScalePreset(scale: item.scales[indexPath.row - 1], dimension: item.dimension)
                }
                
                if (scaleMode == .fullScale) {
                    cell.isUserInteractionEnabled = false
                } else {
                    cell.isUserInteractionEnabled = true
                }

                return cell
            }
        }
        
        return UITableViewCell()
    }
}
