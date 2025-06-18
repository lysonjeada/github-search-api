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
                let users = try JSONDecoder().decode([GitHubUser].self, from: data)
                DispatchQueue.main.async { completion(.success(users)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(.decodingError(error))) }
            }
        }
        
        task.resume()
    }
}
