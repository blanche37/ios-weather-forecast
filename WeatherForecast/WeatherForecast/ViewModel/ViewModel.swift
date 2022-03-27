//
//  ViewModel.swift
//  WeatherForecast
//
//  Created by yun on 2022/03/26.
//

import Foundation
import Alamofire

protocol ViewModel {
    var currentInfo: Observable<CurrentWeather> { get set }
    var fiveDaysInfo: Observable<FiveDaysForecast> { get set }
    var address: String { get set }
    var fiveDaysImageCodes: [String] { get set }
    
    func readCurrent(requestParam: [String: Any], completion: @escaping () -> Void)
    func readFiveDays(requestParam: [String: Any], completion: @escaping () -> Void)
    func getFiveDaysImageCodes()
}

final class WeatherViewModel: ViewModel {
    // MARK: - Properties
    private var useCase: UseCase!
    var currentInfo: Observable<CurrentWeather> = Observable(CurrentWeather(coordination: Coordinate(longitude: 0, lattitude: 0), weather: [], main: Main(temperatureMinimum: 0, temperatureMaximum: 0, temperature: 0)))
    var fiveDaysInfo: Observable<FiveDaysForecast> = Observable(FiveDaysForecast(list: []))
    var address: String = ""
    var fiveDaysImageCodes = [String]()
    
    // MARK: - Methods
    func readCurrent(requestParam: [String: Any], completion: @escaping () -> Void) {
        useCase.readCurrent(requestParam: requestParam) { [weak self] currentWeather in
            guard let self = self else {
                return
            }
            self.currentInfo.value = currentWeather
            completion()
        }
    }
    
    func readFiveDays(requestParam: [String: Any], completion: @escaping () -> Void) {
        useCase.readFiveDays(requestParam: requestParam) { [weak self] fivedays in
            guard let self = self else {
                return
            }
            
            self.fiveDaysInfo.value = fivedays
            completion()
        }
    }
    
    func getFiveDaysImageCodes() {
        let imageCodes = self.fiveDaysInfo.value.list.flatMap({ $0.weather }).flatMap({ $0.icon }).map({String($0)})
        self.fiveDaysImageCodes = imageCodes
    }
    
    // MARK: - Initializers
    init(useCase: UseCase) {
        self.useCase = useCase
    }
}
