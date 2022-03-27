//
//  WeatherInfoCell.swift
//  WeatherForecast
//
//  Created by yun on 2021/10/15.
//

import UIKit
import SnapKit

final class WeatherInfoCell: UITableViewCell, CelsiusConvertable, ImageConvertable {
    static let cellIdentifier: String = "WeatherInfoCell"
    private let weatherImageView = UIImageView()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.boldSystemFont(ofSize: 17)
        return label
    }()
    
    private let temperatureLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.textColor = .white
        return label
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        [self.temperatureLabel, self.weatherImageView]
            .forEach { stackView.addArrangedSubview($0) }
        return stackView
    }()
    
    private func addSubViews() {
        self.contentView.addSubview(dateLabel)
        self.contentView.addSubview(stackView)
    }
    
    private func configureLayout() {
        dateLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        
        weatherImageView.snp.makeConstraints { make in
            make.width.height.equalTo(30)
        }
        
        stackView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
        }
    }
    
    func bind(date: Date, temperature: Double, imageCode: String) {
        let dateFormatter = DateFormatManager()
        let fahrenheit = temperature
        let celsius = convertFahrenheitToCelsius(fahrenheit: fahrenheit)
        
        makeImage(imageCode: imageCode) { [weak self] image in
            DispatchQueue.main.async {
                self?.weatherImageView.image = image
                self?.dateLabel.text = dateFormatter.format(with: date)
                self?.temperatureLabel.text = "\(celsius)°"
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubViews()
        configureLayout()
        self.backgroundColor = .clear
        self.selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
