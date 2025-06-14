//
//  RepositoryViewModel.swift
//  GithubSearchAPI
//
//  Created by Amaryllis Baldrez on 09/06/25.
//

import UIKit

struct RepositoryViewModel {
    let id: Int?
    let name: String?
    let fullName: String?
    let description: String?
    let isPrivate: Bool?
    let stars: Int?
    let forks: Int?
    let ownerName: String?
    let ownerAvatarUrl: URL?
    let htmlUrl: URL?
}

struct GithubUserViewModel {
    let avatarURL: URL?
    let name: String
    let login: String
    let description: String?
    let language: String?
    let publicRepos: Int?
    let following: Int?
    let followers: Int?
}
