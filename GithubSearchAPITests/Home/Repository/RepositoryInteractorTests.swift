//
//  RepositoryInteractorTests.swift
//  GithubSearchAPI
//
//  Created by Amaryllis Baldrez on 18/06/25.
//

import XCTest
@testable import GithubSearchAPI

final class RepositoryInteractorTests: XCTestCase {
    
    private var interactor: RepositoryInteractor!
    private var serviceSpy: RepositoryServiceSpy!
    private var searchServiceSpy: SearchServiceSpy!
    private var presenterSpy: RepositoryPresenterSpy!

    override func setUp() {
        super.setUp()
        serviceSpy = RepositoryServiceSpy()
        searchServiceSpy = SearchServiceSpy()
        presenterSpy = RepositoryPresenterSpy()
        interactor = RepositoryInteractor(service: serviceSpy, searchService: searchServiceSpy, presenter: presenterSpy)
    }
    
    override func tearDown() {
        interactor = nil
        serviceSpy = nil
        searchServiceSpy = nil
        presenterSpy = nil
        super.tearDown()
    }
    
    func test_loadInitialRepositories_shouldFetchFirstPageAndPresentResult() {
        // Given
        var completionCalled = false
        serviceSpy.fetchRepositoriesHandler = { page, perPage, completion in
            XCTAssertEqual(page, 1)
            XCTAssertEqual(perPage, 5)
            completion(.success([]))
            completionCalled = true
        }
        
        // When
        interactor.loadInitialRepositories()
        
        // Then
        XCTAssertTrue(completionCalled)
        XCTAssertTrue(presenterSpy.presentRepositoriesCalled)
        XCTAssertEqual(presenterSpy.presentedIsFirstPage, true)
    }
    
    func test_loadMoreRepositories_shouldFetchNextPageAndPresentResult() {
        // Given
        interactor.loadInitialRepositories()  // currentPage = 1
        var completionCalled = false
        serviceSpy.fetchRepositoriesHandler = { page, perPage, completion in
            XCTAssertEqual(page, 2)
            XCTAssertEqual(perPage, 5)
            completion(.success([]))
            completionCalled = true
        }
        
        // When
        interactor.loadMoreRepositories()
        
        // Then
        XCTAssertTrue(completionCalled)
        XCTAssertTrue(presenterSpy.presentRepositoriesCalled)
        XCTAssertEqual(presenterSpy.presentedIsFirstPage, false)
    }
    
    func test_searchUser_shouldCallSearchServiceAndPresentUserResult() {
        // Given
        let expectation = self.expectation(description: "searchUser completion")
        searchServiceSpy.searchUserHandler = { username, completion in
            XCTAssertEqual(username, "testUser")
//            completion(.success(GithubUser(username: "testUser")))
            expectation.fulfill()
        }
        
        // When
        interactor.searchUser(username: "testUser")
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(presenterSpy.presentUserResultCalled)
    }
    
    func test_getRepository_shouldCallSearchServiceAndPresentRepositoryResult() {
        // Given
        let expectation = self.expectation(description: "getRepository completion")
        searchServiceSpy.getRepositoryHandler = { owner, repoName, completion in
            XCTAssertEqual(owner, "testOwner")
            XCTAssertEqual(repoName, "testRepo")
//            completion(.success(Repository(name: "testRepo")))
            expectation.fulfill()
        }
        
        // When
        interactor.getRepository(owner: "testOwner", repoName: "testRepo")
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(presenterSpy.presentRepositoryResultCalled)
    }
}
