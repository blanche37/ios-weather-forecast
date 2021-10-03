//
//  WeatherForecast - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    private var locationManager = LocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.askUserLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let locationValue: CLLocationCoordinate2D = manager.location?.coordinate else {
            return
        }
        print("locations = \(locationValue.latitude) \(locationValue.longitude)")
        print(locations)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied:
            disableMyLocationBasedFeatures()
            break
            
        case .authorizedWhenInUse:
            enableMyLocationFeatures()
            break
            
        case .authorizedAlways:
            enableMyAlwaysFeatures()
            break
            
        case .notDetermined:
            break
        }
    }
    
    
    func disableMyLocationBasedFeatures() {
    }
    
    func enableMyLocationFeatures() {
    }
    
    func enableMyAlwaysFeatures() {
    }
}

