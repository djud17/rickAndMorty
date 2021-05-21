//
//  ViewController.swift
//  rick&Morty
//
//  Created by Давид Тоноян  on 21.05.2021.
//

import UIKit

class CharacterViewController: UIViewController {
    @IBOutlet weak var charactersTableView: UITableView!
    
    var characters: [Character] = []
    let apiClient: ApiClient = ApiClientImpl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Rick & Morty"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        loadData()
    }
    
    func loadData() {
        apiClient.getAllCharacters(completion: { result in
            DispatchQueue.main.async {
                self.characters = result.results
                self.charactersTableView.reloadData()
            }
        })
    }
}

extension CharacterViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        characters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "characterCell") as! CharacterTableViewCell
        let model = characters[indexPath.row]
        
        cell.characterNameLabel.text = model.name
        cell.characterLocationLabel.text = model.location.name
        cell.characterStatusLabel.text = model.status.rawValue
        cell.characterImageView.load(URL(string: model.image)!)
        
        switch model.status {
        case .alive: cell.statusColorView.backgroundColor = UIColor.green
        case .dead: cell.statusColorView.backgroundColor = UIColor.red
        default: cell.statusColorView.backgroundColor = UIColor.yellow
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateViewController(identifier: "characterDetail") as! CharacterDetailViewController
        
        viewController.character = characters[indexPath.row]
        
        navigationController?.pushViewController(viewController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension UIImageView {
    func load(_ url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}

