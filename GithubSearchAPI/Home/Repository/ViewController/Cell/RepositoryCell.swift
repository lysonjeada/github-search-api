//
//  RepositoryCell.swift
//  GithubSearchAPI
//
//  Created by Amaryllis Baldrez on 09/06/25.
//

import UIKit

final class RepositoryCell: UITableViewCell {

    private lazy var avatarImageView: UIImageView = {
        let image = UIImageView()
        return image
    }()
    
    private lazy var loginLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20) // Negrito com tamanho 16
        label.textColor = .black // Cor preta (ou a cor primária do seu texto)
        label.numberOfLines = 1 // Uma linha só
        label.adjustsFontSizeToFitWidth = true // Ajusta tamanho se necessário
        return label
    }()
    
    private lazy var repositoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20) // Negrito com tamanho 16
        label.textColor = .black // Cor preta (ou a cor primária do seu texto)
        label.numberOfLines = 1 // Uma linha só
        label.adjustsFontSizeToFitWidth = true // Ajusta tamanho se necessário
        return label
    }()

    private lazy var ownerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.italicSystemFont(ofSize: 18) // Itálico com tamanho 14
        label.textColor = .gray // Cor cinza
        label.numberOfLines = 1 // Uma linha só
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var languageLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with viewModel: RepositoryViewModel) {
        repositoryLabel.text = viewModel.repoName
        ownerLabel.text = "🏛️  \(viewModel.ownerName)"
        descriptionLabel.text = "✏️ \(viewModel.description)"
        languageLabel.text = "🧠 \(viewModel.language)"
        avatarImageView.load(url: viewModel.avatarURL)
    }

    private func setupLayout() {
        [avatarImageView, repositoryLabel, languageLabel, ownerLabel, descriptionLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        avatarImageView.layer.cornerRadius = 25
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill

        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            avatarImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 50),
            avatarImageView.heightAnchor.constraint(equalToConstant: 50),

            repositoryLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            repositoryLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            repositoryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),

            languageLabel.leadingAnchor.constraint(equalTo: repositoryLabel.leadingAnchor),
            languageLabel.topAnchor.constraint(equalTo: repositoryLabel.bottomAnchor, constant: 4),

            ownerLabel.leadingAnchor.constraint(equalTo: languageLabel.trailingAnchor, constant: 8),
            ownerLabel.topAnchor.constraint(equalTo: languageLabel.topAnchor),
            ownerLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -12),

            descriptionLabel.leadingAnchor.constraint(equalTo: repositoryLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: languageLabel.bottomAnchor, constant: 8),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
}
