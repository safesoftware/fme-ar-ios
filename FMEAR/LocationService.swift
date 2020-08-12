//
//  ViewController+CoreLocation.swift
//  FMEAR
//
//  Created by Angus Lau on 2019-10-02.
//  Copyright © 2019 Safe Software Inc. All rights reserved.
//


import UIKit
import CoreLocation

protocol LocationServiceDelegate {
    // This function is called when the description text is updated because of
    // one of the location, heading, authorization status, or error has changed.
    func didUpdateDescription(_ locationService: LocationService, description: String)
    
    func didUpdateLocation(_ locationService: LocationService, location: CLLocation)
}

class LocationService: NSObject, CLLocationManagerDelegate {
    
    var delegate: LocationServiceDelegate?
    
    var locationManager: CLLocationManager?
    var location: CLLocation?
    var heading: CLHeading?
    var authorizationStatus: CLAuthorizationStatus?
    var error: CLError?
    
    override init() {
        super.init()
        initLocationManager()
    }
    
    func initLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager?.headingFilter = kCLHeadingFilterNone
    }
    
    func startLocationService() {
        if CLLocationManager.headingAvailable() {
            locationManager?.startUpdatingHeading()
        }
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager?.startUpdatingLocation()
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleDeviceOrientationDidChange),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
        
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
    }
    
    func stopLocationService() {
        if CLLocationManager.headingAvailable() {
            locationManager?.stopUpdatingHeading()
        }
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager?.stopUpdatingLocation()
        }
        
        NotificationCenter.default.removeObserver(self,
                                                  name: UIDevice.orientationDidChangeNotification,
                                                  object: nil)
        
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }
    
    func description() -> String {
        var d = ""
        
        var locationAvailable = true
        var headingAvailable = true
        if let error = error {
            switch error.code {
            case .headingFailure:
                headingAvailable = false
            case .denied:
                locationAvailable = false
                headingAvailable = false
            default:
                locationAvailable = false
            }
        }
        
        if let status = authorizationStatus {
            switch status {
            case .denied: fallthrough
            case .notDetermined: fallthrough
            case .restricted:
                locationAvailable = false
                headingAvailable = false
            default:
                break
            }
        }
        
        if let location = location, locationAvailable {
            let latitude = String(format: "%.6f", location.coordinate.latitude)
            let longitude = String(format: "%.6f", location.coordinate.longitude)
            let accuracy = String(format: "%.0f", location.horizontalAccuracy)
            d += " ⍋ \(latitude), \(longitude) ± \(accuracy)m"
        } else {
            d += " ⍋ Location Not Available "
        }
        
        if let heading = heading, headingAvailable {
            let roundedHeading = (heading.trueHeading).truncatingRemainder(dividingBy: 360.0).rounded(.down)
            let trueHeading = String(format: "%.0f", roundedHeading)
            let direction = directionText(degree: roundedHeading)
            d += " 🧭 \(trueHeading)° \(direction) "
        } else {
            d += " 🧭 Heading Not Available "
        }

        return d
    }
    
    func notifyDelegateNewDescription() {
        if delegate != nil {
            delegate?.didUpdateDescription(self, description: description())
        }
    }
    
    func notifyDelegateNewLocation(location: CLLocation) {
        if delegate != nil {
            delegate?.didUpdateLocation(self, location: location)
        }
    }
    
    func directionText(degree: CLLocationDirection) -> String {
        let directions = [ "N", "NE", "E", "SE", "S", "SW", "W", "NW", "N" ]
        let index: Int = min(max(Int((degree + 22.5) / 45.0), 0), 8)
        return directions[index]
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        
        switch status {
            case .denied: fallthrough
            case .notDetermined: fallthrough
            case .restricted:
                stopLocationService()
        default:
            break
        }
        
        self.error = nil
        notifyDelegateNewDescription()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("ERROR: \(error)")
        
        // If the user denies your app's use of the location service,
        // this method reports a CLError.Code.denied error.
        // Upon receiving such an error, you should stop the location service.
        // https://developer.apple.com/documentation/corelocation/cllocationmanagerdelegate/1423786-locationmanager
        if let error = error as? CLError {
            self.error = error
            if error.code == CLError.Code.denied {
                stopLocationService()
            }
        } else {
            // We don't know what error we receive. Stop the service to be safe
            stopLocationService()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading
//        print("new heading: \(newHeading)")
        self.error = nil
        notifyDelegateNewDescription()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.location = location
            self.error = nil
            notifyDelegateNewDescription()
            notifyDelegateNewLocation(location: location)
        }
    }
    
    // MARK: - Device Orientation
    @objc func handleDeviceOrientationDidChange() {
        switch UIDevice.current.orientation {
        case .faceUp:
            locationManager?.headingOrientation = CLDeviceOrientation.faceUp
        case .unknown:
            break;   // Do nothing
        case .portrait:
            locationManager?.headingOrientation = CLDeviceOrientation.portrait
        case .portraitUpsideDown:
            locationManager?.headingOrientation = CLDeviceOrientation.portraitUpsideDown
        case .landscapeLeft:
            locationManager?.headingOrientation = CLDeviceOrientation.landscapeLeft
        case .landscapeRight:
            locationManager?.headingOrientation = CLDeviceOrientation.landscapeRight
        case .faceDown:
            locationManager?.headingOrientation = CLDeviceOrientation.faceDown
        @unknown default:
            break;   // Do nothing
        }
    }
}
