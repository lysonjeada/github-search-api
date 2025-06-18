//
//  SearchServiceSpy.swift
//  GithubSearchAPI
//
//  Created by Amaryllis Baldrez on 18/06/25.
//

@testable import GithubSearchAPI

final class SearchServiceSpy: SearchServiceProtocol {
    var searchUserHandler: ((String, @escaping (Result<GitHubUser, GithubSearchAPI.SearchServiceError>) -> Void) -> Void)?
    var getRepositoryHandler: ((String, String, @escaping (Result<Repository, GithubSearchAPI.SearchServiceError>) -> Void) -> Void)?
    
    func getRepository(owner: String, repoName: String, completion: @escaping (Result<Repository, GithubSearchAPI.SearchServiceError>) -> Void) {
        getRepositoryHandler?(owner, repoName, completion)
    }
    
    func searchUser(username: String, completion: @escaping (Result<GitHubUser, GithubSearchAPI.SearchServiceError>) -> Void) {
        searchUserHandler?(username, completion)
    }
}

