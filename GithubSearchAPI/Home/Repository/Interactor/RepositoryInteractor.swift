//
//  RepositoryInteractor.swift
//  GithubSearchAPI
//
//  Created by Amaryllis Baldrez on 09/06/25.
//

import Foundation

protocol RepositoryInteractorProtocol {
    func loadRepositories()
    func searchUser(username: String)
}

final class RepositoryInteractor: RepositoryInteractorProtocol {
    private let service: RepositoryServiceProtocol
    private let searchService: SearchServiceProtocol
    var presenter: RepositoryPresenterProtocol

    init(service: RepositoryServiceProtocol, searchService: SearchServiceProtocol, presenter: RepositoryPresenterProtocol) {
        self.service = service
        self.searchService = searchService
        self.presenter = presenter
    }

    func loadRepositories() {
        service.fetchRepositories { [weak self] result in
            self?.presenter.presentRepositories(result: result)
        }
    }

    func searchUser(username: String) {
        searchService.searchUser(username: username) { [weak self] result in
            DispatchQueue.main.async {
                self?.presenter.presentUserResult(result)
            }
        }
    }
}

