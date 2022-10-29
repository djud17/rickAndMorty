//
//  characterModel.swift
//  rick&Morty
//
//  Created by Давид Тоноян  on 21.05.2021.
//

import UIKit

// MARK: - Characters
struct Characters: Decodable {
    let info: Info
    let results: [Character]
}

extension Characters {
    // MARK: - Info
    struct Info: Decodable {
        let next: String?
        let prev: String?
    }

    // MARK: - Result
    struct Character: Decodable {
        let id: Int
        let name: String
        let status: Status
        let species: String
        let type: String
        let gender: String
        let origin, location: Location
        let image: String
        let episode: [String]
        let url: String
        let created: String
        
        func getStatusColor() -> UIColor {
            let color: UIColor = {
                switch status {
                case .alive:
                    return .green
                case .dead:
                    return .red
                case .unknown:
                    return .yellow
                }
            }()
            return color
        }
    }

    // MARK: - Location
    struct Location: Decodable {
        let name: String
        let url: String
    }

    enum Status: String, Decodable {
        case alive = "Alive"
        case dead = "Dead"
        case unknown = "unknown"
    }

    struct Episode: Decodable {
        let id: Int
        let name, airDate, episode: String
        let characters: [String]
        let url: String
        let created: String

        enum CodingKeys: String, CodingKey {
            case id, name
            case airDate = "air_date"
            case episode, characters, url, created
        }
    }
}
