//
//  RepositoryCell.swift
//  GithubSearchAPI
//
//  Created by Amaryllis Baldrez on 09/06/25.
//

import UIKit

final class RepositoryCell: UITableViewCell {

    private let avatarImageView = UIImageView()
    private let titleLabel = UILabel()
    private let ownerLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let languageLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with viewModel: RepositoryViewModel) {
        titleLabel.text = viewModel.repoName
        ownerLabel.text = "👤 \(viewModel.ownerName)"
        descriptionLabel.text = viewModel.description
        languageLabel.text = "🧠 \(viewModel.language)"

        avatarImageView.load(url: viewModel.avatarURL)
    }

    private func setupLayout() {
        [avatarImageView, titleLabel, ownerLabel, descriptionLabel, languageLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        avatarImageView.layer.cornerRadius = 25
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill

        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            avatarImageView.widthAnchor.constraint(equalToConstant: 50),
            avatarImageView.heightAnchor.constraint(equalToConstant: 50),

            titleLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),

            ownerLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            ownerLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),

            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: ownerLabel.bottomAnchor, constant: 4),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            languageLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            languageLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 4),
            languageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
}
