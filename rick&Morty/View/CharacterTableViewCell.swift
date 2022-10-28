//
//  CharacterTableViewCell.swift
//  rick&Morty
//
//  Created by Давид Тоноян  on 21.05.2021.
//

import UIKit
import SnapKit

final class CharacterTableViewCell: UITableViewCell {
    private let characterView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 10
        return view
    }()
    let characterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .white
        return imageView
    }()
    let characterNameLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 17)
        label.tintColor = .black
        return label
    }()
    let characterStatusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    let characterLocationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        return label
    }()
    let statusColorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.cornerRadius = view.frame.size.width / 2
        return view
    }()
    
    convenience override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
    }
    
    private func setupView() {
        [characterImageView,
         characterNameLabel,
         characterStatusLabel,
         characterLocationLabel,
         statusColorView].forEach { characterView.addSubview($0) }
        
        contentView.addSubview(characterView)
        
        characterView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        
        characterImageView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().inset(10)
            make.width.height.equalTo(100)
        }
        
        characterNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalTo(characterImageView.snp.trailing).offset(10)
        }
        
        statusColorView.snp.makeConstraints { make in
            make.top.equalTo(characterNameLabel.snp.bottom).offset(10)
            make.leading.equalTo(characterImageView.snp.trailing).offset(10)
        }
        
        characterStatusLabel.snp.makeConstraints { make in
            make.top.equalTo(characterNameLabel.snp.bottom).offset(10)
            make.leading.equalTo(statusColorView.snp.trailing).offset(5)
        }
        
        characterLocationLabel.snp.makeConstraints { make in
            make.top.equalTo(characterStatusLabel.snp.bottom).offset(10)
            make.leading.equalTo(characterImageView.snp.trailing).offset(10)
        }
    }
}
