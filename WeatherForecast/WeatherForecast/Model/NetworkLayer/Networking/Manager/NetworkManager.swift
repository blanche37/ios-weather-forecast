//
//  NetworkManager.swift
//  WeatherForecast
//
//  Created by Do Yi Lee on 2021/09/28.
//

import Foundation

struct NetworkManager {
    private var apiKey: String {
        get {
            guard let filePath = Bundle.main.path(forResource: "Info", ofType: "plist") else {
                fatalError()
            }
            let plist = NSDictionary(contentsOfFile: filePath)
            guard let value = plist?.object(forKey: "API_KEY") as? String else {
                fatalError()
            }
            return value
        }
    }
    
    private let router = Router<WeatherApi>()
    
    func getCurrentWeatherInformation(weahterApi: WeatherApi, _ session: URLSession) {
        router.request(weahterApi, session)
    }
 
    func getFiveDaysForcast(weahterApi: WeatherApi, _ session: URLSession) {
        router.request(weahterApi, session)
    }
}


