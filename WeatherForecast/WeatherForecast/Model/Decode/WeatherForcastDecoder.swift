//
//  WeatherForcaseDecoder.swift
//  WeatherForecast
//
//  Created by Do Yi Lee on 2021/09/28.
//

import Foundation

struct WeatherJSON: Decodable {
    
}

struct WeatherForcastDecoder {
    static func decode<T: Decodable>(_ type: T, _ data: Data) -> Data {
        let decoder = JSONDecoder()
        do {
            let data = try decoder.decode(T.self, from: data)
        } catch {
            error
        }
        return data
    }
    
}
