//
//  UserDetailViewController.swift
//  GithubSearchAPI
//
//  Created by Amaryllis Baldrez on 12/06/25.
//

import UIKit

final class UserDetailViewController: UIViewController {
    private let user: GithubUserViewModel

    init(user: GithubUserViewModel) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = user.login
        setupUI()
    }

    private func setupUI() {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let avatarImageView = UIImageView()
        avatarImageView.load(url: user.avatarURL)
        avatarImageView.layer.cornerRadius = 8
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFit
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.heightAnchor.constraint(equalToConstant: 160).isActive = true
        avatarImageView.widthAnchor.constraint(equalToConstant: 80).isActive = true

        let nameLabel = UILabel()
        nameLabel.text = "👤 \(user.name)"

        let loginLabel = UILabel()
        loginLabel.text = "🗣️ \(user.login)"

        let followersLabel = UILabel()
        followersLabel.text = "👥 Seguidores: \(user.followers ?? 0)"

        let followingLabel = UILabel()
        followingLabel.text = "➡️ Seguindo: \(user.following ?? 0)"

        let publicReposLabel = UILabel()
        publicReposLabel.text = "📦 Repositórios públicos: \(user.publicRepos ?? 0)"

        let bioLabel = UILabel()
        bioLabel.text = "📝 Bio: \(user.description ?? "")"
        bioLabel.numberOfLines = 0

        [avatarImageView, nameLabel, loginLabel, followersLabel, followingLabel, publicReposLabel, bioLabel].forEach {
            stackView.addArrangedSubview($0)
        }

        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}
