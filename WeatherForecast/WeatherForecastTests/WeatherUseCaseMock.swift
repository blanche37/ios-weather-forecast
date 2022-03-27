//
//  NetworkRepositoryMock.swift
//  WeatherForecastTests
//
//  Created by yun on 2022/03/28.
//

import Foundation
import Alamofire

@testable import WeatherForecast

class WeatherUseCaseMock: UseCase {
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
