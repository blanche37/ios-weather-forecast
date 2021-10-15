//
//  LocationManager.swift
//  WeatherForecast
//
//  Created by yun on 2021/10/05.
//

import UIKit
import CoreLocation

class LocationManager: CLLocationManager {
    var address: String?
    var data: FiveDaysForecast?
    private var session = URLSession.shared
    func askUserLocation() {
        self.requestWhenInUseAuthorization()
        self.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let networkManager = NetworkManager()
        
        guard let longitude = manager.location?.coordinate.longitude,
              let latitude = manager.location?.coordinate.latitude,
              let fiveDaysUrl = URL(string: "https://api.openweathermap.org/data/2.5/forecast") else  {
            return
        }
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let geoCoder = CLGeocoder()
        let locale = Locale(identifier: "Ko-kr")
        geoCoder.reverseGeocodeLocation(location, preferredLocale: locale) { placeMarks, error in
            guard error == nil else {
                return
            }
            
            guard let addresses = placeMarks,
                  let address = addresses.last?.name else {
                return
            }
            
            self.address = address
        }

        let requestInfo: Parameters = ["lat": latitude, "lon": longitude, "appid": networkManager.apiKey]
        let fiveDaysWeatherApi = WeatherApi(httpTask: .request(withUrlParameters: requestInfo), httpMethod: .get, baseUrl: fiveDaysUrl)
        networkManager.getCurrentWeatherData(weatherAPI: fiveDaysWeatherApi, self.session) { requestedData in
            do {
                self.data = try JSONDecoder().decode(FiveDaysForecast.self, from: requestedData)
                print(self.data)
            } catch {
                print("Decoding Error")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        showAlert(title: "🙋‍♀️", message: "새로고침을 해주세요.")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied:
            showAlert(title: "❌", message: "날씨 정보를 사용 할 수 없습니다.")
            break
        case .authorizedWhenInUse, .authorizedAlways, .notDetermined:
            manager.requestLocation()
            break
        }
    }
    
    private func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Test", style: .default, handler: nil)
            alert.addAction(alertAction)
            ViewController().present(alert, animated: true, completion: nil)
        }
    }
}
