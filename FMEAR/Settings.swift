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

// Version 3 - FME 2019.2
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

// Version 4 - FME 2020.0
let kVersion4 = "4"
let kViewpoints = "viewpoints"
let kName = "name"
let kMetadata = "metadata"
let kGlobal = "fmear_global"
let kModelExpiry = "fmear_model_expiry"
// Example: Initial Model Scaling = <Empty>:      {"version":"4","viewpoints":[]}
// Example: Initial Model Scaling = Fit:          {"version":"4","scaling":"fit","viewpoints":[]}
// Example: Initial Model Scaling = Full Scale:   {"version":"4","scaling":"1to1","viewpoints":[]}
// Example: Initial Model Scaling = Custom = 1:   {"version":"4","scaling":"1","viewpoints":[]}
// Example: Initial Model Scaling = Custom = 0.2: {"version":"4","scaling":"0.2","viewpoints":[]}
// Example: Initial Model Scaling = Fit, One viewpoint:
//     {"version":"4","scaling":"fit","viewpoints":[{"x":-99.69291200000043,"y":851.8795360000004}]}
// Example: Initial Model Scaling = Fit, One viewpoint with a name:
//     {"version":"4","scaling":"fit","viewpoints":[{"x":-99.69291200000043,"y":851.8795360000004,"name":"x4000y4000"}]}
// Example: Initial Model Scaling = Fit, Multiple viewpoints with names:
//     {"version":"4","scaling":"fit","viewpoints":[
//         {"x":15900.307088,"y":4851.879536,"name":"x20000y-8000"},
//         {"x":-9099.692912,"y":-23148.120464,"name":"x-5000y-20000"},
//         {"x":-99.69291200000043,"y":851.8795360000004,"name":"x4000y4000"}
//     ]}
// Example: Intial Model Scaling = Fit, Multiple viewpoints with names, geolocated anchor without coordinate:
//     {"version":"4","scaling":"fit","anchor":{"latitude":49.178121,"longitude":-122.842716},"viewpoints":[
//         {"x":15900.307088,"y":4851.879536,"name":"x20000y-8000"},
//         {"x":-9099.692912,"y":-23148.120464,"name":"x-5000y-20000"},
//         {"x":-99.69291200000043,"y":851.8795360000004,"name":"x4000y4000"}
//     ]}
// Example: Initial Model Scaling = Fit, No viewpoints, geolocated anchor without coordinate:
//     {"version":"4","scaling":"fit","anchor":{"latitude":49.178121,"longitude":-122.842716},"viewpoints":[]}
// Example: Initial Model Scaling = Fit, Multiple viewpoints with names, anchor located at the last viewpoint
//     {"version":"4","scaling":"fit","anchor":{"latitude":49.178121,"longitude":-122.842716,"x":-99.69291200000043,"y":851.8795360000004},"viewpoints":[
//         {"x":15900.307088,"y":4851.879536,"name":"x20000y-8000"},
//         {"x":-9099.692912,"y":-23148.120464,"name":"x-5000y-20000"},
//         {"x":-99.69291200000043,"y":851.8795360000004,"name":"x4000y4000"}
//     ]}
// Example: Initial Model Scaling = Fit, Multiple viewpoints with names, anchor not located at any of the viewpoints
//     {"version":"4","scaling":"fit","anchor":{"latitude":49.178121,"longitude":-122.842716,"x":900.3070879999996,"y":1851.8795360000004},"viewpoints":[
//         {"x":15900.307088,"y":4851.879536,"name":"x20000y-8000"},
//         {"x":-9099.692912,"y":-23148.120464,"name":"x-5000y-20000"},
//         {"x":-99.69291200000043,"y":851.8795360000004,"name":"x4000y4000"}
//     ]}
// Example: Initial Model Scaling = Fit, Multiple viewpoints with names, anchor with z
//     {"version":"4","scaling":"fit","anchor":{"latitude":49.178121,"longitude":-122.842716,"x":-99.69291200000043,"y":851.8795360000004,"z":7264},"viewpoints":[
//         {"x":15900.307088,"y":4851.879536,"z":7264,"name":"x20000y-8000"},
//         {"x":-9099.692912,"y":-23148.120464,"z":7264,"name":"x-5000y-20000"},
//         {"x":-99.69291200000043,"y":851.8795360000004,"z":7264,"name":"x4000y4000"}
//     ]}
// {"version":"4","viewpoints":[{"x":-1,"y":-2.5,"z":10,"name":"Viewpoint at (0,0,10)"}],"metadata":{"fmear_global":{"fmear_model_expiry":"20170206111730.135-08:00"}}}

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

