//
//  UseCase.swift
//  WeatherForecast
//
//  Created by yun on 2022/02/05.
//

import Foundation

protocol UseCase {
    func readCurrent(requestParam: [String: Any], completion: @escaping (CurrentWeather) -> Void)
    func readFiveDays(requestParam: [String: Any], completion: @escaping (FiveDaysForecast) -> Void)
}

final class WeatherUseCase: UseCase {
    var repository: Repository!
    
    func readCurrent(requestParam: [String: Any], completion: @escaping (CurrentWeather) -> Void) {
        repository.readCurrentInfo(requestParam: requestParam, completion: completion)
    }
    
    func readFiveDays(requestParam: [String: Any], completion: @escaping (FiveDaysForecast) -> Void) {
        repository.readFiveDaysInfo(requestParam: requestParam, completion: completion)
    }
    
    init(repository: Repository) {
        self.repository = repository
    }
}
