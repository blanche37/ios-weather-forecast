//
//  WeatherForecast - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit
import CoreLocation
import Alamofire

final class ViewController: UIViewController {
    // MARK: - Properties
    private let locationManager = LocationManager()
    private let tableView = UITableView()
    private let tableViewHeaderView = UIView()
    private let currentWeatherImageView = UIImageView()
    private let addressLabel = UILabel()
    private let temperatureRangeLabel = UILabel()
    private let currentTemperatureLabel = UILabel()
    private let fiveDaysWeatherImageCache = NSCache<NSString, UIImage>()
    
    // MARK: - LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        addObservers()
        setUpTableView()
        addSubviews()
        configureLayout()
        setupBackgroundImage()
    }
    
    // MARK: - Methods
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
    
    private func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(WeatherInfoCell.self, forCellReuseIdentifier: WeatherInfoCell.cellIdentifier)
    }
    
    @objc func refreshTableView(_ notification: Notification) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @objc func setupTableViewHeaderView(_ notification: Notification) {
        guard let paramIcon = locationManager.currentWeatherInfo?.weather.first,
              let imageURL = URL(string: "https://openweathermap.org/img/w/\(paramIcon.icon).png") else {
                  return
        }
        let maxCelsius = UnitTemperature.celsius.converter.value(fromBaseUnitValue: self.locationManager.currentWeatherInfo!.main.temperatureMaximum)
        let minCelsius = UnitTemperature.celsius.converter.value(fromBaseUnitValue: self.locationManager.currentWeatherInfo!.main.temperatureMinimum)
        let currentCelsius = UnitTemperature.celsius.converter.value(fromBaseUnitValue: self.locationManager.currentWeatherInfo!.main.temperature)
        DispatchQueue.main.async {
            self.addressLabel.text = self.locationManager.address
            AF.request(imageURL, method: .get)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        let image = UIImage(data: data)
                        DispatchQueue.main.async {
                            self.currentWeatherImageView.image = image
                        }
                    case .failure(let error):
                        print(error)
                    }
                }
            self.temperatureRangeLabel.text = "최저 \(round(minCelsius * 10) / 10)° 최고 \(round(maxCelsius * 10) / 10)°"
            self.currentTemperatureLabel.text = "\(round(currentCelsius * 10) / 10)"
        }
    }
    
    private func setupBackgroundImage() {
        self.view.addBackground(imageName: "sky")
        self.tableView.backgroundColor = .clear
    }
    
    private func addSubviews() {
        view.addSubview(tableView)
        tableView.tableHeaderView = tableViewHeaderView
        tableViewHeaderView.addSubview(currentWeatherImageView)
        tableViewHeaderView.addSubview(addressLabel)
        tableViewHeaderView.addSubview(temperatureRangeLabel)
        tableViewHeaderView.addSubview(currentTemperatureLabel)
    }
    
    private func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableViewHeaderView.translatesAutoresizingMaskIntoConstraints = false
        currentWeatherImageView.translatesAutoresizingMaskIntoConstraints = false
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        temperatureRangeLabel.translatesAutoresizingMaskIntoConstraints = false
        currentTemperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            tableViewHeaderView.heightAnchor.constraint(equalToConstant: 100),
            tableViewHeaderView.widthAnchor.constraint(equalToConstant: tableView.bounds.width)
        ])
        
        NSLayoutConstraint.activate([
            currentWeatherImageView.leadingAnchor.constraint(equalTo: tableViewHeaderView.leadingAnchor, constant: 10),
            currentWeatherImageView.widthAnchor.constraint(equalToConstant: 80),
            currentWeatherImageView.heightAnchor.constraint(equalToConstant: 80),
            currentWeatherImageView.topAnchor.constraint(equalTo: tableViewHeaderView.topAnchor, constant: 10)
        ])
        
        NSLayoutConstraint.activate([
            addressLabel.leadingAnchor.constraint(equalTo: currentWeatherImageView.trailingAnchor, constant: 10),
            addressLabel.topAnchor.constraint(equalTo: tableViewHeaderView.topAnchor, constant: 10)
        ])
        
        NSLayoutConstraint.activate([
            temperatureRangeLabel.leadingAnchor.constraint(equalTo: currentWeatherImageView.trailingAnchor, constant: 10),
            temperatureRangeLabel.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: 10)
        ])
        
        NSLayoutConstraint.activate([
            currentTemperatureLabel.leadingAnchor.constraint(equalTo: currentWeatherImageView.trailingAnchor, constant: 10),
            currentTemperatureLabel.topAnchor.constraint(equalTo: temperatureRangeLabel.bottomAnchor, constant: 10)
        ])
    }
}

// MARK: - TableView Protocol
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func getWeatherImageData(with iconId: String, completion: @escaping (Data) -> Void) {
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
    
    func convert(with data: Data, completion: @escaping (UIImage) -> Void) {
        DispatchQueue.global().async {
            guard let weatherImage = UIImage(data: data) else {
                return
            }
            completion(weatherImage)
        }
    }
    
    func cacheImage(iconId: String, image: UIImage) {
        self.fiveDaysWeatherImageCache.setObject(image, forKey: iconId as NSString)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WeatherInfoCell.cellIdentifier,
                                                       for: indexPath) as? WeatherInfoCell,
              let item = locationManager.fiveDaysWeatherInfo,
              let weatherInfo = item.list[indexPath.row].weather.first else {
                  return UITableViewCell()
              }
        
        let celsius = UnitTemperature.celsius.converter.value(fromBaseUnitValue: item.list[indexPath.row].main.temperature)
        let roundedNumber = round(celsius * 10) / 10
        let dateFormatter = DateFormatter()
        
        getWeatherImageData(with: weatherInfo.icon) { data in
            self.convert(with: data) { image in
                if let cachedImage = self.fiveDaysWeatherImageCache.object(forKey: "\(weatherInfo.icon)" as NSString) {
                    DispatchQueue.main.async {
                        cell.weatherImageView.image = cachedImage
                    }
                } else {
                    self.cacheImage(iconId: weatherInfo.icon, image: image)
                }
            }
        }
        
        dateFormatter.dateFormat = "MM/dd HH시"
        
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.dateLabel.text = "\(dateFormatter.string(from: item.list[indexPath.row].date))"
        cell.temperatureLabel.text = "\(roundedNumber)°"
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationManager.fiveDaysWeatherInfo?.list.count ?? 0
    }
}

extension UIView {
    func addBackground(imageName: String) {
        let imageViewBackground = UIImageView(frame: UIScreen.main.bounds)
        imageViewBackground.image = UIImage(named: imageName)
        imageViewBackground.contentMode = .scaleToFill
        self.addSubview(imageViewBackground)
        self.sendSubviewToBack(imageViewBackground)
    }
}
