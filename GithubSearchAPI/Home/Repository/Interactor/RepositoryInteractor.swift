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
    
    init(service: RepositoryServiceProtocol, searchService: SearchServiceProtocol, presenter: RepositoryPresenterProtocol) {
        self.service = service
        self.searchService = searchService
        self.presenter = presenter
    }
    
    func loadInitialRepositories() {
        currentPage = 1
        service.fetchRepositories(page: currentPage, perPage: itemsPerPage) { [weak self] result in
            self?.presenter.presentRepositories(result: result, isFirstPage: true)
        }
    }
    
    func loadMoreRepositories() {
        currentPage += 1
        service.fetchRepositories(page: currentPage, perPage: itemsPerPage) { [weak self] result in
            self?.presenter.presentRepositories(result: result, isFirstPage: false)
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
        // Chame o serviço de API que busca um repositório específico
        // Exemplo: repositoryService.fetchRepository(owner: owner, repoName: repoName) { ... }
    }

}

