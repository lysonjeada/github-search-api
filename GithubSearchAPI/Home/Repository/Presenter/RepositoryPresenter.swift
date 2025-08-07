//
//  RepositoryPresenter.swift
//  GithubSearchAPI
//
//  Created by Amaryllis Baldrez on 09/06/25.
//

import Foundation

protocol RepositoryPresenterProtocol {
    func presentRepositories(repositories: [Repository], isFirstPage: Bool)
    func presentUserResult(_ user: GitHubUser)
    func presentRepositoryResult(_ repository: Repository)
    func presentError(_ error: String)
}

final class RepositoryPresenter: RepositoryPresenterProtocol {
    weak var view: RepositoryViewProtocol?
    
    func presentRepositories(repositories: [Repository], isFirstPage: Bool) {
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
                htmlUrl: repo.htmlUrl,
                language: repo.languages
            )
        }
        view?.displayRepositories(viewModels, isFirstPage: isFirstPage)
    }
    
    func presentUserResult(_ user: GitHubUser) {
        guard let url = URL(string: user.avatarURL ?? "") else { return }
        let userViewModel = GithubUserViewModel(
            avatarURL: url,
            name: user.name ?? "No name",
            login: user.login ?? "No login",
            description: user.bio ?? "Without biography",
            language: "",
            publicRepos: user.repos.count,
            following: user.following,
            followers: user.followers
        )
        view?.displayUserProfile(userViewModel)
        
    }
    
    func presentRepositoryResult(_ repository: Repository) {
        let repositoryViewModel = RepositoryViewModel(
            id: repository.id,
            name: repository.name,
            fullName: repository.fullName,
            description: repository.description ?? "No description",
            isPrivate: repository.isPrivate ?? false,
            stars: repository.stargazersCount,
            forks: repository.forksCount,
            ownerName: repository.owner.login,
            ownerAvatarUrl: repository.owner.avatarUrl,
            htmlUrl: repository.htmlUrl,
            language: repository.languages
        )
        view?.displayRepository(repositoryViewModel)
    }
    
    func presentError(_ error: String) {
        view?.displayError(error)
    }
}
