//
//  ImageConvertable.swift
//  WeatherForecast
//
//  Created by yun on 2022/03/27.
//

import UIKit
import Alamofire

protocol ImageConvertable: AnyObject { }

extension ImageConvertable {
    func makeImage(imageCode: String, completion: @escaping (UIImage) -> Void) {
        let cachingManager = CachingManager.shared
        
        if let image = cachingManager.weatherImageCache.object(forKey: imageCode as NSString) {
            completion(image)
        } else {
            guard let imageURL = URL(string: "https://openweathermap.org/img/w/\(imageCode).png") else {
                return
            }
            
            AF.request(imageURL, method: .get)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        self.convert(with: data) { image in
                            cachingManager.cacheImage(iconId: imageCode, image: image)
                            completion(image)
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
        }
    }
    
    private func convert(with data: Data, completion: @escaping (UIImage) -> Void) {
        DispatchQueue.global().async {
            guard let image = UIImage(data: data) else {
                return
            }
            completion(image)
        }
    }
}
