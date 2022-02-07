//
//  LocationManager.swift
//  WeatherForecast
//
//  Created by yun on 2021/10/05.
//

import CoreLocation

final class LocationManager: CLLocationManager {
    private func askUserLocation() {
        self.requestWhenInUseAuthorization()
        self.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        self.startUpdatingLocation()
    }
    
    override init() {
        super.init()
        askUserLocation()
    }
}
