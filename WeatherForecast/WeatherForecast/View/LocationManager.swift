//
//  LocationManager.swift
//  WeatherForecast
//
//  Created by yun on 2021/10/05.
//

import UIKit
import CoreLocation
import Alamofire

final class LocationManager: CLLocationManager {
    var address: String?
    var fiveDaysWeatherInfo: FiveDaysForecast?
    var currentWeatherInfo: CurrentWeather?
    
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
    private func parseCurrent(url: URL, param: [String: Any], completion: @escaping () -> Void) {
        AF.request(url, method: .get, parameters: param)
            .validate()
            .responseData { response in
                switch response.result {
                case let .success(data):
                    do {
                        self.currentWeatherInfo = try JSONDecoder().decode(CurrentWeather.self, from: data)
                        completion()
                    } catch {
                        print("DecodingError")
                    }
                case let .failure(error):
                    print(error)
                }
            }
    }
    
    private func parseFiveDays(url: URL, param: [String: Any], completion: @escaping () -> Void) {
        AF.request(url, method: .get, parameters: param)
            .validate()
            .responseData { response in
                switch response.result {
                case let .success(data):
                    do {
                        self.fiveDaysWeatherInfo = try JSONDecoder().decode(FiveDaysForecast.self, from: data)
                        completion()
                    } catch {
                        print("DecodingError")
                    }
                case let .failure(error):
                    print(error)
                }
            }
    }
    
    private func convertToAddress(with location: CLLocation, locale: Locale) {
        let geoCoder = CLGeocoder()
        
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
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let longitude = manager.location?.coordinate.longitude,
              let latitude = manager.location?.coordinate.latitude else { return }
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let locale = Locale(identifier: "Ko-kr")
        
        convertToAddress(with: location, locale: locale)

        let requestParam: [String: Any] = [
            "lat": latitude,
            "lon": longitude,
            "appid": "9cda367698143794391817f65f81c76e"
        ]
        
        parseCurrent(url: URLs.currentURL, param: requestParam) {
            NotificationCenter.default.post(name: Notification.Name.completion, object: nil, userInfo: nil)
        }
        parseFiveDays(url: URLs.fiveDaysURL, param: requestParam) {
            NotificationCenter.default.post(name: Notification.Name.dataIsNotNil, object: nil, userInfo: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let alertController = FailureAlertController()
        alertController.showAlert(title: "🙋‍♀️", message: "새로고침을 해주세요.")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        let alertController = FailureAlertController()
        switch status {
        case .restricted, .denied:
            alertController.showAlert(title: "❌", message: "날씨 정보를 사용 할 수 없습니다.")
        case .authorizedWhenInUse, .authorizedAlways, .notDetermined:
            manager.requestLocation()
        @unknown default:
            alertController.showAlert(title: "⚠️", message: "알수없는 에러")
        }
    }
}
