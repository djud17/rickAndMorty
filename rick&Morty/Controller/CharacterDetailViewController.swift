//
//  CharacterDetailViewController.swift
//  rick&Morty
//
//  Created by Давид Тоноян  on 21.05.2021.
//

import UIKit
import Kingfisher

final class CharacterDetailViewController: UIViewController {
    @IBOutlet weak var characterImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var speciesLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var episodesTableView: UITableView!
    
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
        navigationItem.title = "Details"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.backgroundColor = .white
        
        if let newCharacter = character {
            loadInfo(for: newCharacter)
            loadEpisodes(for: newCharacter)
        }
    }
    
    private func loadInfo(for newCharacter: Characters.Character) {
        let imageUrl = URL(string: newCharacter.image)
        let processor = DownsamplingImageProcessor(size: characterImageView.bounds.size)
        |> RoundCornerImageProcessor(cornerRadius: 10)
        characterImageView.kf.indicatorType = .activity
        characterImageView.kf.setImage(
            with: imageUrl,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
        
        nameLabel.text = newCharacter.name
        
        var color: UIColor
        switch newCharacter.status {
        case .alive:
            color = .green
        case .dead:
            color = .red
        default:
            color = .yellow
        }
        
        statusView.backgroundColor = color
        statusLabel.text = newCharacter.status.rawValue
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
                        episodesTableView?.reloadData()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "episodeCell")
        if let cell {
            let model = episodes[indexPath.row]
            
            cell.textLabel?.text = model.name
            cell.detailTextLabel?.text = model.episode
        }
                
        return cell ?? UITableViewCell()
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
