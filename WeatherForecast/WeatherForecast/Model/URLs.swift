//
//  URLs.swift
//  WeatherForecast
//
//  Created by yun on 2022/02/05.
//

import Foundation

enum URLs {
    enum URLError: Error {
        case invalidURL
    }
    
    static let currentURL = URL(string: "https://api.openweathermap.org/data/2.5/weather")!
    static let fiveDaysURL = URL(string: "https://api.openweathermap.org/data/2.5/forecast")!
    
    static func getImageURL(with weatherIcon: String) throws -> URL {
        guard let imageURL = URL(string: "https://openweathermap.org/img/w/\(weatherIcon).png") else {
            throw URLError.invalidURL
        }
        
        return imageURL
    }
}
