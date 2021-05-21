//
//  CharacterDetailViewController.swift
//  rick&Morty
//
//  Created by Давид Тоноян  on 21.05.2021.
//

import UIKit

class CharacterDetailViewController: UIViewController {
    
    @IBOutlet weak var characterImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var speciesLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var episodesTableView: UITableView!
    
    var character: Character?
    var episodes: [Episode] = []
    
    let apiClient: ApiClient = ApiClientImpl()

    override func viewDidLoad() {
        super.viewDidLoad()
        if let newCharacter = character {
            loadInfo(newCharacter)
            loadEpisodes(newCharacter)
        }
    }
    
    func loadInfo(_ newCharacter: Character) {
        characterImageView.load(URL(string: newCharacter.image)!)
        nameLabel.text = newCharacter.name
        
        statusView.layer.cornerRadius = statusView.frame.size.width / 2
        statusView.layer.masksToBounds = true
        
        switch newCharacter.status {
        case .alive: statusView.backgroundColor = UIColor.green
        case .dead: statusView.backgroundColor = UIColor.red
        default: statusView.backgroundColor = UIColor.yellow
        }
        
        statusLabel.text = newCharacter.status.rawValue
        speciesLabel.text = newCharacter.species.rawValue
        locationLabel.text = newCharacter.location.name
    }
    
    func loadEpisodes(_ newCharacter: Character){
        for i in 0...newCharacter.episode.count-1 {
            let episodeURL = newCharacter.episode[i]
            apiClient.getEpisode(episodeURL) { result in
                DispatchQueue.main.async {
                    self.episodes.append(result)
                    self.episodesTableView.reloadData()
                }
            }
        }
        
    }
}

extension CharacterDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "episodeCell")
        let model = episodes[indexPath.row]
        
        cell?.textLabel?.text = model.name
        cell?.detailTextLabel?.text = model.episode
                
        return cell!
    }
    
    
}
