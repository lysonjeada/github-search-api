//
//  Repository.swift
//  GithubSearchAPI
//
//  Created by Amaryllis Baldrez on 09/06/25.
//

import Foundation

struct RepositoryOwner: Decodable {
    let login: String
    let id: Int
    let avatarURL: URL
    let htmlURL: URL
    let type: String

    enum CodingKeys: String, CodingKey {
        case login, id, type
        case avatarURL = "avatar_url"
        case htmlURL = "html_url"
    }
}

struct Repository: Decodable {
    let id: Int
    let name: String
    let fullName: String
    let description: String?
    let htmlURL: URL
    let language: String?
    let stargazersCount: Int
    let forksCount: Int
    let owner: RepositoryOwner

    enum CodingKeys: String, CodingKey {
        case id, name, description, owner, language
        case fullName = "full_name"
        case htmlURL = "html_url"
        case stargazersCount = "stargazers_count"
        case forksCount = "forks_count"
    }
}
