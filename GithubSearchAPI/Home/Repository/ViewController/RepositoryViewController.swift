//
//  RepositoryViewController.swift
//  GithubSearchAPI
//
//  Created by Amaryllis Baldrez on 09/06/25.
//

import UIKit

protocol RepositoryViewProtocol: AnyObject {
    func displayRepositories(_ newRepositories: [RepositoryViewModel], isFirstPage: Bool)
    func displayUserProfile(_ user: GithubUserViewModel)
    func displayRepository(_ repository: RepositoryViewModel)
    func displayError(_ message: String)
}

final class RepositoryViewController: UIViewController, RepositoryViewProtocol {
    private var repositories: [RepositoryViewModel] = []
    private var githubUser: GithubUserViewModel?
    private var isLoading = false
    private var currentPage = 1
    private var hasMoreData = true
    private var shouldHighlightEmptyFields = false
    private var showErrorCell = false
    var interactor: RepositoryInteractorProtocol
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ErrorCell.self, forCellReuseIdentifier: ErrorCell.reuseIdentifier)
        tableView.register(UserProfileCell.self, forCellReuseIdentifier: "UserProfileCell")
        return tableView
    }()
    
    private lazy var ownerTextField: UITextField = {
        let ownerTextField = UITextField()
        return ownerTextField
    }()
    
    private lazy var repositoryTextField: UITextField = {
        let repositoryTextField = UITextField()
        return repositoryTextField
    }()
    
    private lazy var searchButton: UIButton = {
        let searchButton = UIButton(type: .system)
        return searchButton
    }()
    
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
        interactor.loadInitialRepositories()
    }
    
    private func setupUI() {
        title = "Swift Repositories"
        view.backgroundColor = .white
        
        // Configura os textFields com estilo de busca
        configureSearchStyle(for: ownerTextField, placeholder: "Username")
        configureSearchStyle(for: repositoryTextField, placeholder: "Repository name")
        
        addClearButton(to: ownerTextField)
        addClearButton(to: repositoryTextField)
        
        // Aumentar altura dos textFields
        ownerTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        repositoryTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        // Search Button
        searchButton.setTitle("Buscar Repositório", for: .normal)
        searchButton.addTarget(self, action: #selector(searchRepository), for: .touchUpInside)
        
        let divider = UIView()
        divider.backgroundColor = UIColor.systemGray4
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [ownerTextField, repositoryTextField, searchButton, divider])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(RepositoryCell.self, forCellReuseIdentifier: "RepositoryCell")
        tableView.register(UserProfileCell.self, forCellReuseIdentifier: "UserProfileCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 250
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    
    private func configureSearchStyle(for textField: UITextField, placeholder: String) {
        textField.placeholder = placeholder
        textField.borderStyle = .none
        textField.backgroundColor = .systemGray6
        textField.layer.cornerRadius = 10
        textField.layer.masksToBounds = false
        
        // Sombra
        textField.layer.shadowColor = UIColor.black.cgColor
        textField.layer.shadowOpacity = 0.1
        textField.layer.shadowOffset = CGSize(width: 0, height: 1)
        textField.layer.shadowRadius = 4
        
        // Ícone de lupa no leftView
        let searchIcon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        searchIcon.tintColor = .gray
        searchIcon.contentMode = .scaleAspectFit
        searchIcon.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 24))
        searchIcon.center = containerView.center
        containerView.addSubview(searchIcon)
        
        textField.leftView = containerView
        textField.leftViewMode = .always
        
        textField.delegate = self
    }
    
    private func addClearButton(to textField: UITextField) {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .gray
        button.addTarget(self, action: #selector(clearTextField(_:)), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        
        textField.rightView = button
        textField.rightViewMode = .whileEditing
    }
    
    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Erro", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - RepositoryViewProtocol
    
    func displayRepositories(_ newRepositories: [RepositoryViewModel], isFirstPage: Bool) {
        repositories = isFirstPage ? newRepositories : repositories + newRepositories
        isLoading = false
        tableView.reloadData()
    }
    
    func displayUserProfile(_ user: GithubUserViewModel) {
        githubUser = user
        repositories = []
        isLoading = false
        tableView.reloadData()
    }
    
    func displayRepository(_ repository: RepositoryViewModel) {
        githubUser = nil
        repositories = [repository]
        isLoading = false
        tableView.reloadData()
    }
    
    func displayError(_ message: String) {
        isLoading = false
        repositories = []
        githubUser = nil
        showErrorCell = true
        tableView.reloadData()
    }
    
    private func checkIfFieldsAreEmpty() {
        let isOwnerEmpty = ownerTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
        let isRepoEmpty = repositoryTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
        
        if isOwnerEmpty && isRepoEmpty {
            githubUser = nil
            repositories = []
            isLoading = false
            currentPage = 1
            hasMoreData = true
            interactor.loadInitialRepositories()
            tableView.reloadData()
        }
    }
}

