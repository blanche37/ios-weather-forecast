//
//  WeatherForecast - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit
import Alamofire
import SnapKit

final class ViewController: UIViewController {
    // MARK: - Properties
    private let locationManager = LocationManager()
    private lazy var tableViewHeaderView = UIView()
    private let currentWeatherImageView = UIImageView()
    
    private let refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshTableView(refreshControl:)), for: .valueChanged)
        refreshControl.backgroundColor = .clear
        return refreshControl
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(WeatherInfoCell.self, forCellReuseIdentifier: WeatherInfoCell.cellIdentifier)
        tableView.tableHeaderView = self.tableViewHeaderView
        tableView.refreshControl = self.refreshControl
        tableView.backgroundColor = .clear
        tableView.separatorColor = .lightGray
        return tableView
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .lightGray
        return label
    }()
    
    private let temperatureRangeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .lightGray
        return label
    }()
    
    private let currentTemperatureLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .white
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .leading
        stackView.distribution = .equalSpacing
        [self.addressLabel, self.temperatureRangeLabel, self.currentTemperatureLabel]
            .forEach { stackView.addArrangedSubview($0) }
        return stackView
    }()
    
    // MARK: - LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setBackgroundImage()
        addObservers()
        addSubviews()
        configureLayout()
    }
    
    // MARK: - Methods
    private func setBackgroundImage() {
        self.view.addBackground(imageName: "seoul")
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(refreshTableView(_:)),
                                               name: Notification.Name.dataIsNotNil,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(setupTableViewHeaderView),
                                               name: Notification.Name.completion,
                                               object: nil)
    }
    
    @objc private func refreshTableView(_ notification: Notification) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @objc func setupTableViewHeaderView(_ notification: Notification) {
        guard let weatherInfo = locationManager.currentWeatherInfo.flatMap({ $0.weather.first }),
              let temperatureInfo = locationManager.currentWeatherInfo.map({ $0.main }) else {
            return
        }
        
        let iconId = weatherInfo.icon
        
        getWeatherImageData(with: iconId) { data in
            self.convert(with: data) { image in
                DispatchQueue.main.async {
                    self.currentWeatherImageView.image = image
                }
            }
        }
        
        let maxCelsius = convertFahrenheitToCelsius(fahrenheit: temperatureInfo.temperatureMaximum)
        let minCelsius = convertFahrenheitToCelsius(fahrenheit: temperatureInfo.temperatureMinimum)
        let currentCelsius = convertFahrenheitToCelsius(fahrenheit: temperatureInfo.temperature)
        
        self.addressLabel.text = self.locationManager.address
        self.temperatureRangeLabel.text = "최저 \(round(minCelsius * 10) / 10)° 최고 \(round(maxCelsius * 10) / 10)°"
        self.currentTemperatureLabel.text = "\(round(currentCelsius * 10) / 10)°"
    }
    
    private func addSubviews() {
        view.addSubview(tableView)
        tableViewHeaderView.addSubview(currentWeatherImageView)
        tableViewHeaderView.addSubview(stackView)
    }
    
    private func configureLayout() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        tableViewHeaderView.snp.makeConstraints { make in
            make.width.equalTo(self.tableView)
            make.height.equalTo(100)
        }
        
        currentWeatherImageView.snp.makeConstraints { make in
            make.width.height.equalTo(80)
            make.leading.top.equalTo(self.tableViewHeaderView).offset(10)
        }
        
        stackView.snp.makeConstraints { make in
            make.leading.equalTo(currentWeatherImageView.snp.trailing).offset(10)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
    }
    
    private func getWeatherImageData(with iconId: String, completion: @escaping (Data) -> Void) {
        do {
            let weatherImageURL = try URLs.getImageURL(with: iconId)
            AF.request(weatherImageURL, method: .get)
                .validate()
                .responseData { response in
                    switch response.result {
                    case let .success(data):
                        completion(data)
                    case let .failure(error):
                        print(error)
                    }
                }
        } catch {
            print(error)
        }
    }
    
    private func convert(with data: Data, completion: @escaping (UIImage) -> Void) {
        DispatchQueue.global().async {
            guard let weatherImage = UIImage(data: data) else {
                return
            }
            completion(weatherImage)
        }
    }
    
    private func convertFahrenheitToCelsius(fahrenheit: Double) -> Double {
        let celsius = UnitTemperature.celsius.converter.value(
            fromBaseUnitValue: fahrenheit
        )
        let roundedNumber = round(celsius * 10) / 10
        return roundedNumber
    }
}

// MARK: - TableView Protocol
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WeatherInfoCell.cellIdentifier,
                                                       for: indexPath) as? WeatherInfoCell,
              let fiveDaysWeatherInfo = locationManager.fiveDaysWeatherInfo,
              let weatherInfo = fiveDaysWeatherInfo.list[indexPath.row].weather.first else {
                  return UITableViewCell()
              }
        
        let fahrenheit = fiveDaysWeatherInfo.list[indexPath.row].main.temperature
        let celsius = convertFahrenheitToCelsius(fahrenheit: fahrenheit)
        let dateFormatter = DateFormatter()
        
        getWeatherImageData(with: weatherInfo.icon) { data in
            self.convert(with: data) { image in
                if let cachedImage = CachingManager.fiveDaysWeatherImageCache.object(
                    forKey: "\(weatherInfo.icon)" as NSString) {
                    DispatchQueue.main.async {
                        cell.weatherImageView.image = cachedImage
                    }
                } else {
                    CachingManager.cacheImage(iconId: weatherInfo.icon, image: image)
                }
            }
        }
        
        dateFormatter.dateFormat = "MM/dd HH시"
        
        cell.dateLabel.text = "\(dateFormatter.string(from: fiveDaysWeatherInfo.list[indexPath.row].date))"
        cell.temperatureLabel.text = "\(celsius)°"
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationManager.fiveDaysWeatherInfo?.list.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

// MARK: - Refresh Control
extension ViewController {
    @objc private func refreshTableView(refreshControl: UIRefreshControl) {
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
