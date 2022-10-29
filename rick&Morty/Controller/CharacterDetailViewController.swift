//
//  CharacterDetailViewController.swift
//  rick&Morty
//
//  Created by Давид Тоноян  on 21.05.2021.
//

import UIKit
import Kingfisher

final class CharacterDetailViewController: UIViewController {
    private var characterImageView = UIImageView()
    private let statusLabel = UILabel()
    private let speciesLabel = UILabel()
    private let locationLabel = UILabel()
    private var episodesTableView = UITableView()
    
    var character: Characters.Character?
    private var episodes: [Characters.Episode] = [] {
        didSet {
            episodes.sort {$0.episode < $1.episode}
        }
    }
    private let apiClient: ApiClient = ApiClientImpl()
    private let viewConfigurator = ViewConfigurator.shared.characterDetailViewController
    private let errorController = ErrorController.shared

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    private func setupView() {
        guard let character else { return }
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = character.name
        
        view.backgroundColor = .white
        
        characterImageView = viewConfigurator.setupImageView(on: view)
        setupLabels()
        setupTableView()
        
        loadInfo(for: character)
        loadEpisodes(for: character)
    }
    
    private func setupLabels() {
        let statusText = "Status:"
        let statusTitleLabel = viewConfigurator.createTitleLabel(withText: statusText,
                                                                 on: view,
                                                                 under: characterImageView)
        let speciesText = "Species and gender:"
        let speciesTitleLabel = viewConfigurator.createTitleLabel(withText: speciesText,
                                                                  on: view,
                                                                  under: statusTitleLabel)
        let locationText = "Location:"
        let locationTitleLabel = viewConfigurator.createTitleLabel(withText: locationText,
                                                                   on: view,
                                                                   under: speciesTitleLabel)
        let titleLabels = [statusTitleLabel, speciesTitleLabel, locationTitleLabel]
        let characterLabels = [statusLabel, speciesLabel, locationLabel]
        viewConfigurator.setupCharacterLabels(on: view,
                                              titleLabels: titleLabels,
                                              characterLabels: characterLabels)
    }
    
    private func setupTableView() {
        let episodesText = "Episodes:"
        let episodesTitleLabel = viewConfigurator.createTitleLabel(withText: episodesText,
                                                                   on: view,
                                                                   under: locationLabel)
        
        episodesTableView = viewConfigurator.setupTableView(on: view, under: episodesTitleLabel)
        episodesTableView.delegate = self
        episodesTableView.dataSource = self
    }
    
    private func loadInfo(for newCharacter: Characters.Character) {
        let imageUrl = URL(string: newCharacter.image)
        let imageSize = CGSize(width: view.frame.size.width, height: 240)
        let processor = DownsamplingImageProcessor(size: imageSize)
        characterImageView.kf.indicatorType = .activity
        characterImageView.kf.setImage(
            with: imageUrl,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
        
        statusLabel.text = newCharacter.status.rawValue
        statusLabel.textColor = newCharacter.getStatusColor()
        speciesLabel.text = newCharacter.species
        locationLabel.text = newCharacter.location.name
    }
    
    private func loadEpisodes(for newCharacter: Characters.Character) {
        for index in 0...newCharacter.episode.count - 1 {
            let episodeURL = newCharacter.episode[index]
            apiClient.getEpisode(from: episodeURL) { result in
                DispatchQueue.main.async { [unowned self] in
                    switch result {
                    case .success(let result):
                        episodes.append(result)
                        episodesTableView.reloadData()
                    case .failure(let error):
                        showError(error: error)
                    }
                }
            }
        }
    }
    
    private func showError(error: ApiError) {
        let alertController = errorController.createErrorController(error: error) { [unowned self] _ in
            guard let character else { return }

            loadEpisodes(for: character)
        }
        present(alertController, animated: true)
    }
}

extension CharacterDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        episodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "episodeCell") else { return UITableViewCell() }

        let model = episodes[indexPath.row]
        cell.textLabel?.text = "\(model.name) - \(model.episode)"
                
        return cell
    }
}

extension CharacterDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = EpisodeDetailViewController()
        viewController.episode = episodes[indexPath.row]
        
        navigationController?.pushViewController(viewController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
