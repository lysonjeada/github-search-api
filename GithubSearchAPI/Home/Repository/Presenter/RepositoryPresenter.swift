//
//  RepositoryPresenter.swift
//  GithubSearchAPI
//
//  Created by Amaryllis Baldrez on 09/06/25.
//

import Foundation

protocol RepositoryPresenterProtocol {
    func presentRepositories(result: Result<[Repository], RepositoryError>)
    func presentUserResult(_ result: Result<GitHubUser, SearchServiceError>)
}

final class RepositoryPresenter: RepositoryPresenterProtocol {
    weak var view: RepositoryViewProtocol?

    func presentRepositories(result: Result<[Repository], RepositoryError>) {
        switch result {
        case .success(let repos):
            let viewModels = repos.map {
                RepositoryViewModel(
                    avatarURL: $0.owner.avatarURL,
                    repoName: $0.name,
                    ownerName: $0.owner.login,
                    description: $0.description ?? "Sem descrição",
                    language: $0.language ?? "Sem linguagem"
                )
            }
            view?.displayRepositories(viewModels)
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
                language: "" // opcional
            )
            view?.displayUserProfile(userViewModel)
        case .failure(let error):
            view?.displayError("Erro ao buscar usuário: \(error.localizedDescription)")
        }
    }

}
