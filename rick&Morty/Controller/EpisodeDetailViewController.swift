//
//  EpisodeDetailViewController.swift
//  rick&Morty
//
//  Created by Давид Тоноян  on 21.05.2021.
//

import UIKit
import Kingfisher
import SnapKit

final class EpisodeDetailViewController: UIViewController {
    private let episodeNameLabel = UILabel()
    private let airDateLabel = UILabel()
    private var charactersCollectionView: UICollectionView!
    
    var episode: Characters.Episode?
    private var characters: [Characters.Character] = []
    
    private let apiClient: ApiClient = ApiClientImpl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    private func setupView() {
        guard let episode else { return }
        
        navigationItem.title = "Episode \(episode.episode)"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.backgroundColor = .white
        
        setupLabels()
        setupCollectionView()
        
        loadCharacters(for: episode)
        episodeNameLabel.text = episode.name
        airDateLabel.text = episode.airDate
    }
    
    private func setupLabels() {
        let episodeNameText = "Name:"
        let safeAreaTop = view.safeAreaLayoutGuide.snp.top
        let episodeNameTitleLabel = createTitleLabel(withText: episodeNameText, under: safeAreaTop)

        let airDateText = "Air Date:"
        let airDateTitleLabel = createTitleLabel(withText: airDateText, under: episodeNameTitleLabel.snp.bottom)

        let titleLabels = [episodeNameTitleLabel, airDateTitleLabel]

        for (index, label) in [episodeNameLabel, airDateLabel].enumerated() {
            label.font = .systemFont(ofSize: 16)
            label.tintColor = .black
            label.textAlignment = .right
            
            view.addSubview(label)

            label.snp.makeConstraints { make in
                make.top.equalTo(titleLabels[index].snp.top)
                make.trailing.equalToSuperview().inset(20)
                make.leading.equalTo(titleLabels[index].snp.trailing)
            }
        }
    }
    
    private func createTitleLabel(withText text: String, under underConstraint: ConstraintItem) -> UILabel {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.tintColor = .black
        label.text = text
        
        view.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.top.equalTo(underConstraint).offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        
        return label
    }
    
    private func setupCollectionView() {
        let charactersText = "Characters:"
        let charactersTitleLabel = createTitleLabel(withText: charactersText, under: airDateLabel.snp.bottom)
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 70, height: 70)
        layout.scrollDirection = .vertical
        
        charactersCollectionView = UICollectionView(frame: CGRect(), collectionViewLayout: layout)
        charactersCollectionView.register(CharacterCollectionViewCell.self, forCellWithReuseIdentifier: "characterCell")
        charactersCollectionView.backgroundColor = .white
        
        charactersCollectionView.dataSource = self
        charactersCollectionView.delegate = self
        charactersCollectionView.alwaysBounceVertical = true
        
        view.addSubview(charactersCollectionView)
        
        charactersCollectionView.snp.makeConstraints { make in
            make.top.equalTo(charactersTitleLabel.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func loadCharacters(for newEpisode: Characters.Episode) {
        for index in 0...newEpisode.characters.count - 1 {
            let episodeURL = newEpisode.characters[index]
            apiClient.getCharacter(from: episodeURL) { result in
                DispatchQueue.main.async { [unowned self] in
                    switch result {
                    case .success(let result):
                        characters.append(result)
                        charactersCollectionView.reloadData()
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
}

extension EpisodeDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        characters.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "characterCell",
                                                            for: indexPath) as? CharacterCollectionViewCell else {
            return UICollectionViewCell()
        }
        let character = characters[indexPath.row]
        let imageUrl = URL(string: character.image)
        let imageSize = CGSize(width: 70, height: 70)
        let processor = DownsamplingImageProcessor(size: imageSize)
        |> RoundCornerImageProcessor(cornerRadius: 10)
        cell.characterImageView.kf.indicatorType = .activity
        cell.characterImageView.kf.setImage(
            with: imageUrl,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
        
        return cell
    }
}

extension EpisodeDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let viewController = CharacterDetailViewController()
        viewController.character = characters[indexPath.row]
        
        navigationController?.pushViewController(viewController, animated: true)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
