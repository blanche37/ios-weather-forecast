//
//  WeatherForecastUITests - WeatherForecastUITests.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import XCTest

class WeatherForecastUITests: XCTestCase {
    private var app: XCUIApplication!
    private var refreshControl: XCUIElement!
    private var tableView: XCUIElement!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
        
        let app = XCUIApplication()
        app.launch()
        
        refreshControl = app.otherElements["refresh"]
        tableView = app.tables["table"]
    }
    
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
