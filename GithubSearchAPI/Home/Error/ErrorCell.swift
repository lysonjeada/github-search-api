//
//  ErrorCell.swift
//  GithubSearchAPI
//
//  Created by Amaryllis Baldrez on 14/06/25.
//

import UIKit

final class ErrorCell: UITableViewCell {
    static let reuseIdentifier = "ErrorCell"
    
    private lazy var sadFaceLabel: UILabel = {
        let label = UILabel()
        label.text = "😞"
        label.font = UIFont.systemFont(ofSize: 60)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.text = "A busca não retornou resultados"
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(sadFaceLabel)
        contentView.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            sadFaceLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            sadFaceLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 40),
            
            messageLabel.topAnchor.constraint(equalTo: sadFaceLabel.bottomAnchor, constant: 20),
            messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }
}
