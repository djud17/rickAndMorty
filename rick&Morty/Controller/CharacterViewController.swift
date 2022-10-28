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

final class CharacterViewController: UIViewController {
    private let charactersTableView = UITableView()
    private let pageNavigationStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        return stackView
    }()
    private let pageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    private let previousPageButton: UIButton = {
        let button = UIButton()
        button.setTitle("Previous", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.setTitleColor(.blue.withAlphaComponent(0.5), for: .highlighted)
        return button
    }()
    private let nextPageButton: UIButton = {
        let button = UIButton()
        button.setTitle("Next", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.setTitleColor(.blue.withAlphaComponent(0.5), for: .highlighted)
        return button
    }()
    
    private var charactersInfo = Characters.Info(next: "", prev: "")
    private var counter = 1
    private var charactersArray: [Characters.Character] = []
    private let apiClient: ApiClient = ApiClientImpl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    private func setupView() {
        navigationItem.title = "Rick & Morty"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.backgroundColor = .white
        
        pageLabel.text = String(counter)
        
        setupTableView()
        setupPageNavigation()
        
        let url = UrlAdresses.allCharacters.rawValue
        loadData(from: url)
    }
    
    private func setupTableView() {
        charactersTableView.register(CharacterTableViewCell.self, forCellReuseIdentifier: "characterCell")
        charactersTableView.backgroundColor = .white
        charactersTableView.separatorColor = .white
        
        charactersTableView.dataSource = self
        charactersTableView.delegate = self
        
        view.addSubview(charactersTableView)
        
        charactersTableView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(40)
        }
    }
    
    private func setupPageNavigation() {
        [previousPageButton, pageLabel, nextPageButton].forEach {
            pageNavigationStackView.addArrangedSubview($0)
        }
        
        view.addSubview(pageNavigationStackView)
        
        previousPageButton.addTarget(self, action: #selector(previousBtnTapped), for: .touchUpInside)
        nextPageButton.addTarget(self, action: #selector(nextBtnTapped), for: .touchUpInside)
        
        pageNavigationStackView.snp.makeConstraints { make in
            make.top.equalTo(charactersTableView.snp.bottom)
            make.leading.equalToSuperview().offset(20)
            make.trailing.bottom.equalToSuperview().inset(20)
        }
    }
    
    private func loadData(from url: String) {
        apiClient.getAllCharacters(from: url) { result in
            DispatchQueue.main.async { [unowned self] in
                switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                case .success(let result):
                    charactersArray = result.results
                    charactersInfo = result.info
                    charactersTableView.reloadData()
                    print(charactersArray.count)
                }
            }
        }
    }
    
    @objc private func nextBtnTapped() {
        if let nextUrl = charactersInfo.next {
            loadData(from: nextUrl)
            charactersTableView.scrollToRow(at: IndexPath(row: 0, section: 0),
                                            at: .top, animated: true)
            counter += 1
            pageLabel.text = String(counter)
        }
    }
    
    @objc private func previousBtnTapped() {
        if let prevUrl = charactersInfo.prev {
            loadData(from: prevUrl)
            charactersTableView.scrollToRow(at: IndexPath(row: 0, section: 0),
                                            at: .top, animated: true)
            counter -= 1
            pageLabel.text = String(counter)
        }
    }
    
}

extension CharacterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        charactersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "characterCell")
                as? CharacterTableViewCell else { return UITableViewCell() }
        
        let model = charactersArray[indexPath.row]
        
        let imageUrl = URL(string: model.image)
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
        
        let statusColor = getStatusColor(for: model.status)
        cell.statusColorView.backgroundColor = statusColor
        cell.characterNameLabel.text = model.name
        cell.characterLocationLabel.text = model.location.name
        cell.characterStatusLabel.text = model.status.rawValue

        return cell
    }
    
    private func getStatusColor(for status: Characters.Status) -> UIColor {
        var color: UIColor
        switch status {
        case .alive:
            color = .green
        case .dead:
            color = .red
        case .unknown:
            color = .yellow
        }
        return color
    }
}

extension CharacterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = CharacterDetailViewController()
        viewController.character = charactersArray[indexPath.row]

        navigationController?.pushViewController(viewController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
