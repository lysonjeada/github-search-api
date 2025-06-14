//
//  Repository.swift
//  GithubSearchAPI
//
//  Created by Amaryllis Baldrez on 09/06/25.
//

import Foundation

struct RepositoryOwner: Decodable {
    let login: String?
    let id: Int?
    let nodeId: String?
    let avatarUrl: URL?
    let gravatarId: String?
    let url: URL?
    let htmlUrl: URL?
    let type: String?
    let siteAdmin: Bool?
    
    enum CodingKeys: String, CodingKey {
        case login, id, type, gravatarId = "gravatar_id"
        case nodeId = "node_id"
        case avatarUrl = "avatar_url"
        case url, htmlUrl = "html_url"
        case siteAdmin = "site_admin"
    }
}

struct Repository: Decodable {
    let id: Int?
    let nodeId: String?
    let name: String?
    let fullName: String?
    let isPrivate: Bool?
    let owner: RepositoryOwner
    let htmlUrl: URL
    let description: String?
    let isFork: Bool?
    let url: URL?
    let forksUrl: String?
    let languagesUrl: String?
    let stargazersUrl: String?
    let contributorsUrl: String?
    let subscribersUrl: String?
    let language: String?
    let forksCount: Int?
    let stargazersCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, name, owner, description, language, url
        case nodeId = "node_id"
        case fullName = "full_name"
        case isPrivate = "private"
        case htmlUrl = "html_url"
        case isFork = "fork"
        case forksUrl = "forks_url"
        case languagesUrl = "languages_url"
        case stargazersUrl = "stargazers_url"
        case contributorsUrl = "contributors_url"
        case subscribersUrl = "subscribers_url"
        case forksCount = "forks_count"
        case stargazersCount = "stargazers_count"
    }
}
