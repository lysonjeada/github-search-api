//
//  RepositoryInteractor.swift
//  GithubSearchAPI
//
//  Created by Amaryllis Baldrez on 09/06/25.
//

import Foundation

protocol RepositoryInteractorProtocol {
    func loadInitialRepositories()
    func loadMoreRepositories()
    func searchUser(username: String)
    func getRepository(owner: String, repoName: String)   // << NOVO
}

final class RepositoryInteractor: RepositoryInteractorProtocol {
    private let service: RepositoryServiceProtocol
    private let searchService: SearchServiceProtocol
    var presenter: RepositoryPresenterProtocol
    private var currentPage = 1
    private let itemsPerPage = 5
    private var isLoading = false
    private var hasMoreData = true
    
    init(service: RepositoryServiceProtocol, searchService: SearchServiceProtocol, presenter: RepositoryPresenterProtocol) {
        self.service = service
        self.searchService = searchService
        self.presenter = presenter
    }
    
    func loadInitialRepositories() {
        currentPage = 1
        service.fetchRepositories(page: currentPage, perPage: itemsPerPage) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let repositories):
                self.presenter.presentRepositories(repositories: repositories, isFirstPage: true)
            case .failure(let failure):
                self.presenter.presentError(failure.localizedDescription)
            }
        }
    }
    
    func loadMoreRepositories() {
        guard !isLoading, hasMoreData else { return }
        currentPage += 1
        service.fetchRepositories(page: currentPage, perPage: itemsPerPage) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            switch result {
            case .success(let repositories):
                if repositories.isEmpty {
                    self.hasMoreData = false
                }
                self.presenter.presentRepositories(repositories: repositories, isFirstPage: false)
            case .failure(let error):
                self.presenter.presentError(error.localizedDescription)
            }
        }
    }
    
    func searchUser(username: String) {
        searchService.searchUser(username: username) { [weak self] result in
            DispatchQueue.main.async {
                self?.presenter.presentUserResult(result)
            }
        }
    }
    
    func getRepository(owner: String, repoName: String) {
        searchService.getRepository(owner: owner, repoName: repoName) { [weak self] result in
            DispatchQueue.main.async {
                self?.presenter.presentRepositoryResult(result)
            }
        }
    }
}
