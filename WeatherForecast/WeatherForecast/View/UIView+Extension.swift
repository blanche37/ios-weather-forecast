//
//  UIView+extension.swift
//  WeatherForecast
//
//  Created by yun on 2022/02/06.
//

import UIKit

extension UIView {
    func addBackground(imageName: String) {
        let imageViewBackground = UIImageView(frame: UIScreen.main.bounds)
        imageViewBackground.image = UIImage(named: imageName)
        imageViewBackground.contentMode = .scaleToFill
        self.addSubview(imageViewBackground)
        self.sendSubviewToBack(imageViewBackground)
    }
}
