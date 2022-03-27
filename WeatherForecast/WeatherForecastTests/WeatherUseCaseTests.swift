//
//  WeatherForecastTests - WeatherForecastTests.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import XCTest
@testable import WeatherForecast

class WeatherUseCaseTests: XCTestCase {
    let repository: Repository = NetworkRepository()
    lazy var sut: UseCase = WeatherUseCaseMock(repository: self.repository)
    lazy var viewModel: ViewModel = WeatherViewModel(useCase: sut)
    
    override func setUpWithError() throws {
        
    }
    
    func testReadCurrent() {
        // given
        let requestParam: [String: Any] = [
            "lat": 35,
            "lon": 139,
            "appid": "9cda367698143794391817f65f81c76e"
        ]
        
        let `default` = Observable(CurrentWeather(coordination: Coordinate(longitude: 0, lattitude: 0), weather: [], main: Main(temperatureMinimum: 0, temperatureMaximum: 0, temperature: 0)))
        
        // when
        sut.readCurrent(requestParam: requestParam) { current in
        // then
            XCTAssertNotEqual(`default`.value.coordination.lattitude, current.coordination.lattitude)
            XCTAssertNotEqual(`default`.value.coordination.longitude, current.coordination.longitude)
        }
    }
    
    func testReadFiveDays() {
        // given
        let requestParam: [String: Any] = [
            "lat": 35,
            "lon": 139,
            "appid": "9cda367698143794391817f65f81c76e"
        ]
        
        let `default`: Observable<FiveDaysForecast> = Observable(FiveDaysForecast(list: []))

        // when
        sut.readFiveDays(requestParam: requestParam) { fiveDays in
        // then
            print(`default`.value) 
            XCTAssertNotEqual(`default`.value.list.first?.date, fiveDays.list.first?.date)
            XCTAssertNotEqual(`default`.value.list.first?.main.temperature, fiveDays.list.first?.main.temperature)
            XCTAssertNotEqual(`default`.value.list.first?.weather.first?.icon, fiveDays.list.first?.weather.first?.icon)
        }
    }
}
