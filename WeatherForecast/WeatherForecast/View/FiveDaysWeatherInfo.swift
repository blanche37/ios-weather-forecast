//
//  WeatherInfoCell.swift
//  WeatherForecast
//
//  Created by yun on 2021/10/15.
//

import UIKit
import SnapKit

final class WeatherInfoCell: UITableViewCell {
    static let cellIdentifier: String = "WeatherInfoCell"
    let weatherImageView = UIImageView()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        return label
    }()
    
    let temperatureLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.textColor = .white
        return label
    }()
    
    lazy var stackView: UIStackView = {
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubViews()
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
