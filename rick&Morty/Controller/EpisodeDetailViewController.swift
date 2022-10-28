//
//  EpisodeDetailViewController.swift
//  rick&Morty
//
//  Created by Давид Тоноян  on 21.05.2021.
//

import UIKit
import Kingfisher

final class EpisodeDetailViewController: UIViewController {
    @IBOutlet weak var episodeNameLabel: UILabel!
    @IBOutlet weak var airDateLabel: UILabel!
    @IBOutlet weak var episodeLabel: UILabel!
    @IBOutlet weak var charactersCollectionView: UICollectionView!
    
    var episode: Characters.Episode?
    private var characters: [Characters.Character] = []
    
    private let apiClient: ApiClient = ApiClientImpl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    private func setupView() {
        navigationItem.title = "Episode"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        if let newEpisode = episode {
            loadCharacters(for: newEpisode)
            episodeNameLabel.text = newEpisode.name
            airDateLabel.text = newEpisode.airDate
            episodeLabel.text = newEpisode.episode
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "characterCell",
                                                      for: indexPath) as? CharacterCollectionViewCell
        if let cell {
            let imageUrl = URL(string: characters[indexPath.row].image)!
            cell.frame.size = CGSize(width: 70, height: 70)
            let processor = DownsamplingImageProcessor(size: cell.characterImageView.bounds.size)
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
        
        return cell ?? UICollectionViewCell()
    }
}

extension EpisodeDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let viewController = CharacterDetailViewController()
        viewController.character = characters[indexPath.row]
        
        navigationController?.pushViewController(viewController, animated: true)
    }
}
