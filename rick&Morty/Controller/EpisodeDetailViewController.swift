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
    private var characters = [Characters.Character]()
    
    private let apiClient: ApiClient = ApiClientImpl()
    private let viewConfigurator = ViewConfigurator.shared.episodeDetailViewConfigurator
    private let errorController = ErrorController.shared

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
        let episodeNameTitleLabel = viewConfigurator.createTitleLabel(withText: episodeNameText,
                                                                      on: view,
                                                                      under: safeAreaTop)
        let airDateText = "Air Date:"
        let airDateTitleLabel = viewConfigurator.createTitleLabel(withText: airDateText,
                                                                  on: view,
                                                                  under: episodeNameTitleLabel.snp.bottom)

        let titleLabels = [episodeNameTitleLabel, airDateTitleLabel]
        let characterLabels = [episodeNameLabel, airDateLabel]
        viewConfigurator.setupCharacterLabels(on: view, titleLabels: titleLabels, characterLabels: characterLabels)
    }
    
    private func setupCollectionView() {
        let charactersText = "Characters:"
        let charactersTitleLabel = viewConfigurator.createTitleLabel(withText: charactersText,
                                                                     on: view,
                                                                     under: airDateLabel.snp.bottom)
        
        charactersCollectionView = viewConfigurator.setupCollectionView(on: view, under: charactersTitleLabel)
        charactersCollectionView.dataSource = self
        charactersCollectionView.delegate = self
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
                        showError(error: error)
                    }
                }
            }
        }
    }
    
    private func showError(error: ApiError) {
        let alertController = errorController.createErrorController(error: error) { [unowned self] _ in
            guard let episode else { return }

            loadCharacters(for: episode)
        }
        present(alertController, animated: true)
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
        setImage(toCell: cell, fromUrl: imageUrl)
        
        return cell
    }
    
    private func setImage(toCell cell: CharacterCollectionViewCell, fromUrl imageUrl: URL?) {
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
