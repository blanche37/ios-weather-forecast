//
//  WeatherInfoHeaderView.swift
//  WeatherForecast
//
//  Created by yun on 2022/02/07.
//

import UIKit
import SnapKit

final class WeatherInfoHeaderView: UIView, ImageConvertable, CelsiusConvertable {
    private let currentWeatherImageView = UIImageView()
    private var weatherInfo = WeatherInformation.shared
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
    
    private func addSubviews() {
        self.addSubview(currentWeatherImageView)
        self.addSubview(stackView)
    }
    private func configureLayout() {
        currentWeatherImageView.snp.makeConstraints { make in
            make.width.height.equalTo(80)
            make.leading.top.equalToSuperview().offset(10)
        }
        
        stackView.snp.makeConstraints { make in
            make.leading.equalTo(currentWeatherImageView.snp.trailing).offset(10)
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
    }
    
    @objc private func setupTableViewHeaderView(_ notification: Notification) {
        guard let weatherInfo = self.weatherInfo.currentWeatherInfo.flatMap({ $0.weather.first }),
              let temperatureInfo = self.weatherInfo.currentWeatherInfo.map({ $0.main }) else {
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
        
        self.addressLabel.text = self.weatherInfo.address
        self.temperatureRangeLabel.text = "최저 \(round(minCelsius * 10) / 10)° 최고 \(round(maxCelsius * 10) / 10)°"
        self.currentTemperatureLabel.text = "\(round(currentCelsius * 10) / 10)°"
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(setupTableViewHeaderView),
                                               name: Notification.Name.completion,
                                               object: nil)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        configureLayout()
        addObserver()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
