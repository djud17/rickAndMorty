//
//  CharacterDetailViewController.swift
//  rick&Morty
//
//  Created by Давид Тоноян  on 21.05.2021.
//

import UIKit
import Kingfisher
import SnapKit

final class CharacterDetailViewController: UIViewController {
    private let characterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .white
        return imageView
    }()
    private let statusLabel = UILabel()
    private let speciesLabel = UILabel()
    private let locationLabel = UILabel()
    private let episodesTableView = UITableView()
    
    var character: Characters.Character?
    private var episodes: [Characters.Episode] = [] {
        didSet {
            episodes.sort {$0.episode < $1.episode}
        }
    }
    private let apiClient: ApiClient = ApiClientImpl()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    private func setupView() {
        guard let character else { return }
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = character.name
        
        view.backgroundColor = .white
        
        setupImageView()
        setupLabels()
        setupTableView()
        
        loadInfo(for: character)
        loadEpisodes(for: character)
    }
    
    private func setupImageView() {
        view.addSubview(characterImageView)
        
        characterImageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(240)
        }
    }
    
    private func setupLabels() {
        let statusText = "Status:"
        let statusTitleLabel = createTitleLabel(withText: statusText, under: characterImageView)

        let speciesText = "Species and gender:"
        let speciesTitleLabel = createTitleLabel(withText: speciesText, under: statusTitleLabel)

        let locationText = "Location:"
        let locationTitleLabel = createTitleLabel(withText: locationText, under: speciesTitleLabel)

        let titleLabels = [statusTitleLabel, speciesTitleLabel, locationTitleLabel]

        for (index, label) in [statusLabel, speciesLabel, locationLabel].enumerated() {
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
    
    private func setupTableView() {
        let episodesText = "Episodes:"
        let episodesTitleLabel = createTitleLabel(withText: episodesText, under: locationLabel)
        
        episodesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "episodeCell")
        episodesTableView.delegate = self
        episodesTableView.dataSource = self
        episodesTableView.backgroundColor = .white
        
        view.addSubview(episodesTableView)
        
        episodesTableView.snp.makeConstraints { make in
            make.top.equalTo(episodesTitleLabel.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func createTitleLabel(withText text: String, under underView: UIView) -> UILabel {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 18)
        label.tintColor = .black
        label.text = text
        
        view.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.top.equalTo(underView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
        }
        
        return label
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
                        print(error.localizedDescription)
                    }
                }
            }
        }
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
