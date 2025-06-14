//
//  GithubUserViewModel.swift
//  GithubSearchAPI
//
//  Created by Amaryllis Baldrez on 14/06/25.
//

import UIKit

protocol UserListViewProtocol: AnyObject {
    func displayUsers(_ newUsers: [GithubUserViewModel], isFirstPage: Bool)
    func displayError(_ message: String)
    func displayUserProfile(_ user: GithubUserViewModel)
}

final class UserListViewController: UIViewController, UserListViewProtocol {
    private var users: [GithubUserViewModel] = []
    private var isLoading = false
    private var hasMoreData = true
    private var currentQuery: String = ""
    private var currentPage = 1
    private let interactor: UserListInteractorProtocol
    private var githubUser: GithubUserViewModel?
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UserProfileCell.self, forCellReuseIdentifier: "UserProfileCell")
        return tableView
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = "Buscar repositórios ou usuário"
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundImage = UIImage()
        searchBar.layer.shadowColor = UIColor.black.cgColor
        searchBar.layer.shadowOpacity = 0.1
        searchBar.layer.shadowOffset = CGSize(width: 0, height: 2)
        searchBar.layer.shadowRadius = 4
        searchBar.layer.masksToBounds = false
        let searchIcon = UIImage(systemName: "magnifyingglass")
        searchBar.setImage(searchIcon, for: .search, state: .normal)
        searchBar.showsCancelButton = false
        searchBar.showsBookmarkButton = false
        searchBar.showsSearchResultsButton = false
        searchBar.showsScopeBar = false
        searchBar.showsBookmarkButton = false
        searchBar.showsCancelButton = false
        searchBar.setShowsCancelButton(false, animated: false)
        searchBar.searchTextField.clearButtonMode = .whileEditing
        return searchBar
    }()
    
    init(interactor: UserListInteractorProtocol) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        interactor.loadInitialUsers()
    }
    
    private func setupUI() {
        navigationItem.titleView = searchBar

        title = "GitHub Users"
        view.backgroundColor = .white
        

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    
    // MARK: - UserListViewProtocol
    
    func displayUsers(_ newUsers: [GithubUserViewModel], isFirstPage: Bool) {
        if isFirstPage {
            users = newUsers
        } else {
            users.append(contentsOf: newUsers)
        }
        isLoading = false
        hasMoreData = !newUsers.isEmpty
        tableView.reloadData()
    }
    
    func displayError(_ message: String) {
        isLoading = false
        let alert = UIAlertController(title: "Erro", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func displayUserProfile(_ user: GithubUserViewModel) {
        currentPage = 1
        users = [user]
        isLoading = false
        hasMoreData = false
        tableView.reloadData()
    }

}

extension UserListViewController: UISearchBarDelegate {
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
        performSearch()
    }
    
    @objc private func performSearch() {
        isLoading = true
        let trimmedQuery = currentQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedQuery.isEmpty {
            currentPage = 1
            interactor.loadInitialUsers()
        } else {
            interactor.searchUser(username: trimmedQuery)
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension UserListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserProfileCell", for: indexPath) as? UserProfileCell else {
            return UITableViewCell()
        }
        cell.configure(with: users[indexPath.row])
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height - 100, !isLoading, hasMoreData {
            isLoading = true
            interactor.loadMoreUsers()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = users[indexPath.row]
        let detailVC = UserDetailViewController(user: selectedUser)
        navigationController?.pushViewController(detailVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
