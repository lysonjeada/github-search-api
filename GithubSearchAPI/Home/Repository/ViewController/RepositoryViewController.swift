//
//  RepositoryViewController.swift
//  GithubSearchAPI
//
//  Created by Amaryllis Baldrez on 09/06/25.
//

import UIKit

protocol RepositoryViewProtocol: AnyObject {
    func displayRepositories(_ repos: [RepositoryViewModel])
    func displayUserProfile(_ user: GithubUserViewModel)
    func displayError(_ message: String)
}

final class RepositoryViewController: UIViewController, RepositoryViewProtocol {
    var interactor: RepositoryInteractorProtocol
    private var repositories: [RepositoryViewModel] = []
    private var currentQuery: String = ""
    private var isLoading = false
    private var currentPage = 1

    private var userProfile: RepositoryViewModel?
    private var githubUser: GithubUserViewModel?

    private let tableView = UITableView()
    private let searchBar = UISearchBar()

    init(interactor: RepositoryInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        interactor.loadRepositories()
    }

    private func setupUI() {
        title = "Swift Repositories"
        view.backgroundColor = .white

        // Search bar
        searchBar.delegate = self
        searchBar.placeholder = "Buscar repositórios ou usuário"
        navigationItem.titleView = searchBar

        // TableView
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(RepositoryCell.self, forCellReuseIdentifier: "RepositoryCell")
        tableView.register(UserCell.self, forCellReuseIdentifier: "UserCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    // MARK: - RepositoryViewProtocol

    func displayRepositories(_ repos: [RepositoryViewModel]) {
        githubUser = nil
        userProfile = nil
        if currentPage == 1 {
            repositories = repos
        } else {
            repositories.append(contentsOf: repos)
        }
        isLoading = false
        tableView.reloadData()
    }


    func displayUserProfile(_ user: GithubUserViewModel) {
        githubUser = user
        currentPage = 1
        repositories = []
        isLoading = false
        tableView.reloadData()
    }

    func displayError(_ message: String) {
        isLoading = false
        userProfile = nil
        repositories = []
        tableView.reloadData()

        let alert = UIAlertController(title: "Erro", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UISearchBarDelegate

extension RepositoryViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        currentQuery = searchText
        currentPage = 1
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(performSearch), object: nil)
        perform(#selector(performSearch), with: nil, afterDelay: 0.5)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        currentQuery = searchBar.text ?? ""
        currentPage = 1
//        performSearch()
    }

    @objc private func performSearch() {
        isLoading = true
        let trimmedQuery = currentQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedQuery.isEmpty {
            githubUser = nil
            userProfile = nil
            currentPage = 1
            interactor.loadRepositories()
        } else {
            interactor.searchUser(username: trimmedQuery)
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension RepositoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let userOffset = userProfile != nil ? 1 : 0
        return repositories.count + userOffset
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let user = userProfile, indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as? UserCell else {
                return UITableViewCell()
            }
            guard let githubUser else { return UITableViewCell() }
            cell.configure(with: githubUser)
            return cell
        }

        let repoIndex = indexPath.row - (userProfile != nil ? 1 : 0)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RepositoryCell", for: indexPath) as? RepositoryCell else {
            return UITableViewCell()
        }
        cell.configure(with: repositories[repoIndex])
        return cell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        if offsetY > contentHeight - height - 100, !isLoading {
            isLoading = true
            currentPage += 1
            //TODO: Colocar paginação
            interactor.loadRepositories()
        }
    }
}