// Viewpoint is in FME coordinate system, i.e. z is the elevation
struct Viewpoint {
    var x: Double?
    var y: Double?
    var z: Double?
    var name: String?
    let id: UUID
    
    init() {
        id = UUID()
    }
}

// Version 4+
struct Metadata {
    
    // Global
    var modelExpiry: Date?
}

class Settings {

    var version: String?
    
    // Version 1+
    var scaling: Double?
    
    // Version 2 - We have never supported this in the mobile app
    var anchorFeatureType: String?
    
    // Version 3 - We only use the first anchor, which may or may not have
    // a geolocation
    // Version 4 - We only use the first anchor, which must have a geolocation
    // but may not have a x,y,z coordinate in model coordinate. When the
    // coordinate is not set, the values will be set as 0.
    var anchors: [Anchor] = []
    
    // Version 4
    var viewpoints: [Viewpoint] = []
    var metadata: Metadata?
   

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
        case kVersion4: try extractVersion4Settings(json: jsonDict)
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
    
    func extractVersion4Settings(json: [String: Any]) throws {
        try extractScaling(json: json)
        try extractViewpoints(json: json)
        try extractGeolocatedAnchor(json: json)
        try extractMetadata(json: json)
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
    
    func extractViewpoints(json: [String: Any]) throws {
        if let viewpoints = json[kViewpoints] {
            if let viewpointArray = viewpoints as? [[String: Any]] {
                // one or more viewpoints
                for dict in viewpointArray {
                    try extractViewpoint(json: dict)
                }
            } else if let viewpointDict = viewpoints as? [String: Any] {
                // single anchor
                try extractViewpoint(json: viewpointDict)
            } else {
                throw SettingsSerializationError.invalid(kViewpoints, viewpoints)
            }
        }
    }
    
    func extractViewpoint(json: [String: Any]) throws {
        var viewpoint: Viewpoint?
        var x: Double?
        var y: Double?
        var name: String?
        
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
        
        name = json[kName] as? String

        if let x = x, let y = y {
            viewpoint = Viewpoint()
            viewpoint?.x = x
            viewpoint?.y = y
            viewpoint?.name = name
        }
                
        if viewpoint != nil {
            if let zString = json[kZ] as? String {
                if let z = Double(zString) {
                    viewpoint?.z = z
                }
            } else if let zDouble = json[kZ] as? Double {
                viewpoint?.z = zDouble
            }
        }
        
        if let viewpoint = viewpoint {
            self.viewpoints.append(viewpoint)
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
    
    func extractGeolocatedAnchor(json: [String: Any]) throws {
        if let anchorDict = json[kAnchor] as? [String: Any] {
            do {
                if let coordinate = try extractCoordinate(json: anchorDict) {
                    var anchor = Anchor()
                    anchor.coordinate = coordinate
                    
                    if let xString = anchorDict[kX] as? String {
                        if let xDouble = Double(xString) {
                            anchor.x = xDouble
                        }
                    } else if let xDouble = anchorDict[kX] as? Double {
                        anchor.x = xDouble
                    }
                    
                    if let yString = anchorDict[kY] as? String {
                        if let yDouble = Double(yString) {
                            anchor.y = yDouble
                        }
                    } else if let yDouble = anchorDict[kY] as? Double {
                        anchor.y = yDouble
                    }

                    if let zString = anchorDict[kZ] as? String {
                        if let zDouble = Double(zString) {
                            anchor.z = zDouble
                        }
                    } else if let zDouble = anchorDict[kZ] as? Double {
                        anchor.z = zDouble
                    }
                    
                    self.anchors.append(anchor)
                }
            } catch {
                print("Settings: Coordinate is invalid")
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
            } else if let zDouble = json[kZ] as? Double {
                anchor?.z = zDouble
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
    
    func extractMetadata(json: [String: Any]) throws {
        if let metadata = json[kMetadata] as? [String: Any] {
            
            // Global metadata
            if let globalMetadata = metadata[kGlobal] as? [String: Any] {
                
                // Model expiry
                if let expiry = globalMetadata[kModelExpiry] as? String {
                    
                    print("MODEL EXPIRY: \(expiry)")
                    if let date = getDate(fmeDateString: expiry) {
                        print("DATE: \(date)")
                    } else {
                        print("DATE: INVALID")
                    }
                }
            }
        }
    }
    
    func getDate(fmeDateString: String) -> Date? {
        
        let fmeDateParser = DateFormatter()
        
        // When working with fixed format dates, we should also set the locale
        // property to a POSIX locale ("en_US_POSIX"), and set the timeZone
        // property to UTC.
        // REFERENCE: https://developer.apple.com/documentation/foundation/dateformatter
        fmeDateParser.locale = Locale(identifier: "en_US_POSIX")
        fmeDateParser.timeZone = TimeZone(secondsFromGMT: 0)

        // FME Date Time Format
        let fmeDateFormat = "yyyyMMdd"
        let fmeTimeFormat = "HHmmss"
        let fmeFractionalSecondFormat = ".SSSSSSSSS"
        let fmeTimeZoneFormat = "ZZZZZ"
        
        // Date only
        fmeDateParser.dateFormat = fmeDateFormat
        if let date = fmeDateParser.date(from: fmeDateString) {
            return date
        }

        // Time only
        fmeDateParser.dateFormat = fmeTimeFormat
        if var date = fmeDateParser.date(from: fmeDateString) {
            return date
        }
        
        // Time with fractional second
        fmeDateParser.dateFormat = "\(fmeTimeFormat)\(fmeFractionalSecondFormat)"
        if let date = fmeDateParser.date(from: fmeDateString) {
            return date
        }
        
        // Time with time zone
        fmeDateParser.dateFormat = "\(fmeTimeFormat)\(fmeTimeZoneFormat)"
        if let date = fmeDateParser.date(from: fmeDateString) {
            return date
        }
        
        // Time with fractional second and time zone
        fmeDateParser.dateFormat = "\(fmeTimeFormat)\(fmeFractionalSecondFormat)\(fmeTimeZoneFormat)"
        if let date = fmeDateParser.date(from: fmeDateString) {
            return date
        }
        
        // Date and time
        fmeDateParser.dateFormat = "\(fmeDateFormat)\(fmeTimeFormat)"
        if let date = fmeDateParser.date(from: fmeDateString) {
            return date
        }
        
        // Date and time with fractional second
        fmeDateParser.dateFormat = "\(fmeDateFormat)\(fmeTimeFormat)\(fmeFractionalSecondFormat)"
        if let date = fmeDateParser.date(from: fmeDateString) {
            return date
        }
        
        // Date and time with time zone
        fmeDateParser.dateFormat = "\(fmeDateFormat)\(fmeTimeFormat)\(fmeTimeZoneFormat)"
        if let date = fmeDateParser.date(from: fmeDateString) {
            return date
        }
        
        // Date and time with fractional second and time zone
        fmeDateParser.dateFormat = "\(fmeDateFormat)\(fmeTimeFormat)\(fmeFractionalSecondFormat)\(fmeTimeZoneFormat)"
        if let date = fmeDateParser.date(from: fmeDateString) {
            return date
        }
        
        return nil
    }
}




