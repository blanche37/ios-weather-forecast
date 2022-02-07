//
//  WeatherInformation.swift
//  WeatherForecast
//
//  Created by yun on 2022/02/08.
//

import Foundation

final class WeatherInformation {
    static let shared = WeatherInformation()
    var address: String?
    var fiveDaysWeatherInfo: FiveDaysForecast?
    var currentWeatherInfo: CurrentWeather?
    
    private init() { }
}
