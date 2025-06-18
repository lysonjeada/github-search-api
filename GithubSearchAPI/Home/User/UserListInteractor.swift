//
//  UserListInteractor.swift
//  GithubSearchAPI
//
//  Created by Amaryllis Baldrez on 14/06/25.
//

import Foundation

protocol UserListInteractorProtocol {
    func loadInitialUsers()
    func loadMoreUsers()
    func searchUser(username: String)
}

final class UserListInteractor: UserListInteractorProtocol {
    
    private let service: UserServiceProtocol
    private let searchService: SearchServiceProtocol
    private let presenter: UserListPresentationLogic
    private var currentPage = 1
    private let itemsPerPage = 5
    private var isLoading = false
    private var hasMoreData = true

    init(service: UserServiceProtocol, presenter: UserListPresentationLogic, searchService: SearchServiceProtocol) {
        self.service = service
        self.presenter = presenter
        self.searchService = searchService
    }
    
    func loadInitialUsers() {
        currentPage = 1
        hasMoreData = true
        loadUsers(isFirstPage: true)
    }
    
    func loadMoreUsers() {
        guard !isLoading, hasMoreData else { return }
        currentPage += 1
        loadUsers(isFirstPage: false)
    }
    
    private func loadUsers(isFirstPage: Bool) {
        isLoading = true
        service.fetchUsers(page: currentPage, perPage: itemsPerPage) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            switch result {
            case .success(let users):
                if users.isEmpty {
                    self.hasMoreData = false
                }
                self.presenter.presentUsers(users, isFirstPage: isFirstPage)
            case .failure(let error):
                self.presenter.presentError(error)
            }
        }
    }
    
    func searchUser(username: String) {
        searchService.searchUser(username: username) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    self?.presenter.presentUserResult(result)
                case .failure(let failure):
                    self?.presenter.presentError(failure)
                }
                
            }
        }
    }
}
