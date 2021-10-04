//
//  LocationManager.swift
//  WeatherForecast
//
//  Created by Do Yi Lee on 2021/10/03.
//

import Foundation
import CoreLocation

class LocationManager: CLLocationManager {
    
    func askUserLocation() {
        self.requestWhenInUseAuthorization()
        
//        self.distanceFilter = CLLocationDistanceMax
        self.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }
    
    func test() {
        self.requestLocation()
    }
}