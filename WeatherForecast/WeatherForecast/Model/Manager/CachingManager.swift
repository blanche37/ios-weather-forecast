//
//  CachingManager.swift
//  WeatherForecast
//
//  Created by yun on 2022/02/06.
//

import UIKit

struct CachingManager {
    static var fiveDaysWeatherImageCache = NSCache<NSString, UIImage>()
    
    static func cacheImage(iconId: String, image: UIImage) {
        Self.fiveDaysWeatherImageCache.setObject(image, forKey: iconId as NSString)
    }
    
    
}
