//
//  CelsiusConvertable.swift
//  WeatherForecast
//
//  Created by yun on 2022/02/07.
//

import Foundation

protocol CelsiusConvertable { }

extension CelsiusConvertable {
    func convertFahrenheitToCelsius(fahrenheit: Double) -> Double {
        let celsius = UnitTemperature.celsius.converter.value(
            fromBaseUnitValue: fahrenheit
        )
        let roundedNumber = round(celsius * 10) / 10
        return roundedNumber
    }
}
