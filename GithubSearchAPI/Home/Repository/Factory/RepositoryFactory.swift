//
//  RepositoryFactory.swift
//  GithubSearchAPI
//
//  Created by Amaryllis Baldrez on 09/06/25.
//

import UIKit

enum RepositoryFactory {
    static func make() -> UIViewController {
        let service = RepositoryService()
        let searchService = SearchService()
        let presenter = RepositoryPresenter()
        let interactor = RepositoryInteractor(service: service, searchService: searchService, presenter: presenter)
        let view = RepositoryViewController(interactor: interactor)
        view.interactor = interactor
        interactor.presenter = presenter
        presenter.view = view
        return view
    }
}
