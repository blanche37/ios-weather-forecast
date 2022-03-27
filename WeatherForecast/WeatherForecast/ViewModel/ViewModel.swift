//
//  ViewModel.swift
//  WeatherForecast
//
//  Created by yun on 2022/03/26.
//

import UIKit
import Alamofire

protocol ViewModel {
    var currentInfo: Observable<CurrentWeather> { get set }
    var fiveDaysInfo: Observable<FiveDaysForecast> { get set }
    var address: Observable<String> { get set }
    var fiveDaysImageCodes: [String] { get set }
    
    func readCurrent(requestParam: [String: Any], completion: @escaping () -> Void)
    func readFiveDays(requestParam: [String: Any], completion: @escaping () -> Void)
    func getCurrentImageURL() -> URL
    func convertFahrenheitToCelsius(fahrenheit: Double) -> Double
    func getFiveDaysImageCodes()
    func getCurrentImage(imageCode: String, completion: @escaping (UIImage) -> Void)
}

class WeatherViewModel: ViewModel {
    private var useCase: UseCase!
    
    var currentInfo: Observable<CurrentWeather> = Observable(CurrentWeather(coordination: Coordinate(longitude: 0, lattitude: 0), weather: [], main: Main(temperatureMinimum: 0, temperatureMaximum: 0, temperature: 0)))
    var fiveDaysInfo: Observable<FiveDaysForecast> = Observable(FiveDaysForecast(list: []))
    var address: Observable<String> = Observable("")
    var fiveDaysImageCodes = [String]()
    
    func readCurrent(requestParam: [String: Any], completion: @escaping () -> Void) {
        useCase.readCurrent(requestParam: requestParam) { [weak self] currentWeather in
            guard let self = self else {
                return
            }
            
            print(currentWeather)
            self.currentInfo.value = currentWeather
            print(self.currentInfo.value)
            completion()
        }
    }
    
    func readFiveDays(requestParam: [String: Any], completion: @escaping () -> Void) {
        useCase.readFiveDays(requestParam: requestParam) { [weak self] fivedays in
            guard let self = self else {
                return
            }
            
            self.fiveDaysInfo.value = fivedays
            completion()
        }
    }
    
    func getCurrentImageURL() -> URL {
        guard let imageCode = currentInfo.value.weather.first,
              let imageURL = URL(string: "https://openweathermap.org/img/w/\(imageCode).png") else {
            return URL(string: "")!
        }
        
        return imageURL
    }
    
    func getFiveDaysImageCodes() {
        let imageCodes = self.fiveDaysInfo.value.list.flatMap({ $0.weather }).flatMap({ $0.icon }).map({String($0)})
        self.fiveDaysImageCodes = imageCodes
    }
    
    private func convert(with data: Data, completion: @escaping (UIImage) -> Void) {
        DispatchQueue.global().async {
            guard let weatherImage = UIImage(data: data) else {
                return
            }
            completion(weatherImage)
        }
    }
    
    func getCurrentImage(imageCode: String, completion: @escaping (UIImage) -> Void) {
        guard let url = URL(string: "https://openweathermap.org/img/w/\(imageCode).png") else {
            return
        }
        
        AF.request(url, method: .get)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    self.convert(with: data) { image in
                        completion(image)
                    }
                case .failure(let error):
                    print(error)
                }
            }
    }
    
    func convertFahrenheitToCelsius(fahrenheit: Double) -> Double {
        let celsius = UnitTemperature.celsius.converter.value(fromBaseUnitValue: fahrenheit)
        let roundedNumber = round(celsius * 10) / 10
        
        return roundedNumber
    }
    
    init(useCase: UseCase) {
        self.useCase = useCase
    }
}
