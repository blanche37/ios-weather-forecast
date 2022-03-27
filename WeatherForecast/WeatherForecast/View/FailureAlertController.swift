//
//  FailureAlertController.swift
//  WeatherForecast
//
//  Created by yun on 2021/10/22.
//

import UIKit

final class FailureAlertController: UIAlertController {
    func showAlert(title: String, message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Test", style: .default, handler: nil)
            alert.addAction(alertAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
}
