//
//  URLParameterEncoder.swift
//  WeatherForecast
//
//  Created by Do Yi Lee on 2021/09/27.
//

import Foundation
// 파라미터엔 위도, 경도 혹은 도시 아이디가 전달되어야 함
public struct URLParameterEncoder: ParameterEncoder {
    public static func encode(urlRequest: inout URLRequest, with parameter: Parameters) throws {
        guard let url = urlRequest.url else {
            throw NetworkError.urlMissing
        }
        
        if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), !parameter.isEmpty {
            // 쿼리아이템 배열을 할당해줌
            urlComponents.queryItems = [URLQueryItem]()
            
            for (key, value) in parameter {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                urlComponents.queryItems?.append(queryItem)
            }
            urlRequest.url = urlComponents.url
        }
    }
}
