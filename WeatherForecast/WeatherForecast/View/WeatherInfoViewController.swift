//
//  WeatherForecast - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit
import Alamofire
import SnapKit

final class WeatherInfoViewController: UIViewController, ImageConvertable, CelsiusConvertable {
    // MARK: - Properties
    private static let dateFormatter = DateFormatManager()
    
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
        tableView.delegate = self
        tableView.dataSource = self
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
        setBackgroundImage()
        addObserver()
        addSubviews()
        configureLayout()
    }
    
    // MARK: - Methods
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
              let fiveDaysWeatherInfo = LocationManager.shared.fiveDaysWeatherInfo,
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
        return LocationManager.shared.fiveDaysWeatherInfo?.list.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
