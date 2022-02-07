//
//  CachingManager.swift
//  WeatherForecast
//
//  Created by yun on 2022/02/06.
//

import UIKit

class CachingManager {
    static let shared = CachingManager()
    var fiveDaysWeatherImageCache = NSCache<NSString, UIImage>()
    
    func cacheImage(iconId: String, image: UIImage) {
        fiveDaysWeatherImageCache.setObject(image, forKey: iconId as NSString)
    }
    
    private init() { }
}
