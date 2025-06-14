//
//  UserListPresenter.swift
//  GithubSearchAPI
//
//  Created by Amaryllis Baldrez on 14/06/25.
//

import Foundation

protocol UserListPresentationLogic: AnyObject {
    func presentUsers(_ users: [GitHubUser], isFirstPage: Bool)
    func presentError(_ error: Error)
    func presentUserResult(_ result: Result<GitHubUser, SearchServiceError>)
}

final class UserListPresenter: UserListPresentationLogic {
    weak var viewController: UserListViewProtocol?

    func presentUsers(_ users: [GitHubUser], isFirstPage: Bool) {
        let viewModels = users.map { user in
            GithubUserViewModel(avatarURL: URL(string: user.avatarURL ?? ""),
                                name: user.login ?? "",
                                login: user.htmlURL ?? "",
                                description: user.reposURL,
                                language: nil,
                                publicRepos: nil,
                                following: nil,
                                followers: nil
            )
        }

        viewController?.displayUsers(viewModels, isFirstPage: isFirstPage)
    }

    func presentError(_ error: Error) {
        let errorMessage: String
        if let userError = error as? UserError {
            switch userError {
            case .invalidURL:
                errorMessage = "URL inválida."
            case .requestFailed(let innerError):
                errorMessage = "Erro na requisição: \(innerError.localizedDescription)"
            case .invalidResponse:
                errorMessage = "Resposta inválida do servidor."
            case .invalidData:
                errorMessage = "Dados inválidos recebidos."
            case .decodingError(let decodeError):
                errorMessage = "Erro ao decodificar os dados: \(decodeError.localizedDescription)"
            }
        } else {
            errorMessage = error.localizedDescription
        }

        viewController?.displayError(errorMessage)
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
            viewController?.displayUserProfile(userViewModel)
        case .failure(let error):
            viewController?.displayError("Erro ao buscar usuário: \(error.localizedDescription)")
        }
    }
}
