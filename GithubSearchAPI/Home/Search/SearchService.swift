//
//  SearchService.swift
//  GithubSearchAPI
//
//  Created by Amaryllis Baldrez on 09/06/25.
//

import Foundation

import Foundation

protocol SearchServiceProtocol {
    func searchUser(username: String, completion: @escaping (Result<GitHubUser, SearchServiceError>) -> Void)
    func getRepository(owner: String, repoName: String, completion: @escaping (Result<Repository, SearchServiceError>) -> Void)
}

enum SearchServiceError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case noData
    case decodingError(Error)
    case notFound
}

class SearchService: SearchServiceProtocol {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func searchUser(username: String, completion: @escaping (Result<GitHubUser, SearchServiceError>) -> Void) {
        guard let url = URL(string: "https://api.github.com/users/\(username)") else {
            print("[SearchService] ❌ Invalid URL for username: \(username)")
            DispatchQueue.main.async {
                completion(.failure(.invalidURL))
            }
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
        // request.setValue("Bearer YOUR_TOKEN", forHTTPHeaderField: "Authorization")

        print("[SearchService] 🔍 Starting request for user: \(username)")

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("[SearchService] ❌ Request failed: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(.requestFailed(error)))
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("[SearchService] ❌ Invalid HTTP response")
                DispatchQueue.main.async {
                    completion(.failure(.invalidResponse))
                }
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

            print("[SearchService] ✅ Response status code: \(httpResponse.statusCode)")

            guard let data = data else {
                print("[SearchService] ❌ No data received")
                DispatchQueue.main.async {
                    completion(.failure(.noData))
                }
                return
            }

            do {
                let user = try JSONDecoder().decode(GitHubUser.self, from: data)
                print("[SearchService] 👤 Successfully decoded user: \(user.login)")
                DispatchQueue.main.async {
                    completion(.success(user))
                }
            } catch {
                print("[SearchService] ❌ Decoding error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(.decodingError(error)))
                }
            }
        }.resume()
    }
}

extension SearchService {
    func getRepository(owner: String, repoName: String, completion: @escaping (Result<Repository, SearchServiceError>) -> Void) {
        let endpoint = "https://api.github.com/repos/\(owner)/\(repoName)"
        
        guard let url = URL(string: endpoint) else {
            print("[SearchService] ❌ Invalid URL for repository: \(owner)/\(repoName)")
            DispatchQueue.main.async {
                completion(.failure(.invalidURL))
            }
            return
        }

        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
        // request.setValue("Bearer YOUR_TOKEN", forHTTPHeaderField: "Authorization")

        print("[SearchService] 🔍 Starting request for repository: \(owner)/\(repoName)")

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("[SearchService] ❌ Request failed: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(.requestFailed(error)))
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("[SearchService] ❌ Invalid HTTP response")
                DispatchQueue.main.async {
                    completion(.failure(.invalidResponse))
                }
                return
            }

            print("[SearchService] ✅ Response status code: \(httpResponse.statusCode)")

            guard let data = data else {
                print("[SearchService] ❌ No data received")
                DispatchQueue.main.async {
                    completion(.failure(.noData))
                }
                return
            }

            do {
                let repository = try JSONDecoder().decode(Repository.self, from: data)
                print("[SearchService] 📦 Successfully decoded repository: \(repository.fullName)")
                DispatchQueue.main.async {
                    completion(.success(repository))
                }
            } catch {
                print("[SearchService] ❌ Decoding error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(.decodingError(error)))
                }
            }
        }.resume()
    }
}
