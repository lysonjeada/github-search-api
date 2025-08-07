//
//  UserService.swift
//  GithubSearchAPI
//
//  Created by Amaryllis Baldrez on 14/06/25.
//

import Foundation

protocol UserServiceProtocol {
    func fetchUsers(page: Int, perPage: Int, completion: @escaping (Result<[GitHubUser], UserError>) -> Void)
}

enum UserError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case notFound
    case invalidData
    case decodingError(Error)
}

final class UserService: UserServiceProtocol {
    private let session: URLSession
    private let baseURL = "https://api.github.com/users"
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetchUsers(page: Int, perPage: Int = 10, completion: @escaping (Result<[GitHubUser], UserError>) -> Void) {
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "since", value: "\((page - 1) * perPage)"),
            URLQueryItem(name: "per_page", value: "\(perPage)")
        ]
        
        guard let url = components?.url else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
        
        if let token = ProcessInfo.processInfo.environment["GITHUB_TOKEN"] {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("Token não encontrado. Configure no esquema.")
        }
        print("[UserService] 🌐 Requesting: \(url.absoluteString)")
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(.requestFailed(error))) }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async { completion(.failure(.invalidResponse)) }
                return
            }

            switch httpResponse.statusCode {
            case 200:
                break 
            case 404:
                DispatchQueue.main.async { completion(.failure(.notFound)) }
                return
            default:
                DispatchQueue.main.async { completion(.failure(.invalidResponse)) }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(.invalidData)) }
                return
            }
            
            do {
                var users = try JSONDecoder().decode([GitHubUser].self, from: data)
                
                let group = DispatchGroup()

                for index in users.indices {
                    if let reposUrl = users[index].reposURL {
                        group.enter()
                        self.fetchRepos(from: reposUrl) { result in
                            switch result {
                            case .success(let repos):
                                users[index].repos = repos
                            case .failure(let failure):
                                users[index].repos = []
                            }
                            
                            group.leave()
                        }
                    }
                }

                group.notify(queue: .main) {
                    print("[RepositoryService] ✅ All repos fetched")
                    completion(.success(users))
                }
            } catch {
                DispatchQueue.main.async { completion(.failure(.decodingError(error))) }
            }
        }
        
        task.resume()
    }
}

extension UserService {
    func fetchRepos(from urlString: String, completion: @escaping (Result<[RepositoryOwnerr], UserError>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")

        if let token = ProcessInfo.processInfo.environment["GITHUB_TOKEN"] {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        session.dataTask(with: request) { data, response, error in
            guard
                let data = data,
                let result = try? JSONDecoder().decode([RepositoryOwnerr].self, from: data)
            else {
                completion(.failure(.decodingError(error ?? NSError(domain: "", code: 0, userInfo: nil))))
                return
            }

            completion(.success(result))
        }.resume()
    }
}

import Foundation

// MARK: - Owner
struct RepositoryOwnerr: Codable {
    let login: String?
    let id: Int?
    let nodeID: String?
    let avatarURL: String?
    let gravatarID: String?
    let url: String?
    let htmlURL: String?
    let followersURL: String?
    let followingURL: String?
    let gistsURL: String?
    let starredURL: String?
    let subscriptionsURL: String?
    let organizationsURL: String?
    let reposURL: String?
    let eventsURL: String?
    let receivedEventsURL: String?
    let type: String?
    let userViewType: String?
    let siteAdmin: Bool?

    enum CodingKeys: String, CodingKey {
        case login, id
        case nodeID = "node_id"
        case avatarURL = "avatar_url"
        case gravatarID = "gravatar_id"
        case url
        case htmlURL = "html_url"
        case followersURL = "followers_url"
        case followingURL = "following_url"
        case gistsURL = "gists_url"
        case starredURL = "starred_url"
        case subscriptionsURL = "subscriptions_url"
        case organizationsURL = "organizations_url"
        case reposURL = "repos_url"
        case eventsURL = "events_url"
        case receivedEventsURL = "received_events_url"
        case type
        case userViewType = "user_view_type"
        case siteAdmin = "site_admin"
    }
}

// MARK: - License
struct License: Codable {
    let key: String?
    let name: String?
    let spdxID: String?
    let url: String?
    let nodeID: String?

    enum CodingKeys: String, CodingKey {
        case key, name
        case spdxID = "spdx_id"
        case url
        case nodeID = "node_id"
    }
}
