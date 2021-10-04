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
        locationManager.test()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let locationValue: CLLocationCoordinate2D = manager.location?.coordinate else {
            return
        }
        lookUpCurrentLocation { place in
            print(place?.name)
        }
        
    }
    
    func lookUpCurrentLocation(completionHandler: @escaping (CLPlacemark?)
                    -> Void ) {
        // Use the last reported location.
        if let lastLocation = self.locationManager.location {
            let geocoder = CLGeocoder()
                
            // Look up the location and pass it to the completion handler
            geocoder.reverseGeocodeLocation(lastLocation,
                        completionHandler: { (placemarks, error) in
                if error == nil {
                    let firstLocation = placemarks?[0]
                    completionHandler(firstLocation)
                }
                else {
                 // An error occurred during geocoding.
                    completionHandler(nil)
                }
            })
        }
        else {
            // No location was available.
            completionHandler(nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied:
            disableMyLocationBasedFeatures()
            break
            
        case .authorizedWhenInUse:
            enableMyLocationFeatures()
            //locationManager.test()
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