extension RepositoryViewController: UITextFieldDelegate {
    // ... (código existente permanece o mesmo até o método searchRepository)
    
    @objc private func searchRepository() {
        let isOwnerEmpty = ownerTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
        let isRepoEmpty = repositoryTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
        
        // Ativa o modo de highlight para campos vazios
        shouldHighlightEmptyFields = true
        
        // Atualiza a aparência dos campos
        updateTextFieldAppearance(ownerTextField, isEmpty: isOwnerEmpty)
        updateTextFieldAppearance(repositoryTextField, isEmpty: isRepoEmpty)
        
        guard !isOwnerEmpty, !isRepoEmpty else {
            return
        }
        
        // Se chegou aqui, os campos estão preenchidos
        shouldHighlightEmptyFields = false
        isLoading = true
        githubUser = nil
        repositories = []
        tableView.reloadData()
        
        interactor.getRepository(owner: ownerTextField.text!, repoName: repositoryTextField.text!)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Quando começa a editar, remove o destaque vermelho
        updateTextFieldAppearance(textField, isEmpty: false)
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        checkIfFieldsAreEmpty()
        // Só atualiza a aparência se estivermos no modo de highlight
        let isEmpty = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
        updateTextFieldAppearance(textField, isEmpty: shouldHighlightEmptyFields && isEmpty)
    }
    
    // Método para atualizar a aparência do text field
    private func updateTextFieldAppearance(_ textField: UITextField, isEmpty: Bool) {
        if isEmpty {
            textField.layer.borderWidth = 1.0
            textField.layer.borderColor = UIColor.red.cgColor
            textField.layer.cornerRadius = 10
            textField.backgroundColor = UIColor.systemRed.withAlphaComponent(0.1)
        } else {
            textField.layer.borderWidth = 0
            textField.backgroundColor = .systemGray6
        }
    }
    
    @objc private func clearTextField(_ sender: UIButton) {
        if sender == ownerTextField.rightView {
            ownerTextField.text = ""
        } else if sender == repositoryTextField.rightView {
            repositoryTextField.text = ""
        }
        checkIfFieldsAreEmpty()
        // Ao limpar o campo, não ativa o highlight
        updateTextFieldAppearance(ownerTextField, isEmpty: false)
        updateTextFieldAppearance(repositoryTextField, isEmpty: false)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension RepositoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showErrorCell && repositories.isEmpty && githubUser == nil {
            return 1 // Mostra apenas a célula de erro
        }
        
        let userOffset = githubUser != nil ? 1 : 0
        return repositories.count + userOffset
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if showErrorCell && repositories.isEmpty && githubUser == nil {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ErrorCell.reuseIdentifier, for: indexPath) as? ErrorCell else {
                return UITableViewCell()
            }
            return cell
        }
        
        if let githubUser = githubUser, indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserProfileCell", for: indexPath) as? UserProfileCell else {
                return UITableViewCell()
            }
            cell.configure(with: githubUser)
            return cell
        }
        
        let repoIndex = indexPath.row - (githubUser != nil ? 1 : 0)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RepositoryCell", for: indexPath) as? RepositoryCell else {
            return UITableViewCell()
        }
        cell.configure(with: repositories[repoIndex])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if showErrorCell && repositories.isEmpty && githubUser == nil {
            return 200 // Altura da célula de erro
        }
        return UITableView.automaticDimension
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height - 100, !isLoading, hasMoreData, !showErrorCell {
            isLoading = true
            interactor.loadMoreRepositories()
        }
    }
}
