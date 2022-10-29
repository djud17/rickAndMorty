//
//  ViewConfiguratore.swift
//  rick&Morty
//
//  Created by Давид Тоноян  on 30.10.2022.
//

import UIKit
import SnapKit

final class ViewConfigurator {
    static let shared = ViewConfigurator()
    
    let characterListVCViewConfigurator = CharacterListVCViewConfigurator()
    let characterDetailViewController = CharacterDetailViewConfigurator()
    let episodeDetailViewConfigurator = EpisodeDetailViewConfigurator()
}

final class CharacterListVCViewConfigurator {
    func setupTableView(on superview: UIView) -> UITableView {
        let tableView = UITableView()
        tableView.register(CharacterTableViewCell.self, forCellReuseIdentifier: "characterCell")
        tableView.backgroundColor = .white
        tableView.separatorColor = .white
        tableView.rowHeight = 130
        
        superview.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(superview.safeAreaLayoutGuide.snp.bottom).inset(40)
        }
        
        return tableView
    }
    
    func setupPageNavigation(on superview: UIView,
                             under underView: UIView,
                             with navigationArray: [UIView]) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually

        navigationArray.forEach { stackView.addArrangedSubview($0) }
        
        superview.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(underView.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.bottom.equalToSuperview().inset(20)
        }
        return stackView
    }
    
    func setupNavigationButton(withText text: String, andAction action: Selector) -> UIButton {
        let button = UIButton()
        button.setTitle(text, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.black.withAlphaComponent(0.5), for: .highlighted)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 10
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    func setupPageCounterLabel(withText text: String) -> UILabel {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textAlignment = .center
        label.textColor = .black
        label.text = text
        return label
    }
}

final class CharacterDetailViewConfigurator {
    func setupImageView(on superview: UIView) -> UIImageView {
        let imageView = UIImageView()
        imageView.backgroundColor = .white
        
        superview.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(superview.safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(240)
        }
        return imageView
    }
    
    func createTitleLabel(withText text: String, on superView: UIView, under underView: UIView) -> UILabel {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.tintColor = .black
        label.text = text
        
        superView.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.top.equalTo(underView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        
        return label
    }
    
    func setupCharacterLabels(on superview: UIView, titleLabels: [UILabel], characterLabels: [UILabel]) {
        for (index, label) in characterLabels.enumerated() {
            label.font = .systemFont(ofSize: 16)
            label.tintColor = .black
            label.textAlignment = .right
            
            superview.addSubview(label)

            label.snp.makeConstraints { make in
                make.top.equalTo(titleLabels[index].snp.top)
                make.trailing.equalToSuperview().inset(20)
                make.leading.equalTo(titleLabels[index].snp.trailing)
            }
        }
    }
    
    func setupTableView(on superview: UIView, under underView: UIView) -> UITableView {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "episodeCell")
        tableView.backgroundColor = .white
        
        superview.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(underView.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
        }
        return tableView
    }
}

final class EpisodeDetailViewConfigurator {
    func createTitleLabel(withText text: String,
                          on superview: UIView,
                          under underConstraint: ConstraintItem) -> UILabel {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.tintColor = .black
        label.text = text
        
        superview.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.top.equalTo(underConstraint).offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        
        return label
    }
    
    func setupCharacterLabels(on superview: UIView, titleLabels: [UILabel], characterLabels: [UILabel]) {
        for (index, label) in characterLabels.enumerated() {
            label.font = .systemFont(ofSize: 16)
            label.tintColor = .black
            label.textAlignment = .right
            
            superview.addSubview(label)

            label.snp.makeConstraints { make in
                make.top.equalTo(titleLabels[index].snp.top)
                make.trailing.equalToSuperview().inset(20)
                make.leading.equalTo(titleLabels[index].snp.trailing)
            }
        }
    }
    
    func setupCollectionView(on superView: UIView, under underView: UIView) -> UICollectionView {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 70, height: 70)
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: CGRect(), collectionViewLayout: layout)
        collectionView.register(CharacterCollectionViewCell.self, forCellWithReuseIdentifier: "characterCell")
        collectionView.backgroundColor = .white
        
        collectionView.alwaysBounceVertical = true
        
        superView.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(underView.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
        }
        return collectionView
    }
}
