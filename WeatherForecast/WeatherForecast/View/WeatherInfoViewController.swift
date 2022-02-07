//
//  WeatherForecast - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit
import Alamofire
import SnapKit
import CoreLocation

final class WeatherInfoViewController: UIViewController, ImageConvertable, CelsiusConvertable {
    // MARK: - Properties
    private static let dateFormatter = DateFormatManager()
    private var weatherInfo = WeatherInformation.shared
    private let locationManager = LocationManager()
    
    // MARK: - Views
    private lazy var tableViewHeaderView = WeatherInfoHeaderView()
    
    private let refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshTableView(refreshControl:)), for: .valueChanged)
        refreshControl.backgroundColor = .clear
        return refreshControl
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(WeatherInfoCell.self, forCellReuseIdentifier: WeatherInfoCell.cellIdentifier)
        tableView.tableHeaderView = self.tableViewHeaderView
        tableView.refreshControl = self.refreshControl
        tableView.backgroundColor = .clear
        tableView.separatorColor = .lightGray
        return tableView
    }()
    
    // MARK: - LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegate()
        setBackgroundImage()
        addObserver()
        addSubviews()
        configureLayout()
    }
    
    // MARK: - Methods
    private func setDelegate() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.locationManager.delegate = self
    }
    private func setBackgroundImage() {
        self.view.addBackground(imageName: "seoul")
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(refreshTableView(_:)),
                                               name: Notification.Name.dataIsNotNil,
                                               object: nil)
    }
    
    @objc private func refreshTableView(_ notification: Notification) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func addSubviews() {
        view.addSubview(tableView)
    }
    
    private func configureLayout() {
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
                                                       for: indexPath) as? WeatherInfoCell,
              let fiveDaysWeatherInfo = weatherInfo.fiveDaysWeatherInfo,
              let weatherInfo = fiveDaysWeatherInfo.list[indexPath.row].weather.first else {
                  return UITableViewCell()
              }
        
        let fahrenheit = fiveDaysWeatherInfo.list[indexPath.row].main.temperature
        let celsius = convertFahrenheitToCelsius(fahrenheit: fahrenheit)
        
        getWeatherImageData(with: weatherInfo.icon) { data in
            self.convert(with: data) { image in
                if let cachedImage = CachingManager.shared.fiveDaysWeatherImageCache.object(
                    forKey: "\(weatherInfo.icon)" as NSString) {
                    DispatchQueue.main.async {
                        cell.weatherImageView.image = cachedImage
                    }
                } else {
                    CachingManager.shared.cacheImage(iconId: weatherInfo.icon, image: image)
                }
            }
        }
        
        cell.dateLabel.text = Self.dateFormatter.formatDate(date: fiveDaysWeatherInfo.list[indexPath.row].date)
        cell.temperatureLabel.text = "\(celsius)°"
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherInfo.fiveDaysWeatherInfo?.list.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

extension WeatherInfoViewController: CLLocationManagerDelegate {
    private func parseCurrent(url: URL, param: [String: Any], completion: @escaping () -> Void) {
        AF.request(url, method: .get, parameters: param)
            .validate()
            .responseData { response in
                switch response.result {
                case let .success(data):
                    do {
                        self.weatherInfo.currentWeatherInfo = try JSONDecoder().decode(CurrentWeather.self, from: data)
                        completion()
                    } catch {
                        print("DecodingError")
                    }
                case let .failure(error):
                    print(error)
                }
            }
    }
    
    private func parseFiveDays(url: URL, param: [String: Any], completion: @escaping () -> Void) {
        AF.request(url, method: .get, parameters: param)
            .validate()
            .responseData { response in
                switch response.result {
                case let .success(data):
                    do {
                        self.weatherInfo.fiveDaysWeatherInfo = try JSONDecoder().decode(FiveDaysForecast.self, from: data)
                        completion()
                    } catch {
                        print("DecodingError")
                    }
                case let .failure(error):
                    print(error)
                }
            }
    }
    
    private func convertToAddress(with location: CLLocation, locale: Locale) {
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(location, preferredLocale: locale) { placeMarks, error in
            guard error == nil else {
                return
            }
            
            guard let addresses = placeMarks,
                  let address = addresses.last?.name else {
                      return
                  }
            
            self.weatherInfo.address = address
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let longitude = manager.location?.coordinate.longitude,
              let latitude = manager.location?.coordinate.latitude else { return }
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let locale = Locale(identifier: "Ko-kr")
        
        convertToAddress(with: location, locale: locale)

        let requestParam: [String: Any] = [
            "lat": latitude,
            "lon": longitude,
            "appid": "9cda367698143794391817f65f81c76e"
        ]
        
        parseCurrent(url: URLs.currentURL, param: requestParam) {
            NotificationCenter.default.post(name: Notification.Name.completion, object: nil, userInfo: nil)
        }
        parseFiveDays(url: URLs.fiveDaysURL, param: requestParam) {
            NotificationCenter.default.post(name: Notification.Name.dataIsNotNil, object: nil, userInfo: nil)
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
