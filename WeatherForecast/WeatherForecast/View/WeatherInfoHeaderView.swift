//
//  WeatherInfoHeaderView.swift
//  WeatherForecast
//
//  Created by yun on 2022/02/07.
//

import UIKit
import SnapKit

final class WeatherInfoHeaderView: UIView, CelsiusConvertable {
    let currentWeatherImageView = UIImageView()
    let addressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .lightGray
        return label
    }()
    
    let temperatureRangeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .lightGray
        return label
    }()
    
    let currentTemperatureLabel: UILabel = {
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        configureLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
