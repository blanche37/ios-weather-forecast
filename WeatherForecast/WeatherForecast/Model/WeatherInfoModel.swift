//
//  WeatherInfoModel.swift
//  WeatherForecast
//
//  Created by Do Yi Lee on 2021/09/29.
//

import Foundation

struct CurrentWeather: Decodable {
    var coordination: Coordinate
    var weather: [Weather]
    var main: Main
    
    enum CodingKeys: String, CodingKey {
        case coordination = "coord"
        case weather, main
    }
    
    struct Weather: Decodable {
        var icon: String
    }
    
    struct Main: Decodable {
        var temperatureMinimum: Double
        var temperatureMaximum: Double
        var temperature: Double
        
        enum CodingKeys: String, CodingKey {
            case temperatureMinimum = "temp_min"
            case temperatureMaximum = "temp_max"
            case temperature = "temp"
        }
    }
    
    struct Coordinate: Decodable {
        var longitude: Double
        var lattitude: Double
        
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
    var date: Date
    var main: MainDetail
    var weather: [WeatherDetail]

    enum CodingKeys: String, CodingKey {
        case date = "dt"
        case main, weather
    }
}

struct MainDetail: Decodable {
    var temperature: Double

    enum CodingKeys: String, CodingKey {
        case temperature = "temp"
    }
}

struct WeatherDetail: Decodable {
    var icon: String
}

