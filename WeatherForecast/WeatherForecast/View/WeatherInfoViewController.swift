//
//  WeatherForecast - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit
import SnapKit
import CoreLocation
import Lottie

final class WeatherInfoViewController: UIViewController, CelsiusConvertable, ImageConvertable {
    // MARK: - Properties
    private let locationManager = LocationManager()
    var viewModel: ViewModel!

    // MARK: - Views
    private lazy var tableViewHeaderView = WeatherInfoHeaderView()
    
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshTableView(refreshControl:)), for: .valueChanged)
        refreshControl.backgroundColor = .clear
        refreshControl.accessibilityIdentifier = "refresh"
        return refreshControl
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(WeatherInfoCell.self, forCellReuseIdentifier: WeatherInfoCell.cellIdentifier)
        tableView.tableHeaderView = self.tableViewHeaderView
        tableView.refreshControl = self.refreshControl
        tableView.backgroundColor = .clear
        tableView.separatorColor = .lightGray
        tableView.accessibilityIdentifier = "table"
        return tableView
    }()
    
    let animationView: AnimationView = {
        let view = AnimationView(name: "back")
        view.contentMode = .scaleAspectFill
        view.loopMode = .loop
        view.animationSpeed = 0.5
        return view
    }()
    
    // MARK: - LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        animationView.play()
        setDelegate()
        addSubviews()
        configureLayout()
    }
    
    // MARK: - Methods
    private func bind() {
        viewModel.currentInfo.bind(listener: { [weak self] current in
            guard let self = self else {
                return
            }
            
            let temperatureInfo = current.main
            let maxCelsius = self.convertFahrenheitToCelsius(fahrenheit: temperatureInfo.temperatureMaximum)
            let minCelsius = self.convertFahrenheitToCelsius(fahrenheit: temperatureInfo.temperatureMinimum)
            let currentCelsius = self.convertFahrenheitToCelsius(fahrenheit: temperatureInfo.temperature)
            
            guard let imageCode = current.weather.first?.icon else {
                return
            }
            
            self.makeImage(imageCode: imageCode) { image in
                DispatchQueue.main.async {
                    self.tableViewHeaderView.currentWeatherImageView.image = image
                    self.tableViewHeaderView.addressLabel.text = self.viewModel.address
                    self.tableViewHeaderView.temperatureRangeLabel.text = "최저 \(round(minCelsius * 10) / 10)° 최고 \(round(maxCelsius * 10) / 10)°"
                    self.tableViewHeaderView.currentTemperatureLabel.text = "\(round(currentCelsius * 10) / 10)°"
                }
            }
        })
    }
    
    private func setDelegate() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.locationManager.delegate = self
    }
    
    private func addSubviews() {
        view.addSubview(animationView)
        view.addSubview(tableView)
    }
    
    private func configureLayout() {
        animationView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }
        
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        tableViewHeaderView.snp.makeConstraints { make in
            make.width.equalTo(self.tableView)
            make.height.equalTo(100)
        }
    }
    
    // MARK: - Refresh Control
    @objc private func refreshTableView(refreshControl: UIRefreshControl) {
        viewModel.readCurrent(requestParam: viewModel.requestParam, completion: nil)
        viewModel.readFiveDays(requestParam: viewModel.requestParam) { [weak self] in
            guard let self = self else {
                return
            }
            
            self.viewModel.getFiveDaysImageCodes()
            self.tableView.reloadData()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.tableView.reloadData()
            refreshControl.endRefreshing()
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if velocity.y < -0.1 {
            self.refreshTableView(refreshControl: self.refreshControl)
        }
    }
}

// MARK: - TableView Protocol
extension WeatherInfoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WeatherInfoCell.cellIdentifier,
                                                       for: indexPath) as? WeatherInfoCell else {
                  return UITableViewCell()
              }
        
        viewModel.fiveDaysInfo.bind { fiveDays in
            let weatherInfo = fiveDays.list[indexPath.row]
            
            guard let imageCode = weatherInfo.weather.first?.icon else {
                return
            }
            
            let temperature = weatherInfo.main.temperature
            let date = weatherInfo.date
            
            cell.bind(date: date, temperature: temperature, imageCode: imageCode)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.fiveDaysInfo.value.list.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

// MARK: - CLLocationManager Delegate 
extension WeatherInfoViewController: CLLocationManagerDelegate {
    private func convertToAddress(with location: CLLocation, locale: Locale) {
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(location, preferredLocale: locale) { [weak self] placeMarks, error in
            guard let self = self,
                error == nil else {
                return
            }
            
            guard let addresses = placeMarks,
                  let address = addresses.last?.name else {
                      return
                  }
            
            self.viewModel.address = address
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let longitude = manager.location?.coordinate.longitude,
              let latitude = manager.location?.coordinate.latitude else { return }
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let locale = Locale(identifier: "Ko-kr")
        
        convertToAddress(with: location, locale: locale)

        viewModel.requestParam.updateValue(latitude, forKey: "lat")
        viewModel.requestParam.updateValue(longitude, forKey: "lon")
        
        viewModel.readCurrent(requestParam: viewModel.requestParam) { [weak self] in
            guard let self = self else {
                return
            }
            
            self.bind()
        }
        
        viewModel.readFiveDays(requestParam: viewModel.requestParam) { [weak self] in
            guard let self = self else {
                return
            }
            
            self.viewModel.getFiveDaysImageCodes()
            self.tableView.reloadData()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let alertController = FailureAlertController()
        alertController.showAlert(title: "🙋‍♀️", message: "새로고침을 해주세요.")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        let alertController = FailureAlertController()
        switch status {
        case .restricted, .denied:
            alertController.showAlert(title: "❌", message: "날씨 정보를 사용 할 수 없습니다.")
        case .authorizedWhenInUse, .authorizedAlways, .notDetermined:
            manager.requestLocation()
        @unknown default:
            alertController.showAlert(title: "⚠️", message: "알수없는 에러")
        }
    }
}
