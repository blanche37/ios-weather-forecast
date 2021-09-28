//
//  EndPointType.swift
//  WeatherForecast
//
//  Created by Do Yi Lee on 2021/09/27.
//

import Foundation

protocol EndPointType {
    var baseURL: URL { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var task: HTTPTask { get }
    var headers: HTTPHeaders? { get }
}

struct WeatherApi: EndPointType {
    var baseURL: URL
    var path: String
    var httpMethod: HTTPMethod
    var task: HTTPTask
    var headers: HTTPHeaders?
}
