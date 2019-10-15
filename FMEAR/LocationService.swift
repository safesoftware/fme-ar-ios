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
}

class LocationService: NSObject, CLLocationManagerDelegate {
    
    var delegate: LocationServiceDelegate?
    
    var locationManager: CLLocationManager?
    var location: CLLocation?
    var heading: CLHeading?
    var authorizationStatus: CLAuthorizationStatus?
    var error: Error?
    
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
        var locationNotAvailable = false
        var headingNotAvailable = false
        
        if let location = location {
            let latitude = String(format: "%.6f", location.coordinate.latitude)
            let longitude = String(format: "%.6f", location.coordinate.longitude)
            d += " ⍋ \(latitude), \(longitude) "
        } else {
            d += " ⍋ ---, --- "
            locationNotAvailable = true
        }
        
        if let heading = heading {
            let trueHeading = String(format: "%.0f", heading.trueHeading)
            let direction = directionText(degree: heading.trueHeading)
            d += " 🧭 \(trueHeading)° \(direction) "
        } else {
            d += " 🧭 ---° "
            headingNotAvailable = true
        }
        
        if let status = authorizationStatus {
            switch (status) {
            case .notDetermined:
                d += " (Not Determined) "
            case .restricted:
                d += " (Restricted Access) "
            case .denied:
                d += " (Denied Access) "
            case .authorizedAlways:
                break;
            case .authorizedWhenInUse:
                break;
            @unknown default:
                break;
            }
        }
        
        if let error = error {
            switch (error) {
            case CLError.Code.locationUnknown:
                d += " (Determining) "
            case CLError.Code.headingFailure:
                d += " (Interference) "
            case CLError.Code.denied:
                d += " (Denied Access) "
            default:
                d += " (Unknown Error) "
            }
        }

        if (locationNotAvailable || headingNotAvailable) {
            d += " (Not Available) "
        }

        return d
    }
    
    func notifyDelegate() {
        if delegate != nil {
            delegate?.didUpdateDescription(self, description: description())
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
        self.error = nil
        notifyDelegate()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.error = error
        print("ERROR: \(error)")
        stopLocationService()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading
        self.error = nil
        notifyDelegate()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.location = location
            self.error = nil
            notifyDelegate()
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
