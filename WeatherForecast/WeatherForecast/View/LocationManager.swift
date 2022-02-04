//
//  LocationManager.swift
//  WeatherForecast
//
//  Created by yun on 2021/10/05.
//

import UIKit
import CoreLocation

final class LocationManager: CLLocationManager {
    var address: String?
    var fiveDaysWeatherInfo: FiveDaysForecast?
    var currentWeatherInfo: CurrentWeather?
    private var session = URLSession.shared
    private var alertController = FailureAlertController()
    
    private func askUserLocation() {
        self.requestWhenInUseAuthorization()
        self.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        self.startUpdatingLocation()
    }
    
    override init() {
        super.init()
        self.delegate = self
        askUserLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    private func parseCurrent(networkManager: NetworkManager, weatherApi: WeatherApi, session: URLSession, completion: @escaping () -> Void) {
        networkManager.getWeatherData(with: weatherApi, session) { requestedData
            in
            do {
                self.currentWeatherInfo = try JSONDecoder().decode(CurrentWeather.self, from: requestedData)
                completion()
            } catch {
                print("Decode Error")
            }
        }
    }
    
    private func parseFiveDays(networkManager: NetworkManager, weatherApi: WeatherApi, session: URLSession, completion: @escaping () -> Void) {
        networkManager.getWeatherData(with: weatherApi, session) { requestedData in
            do {
                self.fiveDaysWeatherInfo = try JSONDecoder().decode(FiveDaysForecast.self, from: requestedData)
                completion()
            } catch {
                print("Decoding Error")
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let networkManager = NetworkManager()
        guard let longitude = manager.location?.coordinate.longitude,
              let latitude = manager.location?.coordinate.latitude,
              let fiveDaysURL = URL(string: "https://api.openweathermap.org/data/2.5/forecast"),
        let currentWeatherURL = URL(string: "https://api.openweathermap.org/data/2.5/weather")
        else  {
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
        let fiveDaysWeatherAPI = WeatherApi(httpTask: .request(withUrlParameters: requestInfo), httpMethod: .get, baseUrl: fiveDaysURL)
        let currentWeatherAPI = WeatherApi(httpTask: .request(withUrlParameters: requestInfo), httpMethod: .get, baseUrl: currentWeatherURL)
        parseCurrent(networkManager: networkManager, weatherApi: currentWeatherAPI, session: self.session) {
            NotificationCenter.default.post(name: Notification.Name.completion, object: nil, userInfo: nil)
        }
        
        parseFiveDays(networkManager: networkManager, weatherApi: fiveDaysWeatherAPI, session: self.session) {
            NotificationCenter.default.post(name: Notification.Name.dataIsNotNil, object: nil, userInfo: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        alertController.showAlert(title: "🙋‍♀️", message: "새로고침을 해주세요.")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied:
            alertController.showAlert(title: "❌", message: "날씨 정보를 사용 할 수 없습니다.")
            break
        case .authorizedWhenInUse, .authorizedAlways, .notDetermined:
            manager.requestLocation()
            break
        @unknown default:
            alertController.showAlert(title: "⚠️", message: "알수없는 에러")
        }
    }
}
