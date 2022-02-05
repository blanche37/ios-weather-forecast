//
//  WeatherInfoModel.swift
//  WeatherForecast
//
//  Created by Do Yi Lee on 2021/09/29.
//

import Foundation

struct CurrentWeather: Decodable {
    let coordination: Coordinate
    let weather: [Weather]
    let main: Main
    
    enum CodingKeys: String, CodingKey {
        case coordination = "coord"
        case weather, main
    }
    
    struct Weather: Decodable {
        let icon: String
    }
    
    struct Main: Decodable {
        let temperatureMinimum: Double
        let temperatureMaximum: Double
        let temperature: Double
        
        enum CodingKeys: String, CodingKey {
            case temperatureMinimum = "temp_min"
            case temperatureMaximum = "temp_max"
            case temperature = "temp"
        }
    }
    
    struct Coordinate: Decodable {
        let longitude: Double
        let lattitude: Double
        
        enum CodingKeys: String, CodingKey {
            case longitude = "lon"
            case lattitude = "lat"
        }
    }
}

struct FiveDaysForecast: Decodable {
    var list: [ListDetail]
}

struct ListDetail: Decodable {
    let date: Date
    let main: MainDetail
    let weather: [WeatherDetail]

    enum CodingKeys: String, CodingKey {
        case date = "dt"
        case main, weather
    }
}

struct MainDetail: Decodable {
    let temperature: Double

    enum CodingKeys: String, CodingKey {
        case temperature = "temp"
    }
}

struct WeatherDetail: Decodable {
    let icon: String
}

