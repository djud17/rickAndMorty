//
//  ViewController.swift
//  rick&Morty
//
//  Created by Давид Тоноян  on 21.05.2021.
//

import UIKit
import Kingfisher

enum UrlAdresses: String {
    case allCharacters = "https://rickandmortyapi.com/api/character"
}

final class CharactersViewController: UIViewController {
    private var charactersTableView = UITableView()
    private var pageNavigationStackView = UIStackView()
    private var pageLabel = UILabel()
    
    private let apiClient: ApiClient = ApiClientImpl()
    private let viewConfigurator = ViewConfigurator.shared.characterListVCViewConfigurator
    private let errorController = ErrorController.shared
    
    private let urlAllCharacters = UrlAdresses.allCharacters.rawValue
    private var charactersInfo = Characters.Info(next: "", prev: "")
    private var counter = 1 {
        didSet {
            pageLabel.text = String(counter)
        }
    }
    private var charactersArray = [Characters.Character]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        loadData(from: urlAllCharacters)
    }
    
    private func setupView() {
        navigationItem.title = "Rick & Morty"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.backgroundColor = .white
        
        charactersTableView = viewConfigurator.setupTableView(on: view)
        charactersTableView.dataSource = self
        charactersTableView.delegate = self
        
        pageLabel = viewConfigurator.setupPageCounterLabel(withText: String(counter))
        
        let previousPageButton = viewConfigurator.setupNavigationButton(withText: "Previous")
        previousPageButton.addTarget(self, action: #selector(previousBtnTapped), for: .touchUpInside)
        
        let nextPageButton = viewConfigurator.setupNavigationButton(withText: "Next")
        nextPageButton.addTarget(self, action: #selector(nextBtnTapped), for: .touchUpInside)
        
        let navigationArray = [previousPageButton, pageLabel, nextPageButton]
        pageNavigationStackView = viewConfigurator.setupPageNavigation(on: view,
                                                                       under: charactersTableView,
                                                                       with: navigationArray)
    }
    
    private func loadData(from url: String) {
        apiClient.getAllCharacters(from: url) { result in
            DispatchQueue.main.async { [unowned self] in
                switch result {
                case .failure(let error):
                    showError(error: error)
                case .success(let result):
                    charactersArray = result.results
                    charactersInfo = result.info
                    charactersTableView.reloadData()
                }
            }
        }
    }
    
    private func showError(error: ApiError) {
        let alertController = errorController.createErrorController(error: error) { [unowned self] _ in
            loadData(from: urlAllCharacters)
        }
        present(alertController, animated: true)
    }
    
    @objc private func nextBtnTapped() {
        if let nextUrl = charactersInfo.next {
            loadData(from: nextUrl)
            charactersTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            counter += 1
        }
    }
    
    @objc private func previousBtnTapped() {
        if let previousUrl = charactersInfo.prev {
            loadData(from: previousUrl)
            charactersTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            counter -= 1
        }
    }
}

extension CharactersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        charactersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "characterCell")
                as? CharacterTableViewCell else { return UITableViewCell()}
        
        let model = charactersArray[indexPath.row]
        
        let imageUrl = URL(string: model.image)
        setImage(toCell: cell, fromUrl: imageUrl)
        cell.statusColorView.backgroundColor = model.getStatusColor()
        cell.characterNameLabel.text = model.name
        cell.characterLocationLabel.text = model.location.name
        cell.characterStatusLabel.text = model.status.rawValue

        return cell
    }
    
    private func setImage(toCell cell: CharacterTableViewCell, fromUrl imageUrl: URL?) {
        let imageSize = CGSize(width: 100, height: 100)
        let processor = DownsamplingImageProcessor(size: imageSize)
        |> RoundCornerImageProcessor(cornerRadius: 20)
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

extension CharactersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = CharacterDetailViewController()
        viewController.character = charactersArray[indexPath.row]

        navigationController?.pushViewController(viewController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
