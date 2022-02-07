//
//  DateFormatManager.swift
//  WeatherForecast
//
//  Created by yun on 2022/02/07.
//

import Foundation

final class DateFormatManager: DateFormatter {
    func format(with date: Date) -> String {
        self.dateFormat = "MM/dd HH시"
        
        return self.string(from: date)
    }
}
