//
//  ApiClient.swift
//  rick&Morty
//
//  Created by Давид Тоноян  on 21.05.2021.
//

import Foundation
import Alamofire

enum ApiError: Error {
    case noData
    case wrongData
}

protocol ApiClient {
    func getAllCharacters(from urlString: String,
                          completion: @escaping (Result<Characters, ApiError>) -> Void)
    func getCharacter(from urlString: String,
                      completion: @escaping (Result<Characters.Character, ApiError>) -> Void)
    func getEpisode(from urlString: String,
                    completion: @escaping (Result<Characters.Episode, ApiError>) -> Void)
}

final class ApiClientImpl: ApiClient {
    func getAllCharacters(from urlString: String,
                          completion: @escaping (Result<Characters, ApiError>) -> Void) {
        let url = URL(string: urlString)
        if let url {
            AF.request(url).responseData {response in
                if let data = response.value {
                    do {
                        let jsonDecoder = JSONDecoder()
                        let characters = try jsonDecoder.decode(Characters.self, from: data )
                        completion(.success(characters))
                    } catch {
                        completion(.failure(.wrongData))
                    }
                } else {
                    completion(.failure(.noData))
                }
            }
        }
    }

    func getEpisode(from urlString: String, completion: @escaping (Result<Characters.Episode, ApiError>) -> Void) {
        let url = URL(string: urlString)
        if let url {
            AF.request(url).responseData {response in
                if let data = response.value {
                    do {
                        let jsonDecoder = JSONDecoder()
                        let episode = try jsonDecoder.decode(Characters.Episode.self, from: data)
                        completion(.success(episode))
                    } catch {
                        completion(.failure(.wrongData))
                    }
                } else {
                    completion(.failure(.noData))
                }
            }
        }
    }
    
    func getCharacter(from urlString: String, completion: @escaping (Result<Characters.Character, ApiError>) -> Void) {
        let url = URL(string: urlString)
        if let url {
            AF.request(url).responseData {response in
                if let data = response.value {
                    do {
                        let jsonDecoder = JSONDecoder()
                        let character = try jsonDecoder.decode(Characters.Character.self, from: data)
                        completion(.success(character))
                    } catch {
                        completion(.failure(.wrongData))
                    }
                } else {
                    completion(.failure(.noData))
                }
            }
        }
    }
}
