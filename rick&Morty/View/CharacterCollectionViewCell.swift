//
//  CharacterCollectionViewCell.swift
//  rick&Morty
//
//  Created by Давид Тоноян  on 21.05.2021.
//

import UIKit

final class CharacterCollectionViewCell: UICollectionViewCell {
    let characterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .white
        return imageView
    }()
    
    convenience override init(frame: CGRect) {
        self.init(frame: frame)
        
        setupView()
    }
    
    private func setupView() {
        contentView.addSubview(characterImageView)
        
        characterImageView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
    }
}
