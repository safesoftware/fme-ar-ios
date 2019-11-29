//
//  Settings.swift
//  FMEAR
//
//  Created by Angus Lau on 2019-10-08.
//  Copyright © 2019 Safe Software Inc. All rights reserved.
//

import Foundation
import CoreLocation
import SceneKit

// Version 0
// Nothing specified

// Version 1
let kVersion = "version"
let kVersion1 = "1"
let kScaling = "scaling"
let kScalingFit = "fit"
let kScaling1To1 = "1to1"
// Example: {"version":"1","scaling":"fit"}
// Example: {"version":"1","scaling":"1to1"}

// Version 2
let kVersion2 = "2"
let kZoom = "zoom"
let kZoomYes = "yes"
let kZoomNo = "no"
let kAnchor = "anchor"
// Example: {"version":"2","scaling":"fit"}
// Example: {"version":"2","scaling":"fit","zoom":"no"}
// Example: {"version":"2","scaling":"1to1","zoom":"yes"}
// Example: {"version":"2","scaling":"1to1","zoom":"yes","anchor":"Beam"}

// Version 3
let kVersion3 = "3"
let kX = "x"
let kY = "y"
let kZ = "z"
let kLongitude = "longitude"
let kLatitude = "latitude"
// Deprecated: "scaling":"fit"
// Deprecated: "anchor":<feature type name>
// Example: {"version":"3","anchor":{"x":"5.23","y":"-2.56"}}
// Example: {"version":"3","anchor":{"x":"5.23","y":-2.56}}
// Example: {"version":"3","anchor":{"x":5.23,"y":"-2.56"}}
// Example: {"version":"3","scaling":"1to1","anchor":{"x":"5.23","y":"-2.56","z":"10"}}
// Example: {"version":"3","scaling":"1to1","anchor":{"x":"5.23","y":"-2.56","latitude":"45.678901","longitude":"123.456789"}}
// Example: {"version":"3","scaling":"1to1","anchor":{"x":5.23,"y":-2.56,"latitude":45.678901,"longitude":123.456789}}
// Example: {"version":"3","scaling":"1to1","anchor":{"latitude":"45.678901","longitude":"123.456789"}}
// Example: {"version":"3","scaling":"1to1","anchor":[{"x":"1.1","y":"-2.2","latitude":"3.3","longitude":"-4.4"},{"x":"5.5","y":"-6.6","latitude":"7.7","longitude":"-8.8"}]}
// Example: {"version":"3","scaling":"1to100"}
// Example: {"version":"3","scaling":"100to2.5"}
// Example: {"version":"3","scaling":"1:100"}
// Example: {"version":"3","scaling":"100:2.5"}
// Example: {"version":"3","scaling":"40"}
// Example: {"version":"3","scaling":"0.04"}
// Example: {"version":"3","scaling":40}
// Example: {"version":"3","scaling":0.04}

enum SettingsSerializationError: Error {
    case missing(String)
    case invalid(String, Any)
    case unsupported(String, Any)
    case invalidJsonDict(Any)
}

struct Anchor {
    
    var x: Double?
    var y: Double?
    var z: Double?
    var coordinate: CLLocationCoordinate2D?
}

class Settings {

    var version: String?
    var scaling: Double?
    var anchorFeatureType: String?
    var anchors: [Anchor] = []

    init() {}
    
    init(json: Any) throws {
        
        guard let jsonDict = json as? [String: Any] else {
            throw SettingsSerializationError.invalidJsonDict(json)
        }
        
        // Extract version
        guard let version = jsonDict[kVersion] as? String else {
            throw SettingsSerializationError.missing(kVersion)
        }
        
        switch version {
        case kVersion1: try extractVersion1Settings(json: jsonDict)
        case kVersion2: try extractVersion2Settings(json: jsonDict)
        case kVersion3: try extractVersion3Settings(json: jsonDict)
        default:
            throw SettingsSerializationError.unsupported("version", version)
        }
        
        self.version = version
    }
    
    func extractVersion1Settings(json: [String: Any]) throws {
        try extractScaling(json: json)
    }
        
    func extractVersion2Settings(json: [String: Any]) throws {
        try extractScaling(json: json)
        try extractZoom(json: json)
    }
    
    func extractVersion3Settings(json: [String: Any]) throws {
        try extractScaling(json: json)
        try extractAnchors(json: json)
    }
    
