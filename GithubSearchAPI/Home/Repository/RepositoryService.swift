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
    
    func fetchRepositories(page: Int, perPage: Int = 7, completion: @escaping (Result<[Repository], RepositoryError>) -> Void) {
        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(perPage)"),
            URLQueryItem(name: "sort", value: "updated")
        ]
        guard let url = components?.url else {
            completion(.failure(.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        print("[RepositoryService] 🌐 Starting request to: \(url.absoluteString)")
        
        if let token = ProcessInfo.processInfo.environment["GITHUB_TOKEN"] {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("Token não encontrado. Configure no esquema.")
        }
        
        let task = session.dataTask(with: request) { data, response, error in
            // Log networking error
            if let error = error {
                print("[RepositoryService] ❌ Request failed with error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(.requestFailed(error)))
                }
                return
            }
            
            // Log invalid response
            guard let httpResponse = response as? HTTPURLResponse else {
                print("[RepositoryService] ❌ Invalid HTTP response")
                DispatchQueue.main.async {
                    completion(.failure(.invalidResponse))
                }
                return
            }
            
            print("[RepositoryService] ✅ Response status code: \(httpResponse.statusCode)")
            
            // Log missing data
            guard let data = data else {
                print("[RepositoryService] ❌ No data received")
                DispatchQueue.main.async {
                    completion(.failure(.invalidData))
                }
                return
            }
            
            // Attempt to decode data
            do {
                let repositories = try JSONDecoder().decode([Repository].self, from: data)
                print("[RepositoryService] 📦 Successfully decoded \(repositories.count) repositories")
                print(repositories)
                DispatchQueue.main.async {
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
