//
//  UserListFactory.swift
//  GithubSearchAPI
//
//  Created by Amaryllis Baldrez on 14/06/25.
//

import UIKit

enum UserListFactory {
    static func make() -> UIViewController {
        let service = UserService()
        let searchService = SearchService()
        let presenter = UserListPresenter()
        let interactor = UserListInteractor(service: service, presenter: presenter, searchService: searchService)
        let view = UserListViewController(interactor: interactor)
        presenter.viewController = view
        return view
    }
}
