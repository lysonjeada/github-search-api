//
//  RepositoryPresenter.swift
//  GithubSearchAPI
//
//  Created by Amaryllis Baldrez on 09/06/25.
//

import Foundation

protocol RepositoryPresenterProtocol {
    func presentRepositories(result: Result<[Repository], RepositoryError>, isFirstPage: Bool)
    func presentUserResult(_ result: Result<GitHubUser, SearchServiceError>)
    func presentRepositoryResult(_ result: Result<Repository, SearchServiceError>)
    func presentError(_ error: String)
}

final class RepositoryPresenter: RepositoryPresenterProtocol {
    weak var view: RepositoryViewProtocol?
    
    func presentRepositories(result: Result<[Repository], RepositoryError>, isFirstPage: Bool) {
        switch result {
        case .success(let repositories):
            let viewModels = repositories.map { repo in
                RepositoryViewModel(
                    id: repo.id,
                    name: repo.name,
                    fullName: repo.fullName,
                    description: repo.description ?? "No description",
                    isPrivate: repo.isPrivate ?? false,
                    stars: repo.stargazersCount,
                    forks: repo.forksCount,
                    ownerName: repo.owner.login,
                    ownerAvatarUrl: repo.owner.avatarUrl,
                    htmlUrl: repo.htmlUrl
                )
            }
            view?.displayRepositories(viewModels, isFirstPage: isFirstPage)
            
        case .failure(let error):
            view?.displayError(error.localizedDescription)
        }
    }
    
    func presentUserResult(_ result: Result<GitHubUser, SearchServiceError>) {
        switch result {
        case .success(let user):
            guard let url = URL(string: user.avatarURL ?? "") else { return }
            let userViewModel = GithubUserViewModel(
                avatarURL: url,
                name: user.name ?? "Sem nome",
                login: user.login ?? "Sem login",
                description: user.bio ?? "Sem biografia",
                language: "",
                publicRepos: user.publicRepos,
                following: user.following,
                followers: user.followers// opcional
            )
            view?.displayUserProfile(userViewModel)
        case .failure(let error):
            view?.displayError("Erro ao buscar usuário: \(error.localizedDescription)")
        }
    }
    
    func presentRepositoryResult(_ result: Result<Repository, SearchServiceError>) {
        switch result {
        case .success(let repo):
            let repositoryViewModel = RepositoryViewModel(
                id: repo.id,
                name: repo.name,
                fullName: repo.fullName,
                description: repo.description ?? "No description",
                isPrivate: repo.isPrivate ?? false,
                stars: repo.stargazersCount,
                forks: repo.forksCount,
                ownerName: repo.owner.login,
                ownerAvatarUrl: repo.owner.avatarUrl,
                htmlUrl: repo.htmlUrl
            )
            view?.displayRepository(repositoryViewModel)
        case .failure(let error):
            view?.displayError("Erro ao buscar usuário: \(error.localizedDescription)")
        }
    }
    
    func presentError(_ error: String) {
        
    }
}
