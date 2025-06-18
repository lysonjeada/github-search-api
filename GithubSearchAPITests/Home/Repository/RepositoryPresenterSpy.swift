//
//  RepositoryPresenterSpy.swift
//  GithubSearchAPI
//
//  Created by Amaryllis Baldrez on 18/06/25.
//

@testable import GithubSearchAPI

final class RepositoryPresenterSpy: RepositoryPresenterProtocol {
    
    var presentRepositoriesCalled = false
    var presentedIsFirstPage: Bool?
    
    var presentUserResultCalled = false
    
    var presentRepositoryResultCalled = false
    
    func presentUserResult(_ result: Result<GithubSearchAPI.GitHubUser, GithubSearchAPI.SearchServiceError>) {
        presentUserResultCalled = true
    }
    
    func presentRepositories(result: Result<[GithubSearchAPI.Repository], GithubSearchAPI.RepositoryError>, isFirstPage: Bool) {
        presentRepositoriesCalled = true
        presentedIsFirstPage = isFirstPage
    }
    
    func presentRepositoryResult(_ result: Result<GithubSearchAPI.Repository, GithubSearchAPI.SearchServiceError>) {
        presentRepositoryResultCalled = true
    }
    
    func presentError(_ error: String) {
        
    }
}
