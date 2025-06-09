//
//  RepositoryViewModel.swift
//  GithubSearchAPI
//
//  Created by Amaryllis Baldrez on 09/06/25.
//

import UIKit

struct RepositoryViewModel {
    let avatarURL: URL
    let repoName: String
    let ownerName: String
    let description: String
    let language: String
}

struct GithubUserViewModel {
    let avatarURL: URL
    let name: String
    let login: String
    let description: String
    let language: String
}
