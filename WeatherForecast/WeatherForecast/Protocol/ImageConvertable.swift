//
//  ImageConvertable.swift
//  WeatherForecast
//
//  Created by yun on 2022/02/07.
//

import UIKit
import Alamofire

protocol ImageConvertable: AnyObject { }

extension ImageConvertable {
    func getWeatherImageData(with iconId: String, completion: @escaping (Data) -> Void) {
        do {
            let weatherImageURL = try URLs.getImageURL(with: iconId)
            AF.request(weatherImageURL, method: .get)
                .validate()
                .responseData { response in
                    switch response.result {
                    case let .success(data):
                        completion(data)
                    case let .failure(error):
                        print(error)
                    }
                }
        } catch {
            print(error)
        }
    }
    
    func convert(with data: Data, completion: @escaping (UIImage) -> Void) {
        DispatchQueue.global().async {
            guard let weatherImage = UIImage(data: data) else {
                return
            }
            completion(weatherImage)
        }
    }
}
