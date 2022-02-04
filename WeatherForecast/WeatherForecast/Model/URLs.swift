//
//  URLs.swift
//  WeatherForecast
//
//  Created by yun on 2022/02/05.
//

import Foundation

enum URLs {
    static let currentURL = URL(string: "https://api.openweathermap.org/data/2.5/weather")!
    static let fiveDaysURL = URL(string: "https://api.openweathermap.org/data/2.5/forecast")!
}
