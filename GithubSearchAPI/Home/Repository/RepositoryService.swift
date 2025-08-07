//
//  RepositoryService.swift
//  GithubSearchAPI
//
//  Created by Amaryllis Baldrez on 09/06/25.
//

import Foundation

protocol RepositoryServiceProtocol {
    func fetchRepositories(page: Int, perPage: Int, completion: @escaping (Result<[Repository], RepositoryError>) -> Void)
}

enum RepositoryError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case invalidData
    case decodingError(Error)
}

class RepositoryService: RepositoryServiceProtocol {
    private let session: URLSession
    private let baseURL = "https://api.github.com/repositories"
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetchRepositories(page: Int, perPage: Int = 4, completion: @escaping (Result<[Repository], RepositoryError>) -> Void) {
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

        if let token = ProcessInfo.processInfo.environment["GITHUB_TOKEN"] {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("[RepositoryService] ⚠️ Token não encontrado. Configure no esquema.")
        }

        print("[RepositoryService] 🌐 Starting request to: \(url.absoluteString)")

        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("[RepositoryService] ❌ Request failed with error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(.requestFailed(error)))
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("[RepositoryService] ❌ Invalid HTTP response")
                DispatchQueue.main.async {
                    completion(.failure(.invalidResponse))
                }
                return
            }

            print("[RepositoryService] ✅ Response status code: \(httpResponse.statusCode)")

            guard let data = data else {
                print("[RepositoryService] ❌ No data received")
                DispatchQueue.main.async {
                    completion(.failure(.invalidData))
                }
                return
            }

            do {
                var repositories = try JSONDecoder().decode([Repository].self, from: data)
                print("[RepositoryService] 📦 Decoded \(repositories.count) repositories")

                let group = DispatchGroup()

                for index in repositories.indices {
                    if let languagesUrl = repositories[index].languagesUrl {
                        group.enter()
                        self.fetchLanguages(from: languagesUrl) { languages in
                            repositories[index].languages = languages
                            group.leave()
                        }
                    }
                }

                group.notify(queue: .main) {
                    print("[RepositoryService] ✅ All languages fetched")
                    completion(.success(repositories))
                }

            } catch {
                print("[RepositoryService] ❌ Decoding error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(.decodingError(error)))
                }
            }
        }

        task.resume()
    }

}

extension RepositoryService {
    func fetchLanguages(from urlString: String, completion: @escaping ([String: Int]?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
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
                let result = try? JSONDecoder().decode([String: Int].self, from: data)
            else {
                completion(nil)
                return
            }

            completion(result)
        }.resume()
    }
}
