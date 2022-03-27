//
//  Repository.swift
//  WeatherForecast
//
//  Created by yun on 2022/02/08.
//

import Foundation
import Alamofire

protocol Repository {
    func readCurrentInfo(requestParam: [String: Any], completion: @escaping (CurrentWeather) -> Void)
    func readFiveDaysInfo(requestParam: [String: Any], completion: @escaping (FiveDaysForecast) -> Void)
}

class NetworkRepository: Repository {
    let currentURL = URL(string: "https://api.openweathermap.org/data/2.5/weather")
    let fiveDaysURL = URL(string: "https://api.openweathermap.org/data/2.5/forecast")
    
    func readCurrentInfo(requestParam: [String: Any], completion: @escaping (CurrentWeather) -> Void) {
        guard let url = currentURL else {
            return
        }
        
        AF.request(url, method: .get, parameters: requestParam)
            .validate()
            .responseDecodable(of: CurrentWeather.self, completionHandler: { response in
                switch response.result {
                case .success(let current):
                    completion(current)
                case .failure(let error):
                    print(error)
                }
            })
    }
    
    func readFiveDaysInfo(requestParam: [String: Any], completion: @escaping (FiveDaysForecast) -> Void) {
        guard let url = fiveDaysURL else {
            return
        }
        
        AF.request(url, method: .get, parameters: requestParam)
            .validate()
            .responseDecodable(of: FiveDaysForecast.self, completionHandler: { response in
                switch response.result {
                case .success(let fiveDays):
                    completion(fiveDays)
                case .failure(let error):
                    print(error)
                }
            })
    }
}