    func extractScaling(json: [String: Any]) throws {
        if let scaling = json[kScaling] {
            if let scalingValue = scaling as? Double {
                self.scaling = scalingValue
            } else if let scalingValue = scaling as? String {
                switch scalingValue {
                case kScalingFit: self.scaling = nil
                case kScaling1To1: self.scaling = 1
                default:
                    // Try parsing the value. The value should be in one of the
                    // three following formats:
                    // 1. <number>to<number>
                    // 2. <number>:<number>
                    // 3. <number>

                    if scalingValue.contains("to") {
                      let numbers = scalingValue.components(separatedBy: "to")
                      if numbers.count == 2 {
                          if let firstNum = Double(numbers.first!), let secondNum = Double(numbers.last!) {
                              if firstNum > 0.0 && secondNum > 0.0 {
                                  self.scaling = firstNum / secondNum
                                  break;
                              }
                          }
                      }
                    } else if scalingValue.contains(":") {
                      let numbers = scalingValue.components(separatedBy: ":")
                      if numbers.count == 2 {
                          if let firstNum = Double(numbers.first!), let secondNum = Double(numbers.last!) {
                              if firstNum > 0.0 && secondNum > 0.0 {
                                  self.scaling = firstNum / secondNum
                                  break;
                              }
                          }
                      }
                    } else {
                      if let number = Double(scalingValue) {
                          self.scaling = number
                          break;
                      }
                    }

                    print("SETTINGS ERROR: scaling = \(scalingValue) is not a valid value. It will be ignored")
                    throw SettingsSerializationError.invalid(kScaling, scalingValue)
                }
            }
        }
    }
    
    func extractZoom(json: [String: Any]) throws {
        if let zoom = json[kZoom] {
            guard let zoomValue = zoom as? String else {
                throw SettingsSerializationError.invalid(kZoom, zoom)
            }
            
            switch zoomValue {
            case kZoomYes:
                try extractAnchorFeatureType(json: json)
            case kZoomNo: fallthrough
            default:
                anchorFeatureType = nil
                anchors = []
            }
        }
    }

    func extractAnchorFeatureType(json: [String: Any]) throws {
        if let anchor = json[kAnchor] {
            guard let anchorValue = anchor as? String else {
                throw SettingsSerializationError.invalid(kAnchor, anchor)
            }
            
            self.anchorFeatureType = anchorValue
            self.anchors = []
        }
    }
    
    func extractAnchors(json: [String: Any]) throws {
        if let anchor = json[kAnchor] {
            
            if let anchorArray = anchor as? [[String: Any]] {
                // multiple anchors
                for dict in anchorArray {
                    try extractAnchor(json: dict)
                }
            } else if let anchorDict = anchor as? [String: Any] {
                // single anchor
                try extractAnchor(json: anchorDict)
            } else {
                throw SettingsSerializationError.invalid(kAnchor, anchor)
            }
        }
    }
    
    func extractAnchor(json: [String: Any]) throws {
        var anchor: Anchor?
        var x: Double?
        var y: Double?
        
        if let xString = json[kX] as? String {
            if let xDouble = Double(xString) {
                x = xDouble
            }
        } else if let xDouble = json[kX] as? Double {
            x = xDouble
        }
        
        if let yString = json[kY] as? String {
            if let yDouble = Double(yString) {
                y = yDouble
            }
        } else if let yDouble = json[kY] as? Double {
            y = yDouble
        }
        
        if let x = x, let y = y {
            anchor = Anchor()
            anchor?.x = x
            anchor?.y = y
        }
                
        if anchor != nil {
            if let zString = json[kZ] as? String {
                if let z = Double(zString) {
                    anchor?.z = z
                }
            }
        }
        
        do {
            if let coordinate = try extractCoordinate(json: json) {
                if anchor == nil {
                    anchor = Anchor()
                }
                anchor?.coordinate = coordinate
            }
        } catch {
            print("Settings: Coordinate is invalid")
        }
        
        if let anchor = anchor {
            self.anchors.append(anchor)
        }
    }
    
    func extractCoordinate(json: [String: Any]) throws -> CLLocationCoordinate2D? {
        var latitude: Double?
        var longitude: Double?
        
        if let latitudeString = json[kLatitude] as? String {
            if let latitudeDouble = Double(latitudeString) {
                latitude = latitudeDouble
            }
        } else if let latitudeDouble = json[kLatitude] as? Double {
            latitude = latitudeDouble
        }
        
        if let longitudeString = json[kLongitude] as? String {
            if let longitudeDouble = Double(longitudeString) {
                longitude = longitudeDouble
            }
        } else if let longitudeDouble = json[kLongitude] as? Double {
            longitude = longitudeDouble
        }
        
        if let latitude = latitude, let longitude = longitude {
            guard case (-90...90, -180...180) = (latitude, longitude) else {
                throw SettingsSerializationError.invalid(kAnchor, (latitude, longitude))
            }
            
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        } else {
            return nil
        }
    }
}




