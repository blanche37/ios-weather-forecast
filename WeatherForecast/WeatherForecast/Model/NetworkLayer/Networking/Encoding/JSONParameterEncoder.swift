//
//  JSONParameterEncoder.swift
//  WeatherForecast
//
//  Created by Do Yi Lee on 2021/09/27.
//

import Foundation

//public struct JSONParameterEncoder: ParameterEncoder {
//    public static func encode(urlRequest: inout URLRequest, with parameter: Parameters) throws {
//        do {
//            let jsonAsData = try JSONSerialization.data(withJSONObject: parameter, options: .prettyPrinted)
//            urlRequest.httpBody =  jsonAsData
//            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
//                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
//            }
//        }
//    }
//}
