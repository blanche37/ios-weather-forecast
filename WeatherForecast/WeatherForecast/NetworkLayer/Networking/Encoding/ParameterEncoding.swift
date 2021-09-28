//
//  ParameterEncoding.swift
//  WeatherForecast
//
//  Created by Do Yi Lee on 2021/09/27.
//

import Foundation

public typealias Parameters = [String: Any]

public protocol ParameterEncoder {
    static func encode(urlRequest: inout URLRequest, with parameter: Parameters) throws
}

public enum NetworkError: String, Error {
    case parametersNill = "Parameter were nil"
    case encodingFailed = "Parameter Encdoing fail"
    case urlMissing = "URL is missing"
    case unIdentified = "Error can't be identified"
}
