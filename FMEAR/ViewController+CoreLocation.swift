//
//  ViewController+CoreLocation.swift
//  FMEAR
//
//  Created by Angus Lau on 2019-10-02.
//  Copyright © 2019 Safe Software Inc. All rights reserved.
//


import UIKit
import CoreLocation

extension ViewController: CLLocationManagerDelegate {
     
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
    
    func unknownHeadingText() -> String {
        return "🧭 ---°"
    }
    
    func unknownHeadingAccuracyText() -> String {
        return " ± --°"
    }
    
    func directionText(degree: CLLocationDirection) -> String {
        let directions = [ "N", "NE", "E", "SE", "S", "SW", "W", "NW", "N" ]
        let index: Int = min(max(Int((degree + 22.5) / 45.0), 0), 8)
        return directions[index]
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("locationManager:didChangeAuthorization")
        switch (status) {
        case .notDetermined:
            headingLabel.text = unknownHeadingText() + " (Not Determined)"
        case .restricted:
            headingLabel.text = unknownHeadingText() + " (Restricted Access)"
        case .denied:
            headingLabel.text = unknownHeadingText() + " (Denied Access)"
        case .authorizedAlways:
            headingLabel.text = unknownHeadingText()
        case .authorizedWhenInUse:
            headingLabel.text = unknownHeadingText()
        @unknown default:
            headingLabel.text = unknownHeadingText() + " (Unknown Heading)"
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("locationManager:didFailWithError")
        switch (error) {
        case CLError.Code.locationUnknown:
            headingLabel.text = unknownHeadingText() + " (Determining)"
        case CLError.Code.headingFailure:
            headingLabel.text = unknownHeadingText() + " (Interference)"
        case CLError.Code.denied:
            headingLabel.text = unknownHeadingText() + " (Denied Access)"
            stopLocationService()
        default:
            headingLabel.text = unknownHeadingText() + " (Unknown Error)"
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        print("locationManager:didUpdateHeading - \(newHeading.magneticHeading), \(newHeading.trueHeading)")
        let trueHeading = newHeading.trueHeading.format(f: ".0")
        let direction = directionText(degree: newHeading.trueHeading)
        if newHeading.trueHeading >= 0.0 {
            headingLabel.text = "🧭 \(trueHeading)° \(direction)"
        } else {
            headingLabel.text = unknownHeadingText()
        }
    }
    
    // MARK: - Device Orientation
    @objc func handleDeviceOrientationDidChange() {
        print("device orientation did change: \(UIDevice.current.orientation.rawValue)")
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
