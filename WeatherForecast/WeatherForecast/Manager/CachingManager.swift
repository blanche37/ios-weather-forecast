//
//  CachingManager.swift
//  WeatherForecast
//
//  Created by yun on 2022/02/06.
//

import UIKit

final class CachingManager {
    static let shared = CachingManager()
    var weatherImageCache = NSCache<NSString, UIImage>()
    
    func cacheImage(iconId: String, image: UIImage) {
        weatherImageCache.setObject(image, forKey: iconId as NSString)
    }
    
    private init() { }
}
