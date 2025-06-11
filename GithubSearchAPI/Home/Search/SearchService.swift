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
}

enum SearchServiceError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case noData
    case decodingError(Error)
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
