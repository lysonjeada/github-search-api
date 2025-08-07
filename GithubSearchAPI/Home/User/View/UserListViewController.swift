//
//  GithubUserViewModel.swift
//  GithubSearchAPI
//
//  Created by Amaryllis Baldrez on 14/06/25.
//

import UIKit

protocol UserListViewProtocol: AnyObject {
    func displayUsers(_ newUsers: [GithubUserViewModel], isFirstPage: Bool)
    func displayError()
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
    private var showErrorCell = false
    private var isCollectionViewMode = false

    // MARK: - UI Components

    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = "Search users"
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundImage = UIImage()
        searchBar.layer.shadowColor = UIColor.black.cgColor
        searchBar.layer.shadowOpacity = 0.1
        searchBar.layer.shadowOffset = CGSize(width: 0, height: 2)
        searchBar.layer.shadowRadius = 4
        searchBar.layer.masksToBounds = false
        searchBar.setImage(imageSearchBar, for: .search, state: .normal)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()

    private lazy var switchContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var switchLabel: UILabel = {
        let label = UILabel()
        label.text = "Change to collection view"
        label.textColor = .label
        label.font = .systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var switchButton: UISwitch = {
        let switchButton = UISwitch()
        switchButton.onTintColor = .systemGreen
        switchButton.translatesAutoresizingMaskIntoConstraints = false
        switchButton.addTarget(self, action: #selector(toggleViewMode), for: .valueChanged)
        return switchButton
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UserProfileCell.self, forCellReuseIdentifier: "UserProfileCell")
        tableView.register(ErrorCell.self, forCellReuseIdentifier: ErrorCell.reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UserProfileCollectionViewCell.self, forCellWithReuseIdentifier: UserProfileCollectionViewCell.reuseIdentifier)
        collectionView.register(ErrorCollectionViewCell.self, forCellWithReuseIdentifier: ErrorCollectionViewCell.reuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isHidden = true
        return collectionView
    }()

    private lazy var imageSearchBar: UIImage = {
        let image = UIImage(systemName: "magnifyingglass")
        return image ?? UIImage()
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
        title = "GitHub Users"
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.label
        ]
        view.backgroundColor = .systemBackground
        
        view.addSubview(searchBar)
        view.addSubview(switchContainer)
        view.addSubview(tableView)
        view.addSubview(collectionView)
        
        switchContainer.addSubview(switchLabel)
        switchContainer.addSubview(switchButton)

        NSLayoutConstraint.activate([
            // searchBar
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            
            // switchContainer
            switchContainer.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            switchContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            switchContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            switchContainer.heightAnchor.constraint(equalToConstant: 40),
            
            // switchLabel
            switchLabel.leadingAnchor.constraint(equalTo: switchContainer.leadingAnchor),
            switchLabel.centerYAnchor.constraint(equalTo: switchContainer.centerYAnchor),
            
            // switchButton
            switchButton.trailingAnchor.constraint(equalTo: switchContainer.trailingAnchor),
            switchButton.centerYAnchor.constraint(equalTo: switchContainer.centerYAnchor),

            // tableView
            tableView.topAnchor.constraint(equalTo: switchContainer.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // collectionView
            collectionView.topAnchor.constraint(equalTo: switchContainer.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -240),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    @objc private func toggleViewMode() {
        isCollectionViewMode.toggle()
        if isCollectionViewMode {
            tableView.isHidden = true
            collectionView.isHidden = false
            collectionView.reloadData()
        } else {
            tableView.isHidden = false
            collectionView.isHidden = true
            tableView.reloadData()
        }
    }

    // MARK: - UserListViewProtocol

    func displayUsers(_ newUsers: [GithubUserViewModel], isFirstPage: Bool) {
        showErrorCell = false
        if isFirstPage {
            users = newUsers
        } else {
            users.append(contentsOf: newUsers)
        }
        isLoading = false
        hasMoreData = !newUsers.isEmpty
        if isCollectionViewMode {
            collectionView.reloadData()
        } else {
            tableView.reloadData()
        }
    }

    func displayUserProfile(_ user: GithubUserViewModel) {
        showErrorCell = false
        currentPage = 1
        users = [user]
        isLoading = false
        hasMoreData = false
        if isCollectionViewMode {
            collectionView.reloadData()
        } else {
            tableView.reloadData()
        }
    }

    func displayError() {
        isLoading = false
        users = []
        showErrorCell = true
        if isCollectionViewMode {
            collectionView.reloadData()
        } else {
            tableView.reloadData()
        }
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
        if showErrorCell && users.isEmpty {
            return 1
        }
        return users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if showErrorCell && users.isEmpty {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ErrorCell.reuseIdentifier, for: indexPath) as? ErrorCell else {
                return UITableViewCell()
            }
            return cell
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserProfileCell", for: indexPath) as? UserProfileCell else {
            return UITableViewCell()
        }
        cell.configure(with: users[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !showErrorCell {
            let selectedUser = users[indexPath.row]
            let detailVC = UserDetailViewController(user: selectedUser)
            navigationController?.pushViewController(detailVC, animated: true)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if showErrorCell && users.isEmpty {
            return 200
        }
        return UITableView.automaticDimension
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout

extension UserListViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if showErrorCell && users.isEmpty {
            return 1
        }
        return users.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if showErrorCell && users.isEmpty {
             guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ErrorCollectionViewCell.reuseIdentifier, for: indexPath) as? ErrorCollectionViewCell else {
                return UICollectionViewCell()
             }
            return cell
        }
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserProfileCollectionViewCell.reuseIdentifier, for: indexPath) as? UserProfileCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: users[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.bounds.height / 2
        let width = (collectionView.bounds.width - 30) / 2
        return CGSize(width: 200, height: 200)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !showErrorCell {
            let selectedUser = users[indexPath.item]
            let detailVC = UserDetailViewController(user: selectedUser)
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == collectionView {
            let offsetX = scrollView.contentOffset.x
            let contentWidth = scrollView.contentSize.width
            let width = scrollView.frame.size.width

            if offsetX > contentWidth - width - 100, !isLoading, hasMoreData, isCollectionViewMode {
                isLoading = true
                interactor.loadMoreUsers()
            }
        } else {
            let offsetY = scrollView.contentOffset.y
            let contentHeight = scrollView.contentSize.height
            let height = scrollView.frame.size.height

            if offsetY > contentHeight - height - 100, !isLoading, hasMoreData, !isCollectionViewMode {
                isLoading = true
                interactor.loadMoreUsers()
            }
        }
    }
}
