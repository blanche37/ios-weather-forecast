//
//  WeatherForecastUITests - WeatherForecastUITests.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import XCTest

class WeatherForecastUITests: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
    }
    
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
    
    func testRefreshControl() {
        
    }
}
