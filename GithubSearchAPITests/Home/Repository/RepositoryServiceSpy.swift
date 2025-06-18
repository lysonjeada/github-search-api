//
//  RepositoryServiceSpy.swift
//  GithubSearchAPI
//
//  Created by Amaryllis Baldrez on 18/06/25.
//

@testable import GithubSearchAPI

final class RepositoryServiceSpy: RepositoryServiceProtocol {
    var fetchRepositoriesHandler: ((Int, Int, @escaping (Result<[Repository], GithubSearchAPI.RepositoryError>) -> Void) -> Void)?
    
    func fetchRepositories(page: Int, perPage: Int, completion: @escaping (Result<[Repository], GithubSearchAPI.RepositoryError>) -> Void) {
        fetchRepositoriesHandler?(page, perPage, completion)
    }
}
