//
//  MainTabBarController.swift
//  GithubSearchAPI
//
//  Created by Amaryllis Baldrez on 14/06/25.
//

import UIKit

final class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarAppearance()

        let repositoryVC = RepositoryFactory.make()
        let userVC = UserListFactory.make()
        
        repositoryVC.tabBarItem = UITabBarItem(title: "Repositories", image: UIImage(systemName: "folder"), tag: 0)
        userVC.tabBarItem = UITabBarItem(title: "Users", image: UIImage(systemName: "person.2"), tag: 1)
        
        viewControllers = [
            UINavigationController(rootViewController: repositoryVC),
            UINavigationController(rootViewController: userVC)
        ]
    }
    
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemGray6  // <- Aqui define o cinza claro

        tabBar.standardAppearance = appearance
        
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }
}

