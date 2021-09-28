//
//  HTTPTask.swift
//  WeatherForecast
//
//  Created by Do Yi Lee on 2021/09/27.
//

import Foundation
typealias HTTPHeaders = [String: String]

enum HTTPTask {
    case requestWithUrlParameters(urlParameters: Parameters)
}
