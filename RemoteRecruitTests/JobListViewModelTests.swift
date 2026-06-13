//
//  JobListViewModelTests.swift
//  RemoteRecruitTests
//
//  Created by Mehul Variya on 13/06/26.
//

import XCTest
import Combine
@testable import RemoteRecruit

@MainActor
final class JobListViewModelTests: XCTestCase {
    
    var sut: JobListViewModel!
    var mockService: MockJobService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockService = MockJobService()
        sut = JobListViewModel(jobService: mockService)
        cancellables = []
    }
    
    override func tearDown() {
        sut = nil
        mockService = nil
        cancellables = nil
        super.tearDown()
    }
    
    // Test: Initial state
    func testInitialState() {
        // Then
        XCTAssertEqual(sut.viewState, .idle)
        XCTAssertTrue(sut.jobs.isEmpty)
        XCTAssertTrue(sut.filteredJobs.isEmpty)
        XCTAssertEqual(sut.searchText, "")
    }
    
    // Test: Fetch jobs success
    func testFetchJobs_Success() async {
        // When
        await sut.fetchJobs()
        
        // Then
        XCTAssertEqual(sut.viewState, .loaded)
        XCTAssertEqual(sut.jobs.count, 3)
        XCTAssertEqual(sut.filteredJobs.count, 3)
    }
    
    // Test: Loading state during fetch
    func testFetchJobs_ShowsLoadingState() async {
        // Given
        let expectation = XCTestExpectation(description: "Loading state")
        
        // When
        sut.$viewState
            .dropFirst()
            .sink { state in
                if state == .loading {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        await sut.fetchJobs()
        
        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    // Test: Filter by job title
    func testFilterJobs_ByTitle() async {
        // Given
        await sut.fetchJobs()
        
        // When
        sut.searchText = "iOS"
        sut.filterJobs()
        
        // Allow debounce time
        try? await Task.sleep(nanoseconds: 400_000_000)
        
        // Then
        XCTAssertEqual(sut.filteredJobs.count, 1)
        XCTAssertTrue(sut.filteredJobs[0].title.contains("iOS"))
    }
    
    // Test: Filter by company name
    func testFilterJobs_ByCompany() async {
        // Given
        await sut.fetchJobs()
        
        // When
        sut.searchText = "CloudScale"
        sut.filterJobs()
        
        // Allow debounce time
        try? await Task.sleep(nanoseconds: 400_000_000)
        
        // Then
        XCTAssertEqual(sut.filteredJobs.count, 1)
        XCTAssertTrue(sut.filteredJobs[0].company.contains("CloudScale"))
    }
    
    // Test: Search text change triggers filter
    func testSearchTextChange_TriggersFilter() async {
        // Given
        await sut.fetchJobs()
        let expectation = XCTestExpectation(description: "Filter triggered")
        
        sut.$filteredJobs
            .dropFirst()
            .sink { jobs in
                if jobs.count == 1 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        sut.searchText = "iOS"
        
        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    // Test: Clear search shows all jobs
    func testFilterJobs_ClearSearch() async {
        // Given
        await sut.fetchJobs()
        sut.searchText = "iOS"
        sut.filterJobs()
        try? await Task.sleep(nanoseconds: 400_000_000)
        
        // When
        sut.searchText = ""
        sut.filterJobs()
        try? await Task.sleep(nanoseconds: 400_000_000)
        
        // Then
        XCTAssertEqual(sut.filteredJobs.count, 3)
    }
    
    // Test: Filter with no results shows empty state
    func testFilterJobs_NoResults() async {
        // Given
        await sut.fetchJobs()
        
        // When
        sut.searchText = "NonExistentJobThatDoesNotExist"
        sut.filterJobs()
        try? await Task.sleep(nanoseconds: 400_000_000)
        
        // Then
        XCTAssertEqual(sut.filteredJobs.count, 0)
        XCTAssertEqual(sut.viewState, .empty)
    }
    
    // Test: Case insensitive search
    func testFilterJobs_CaseInsensitive() async {
        // Given
        await sut.fetchJobs()
        
        // When
        sut.searchText = "ios"
        sut.filterJobs()
        try? await Task.sleep(nanoseconds: 400_000_000)
        
        // Then
        XCTAssertEqual(sut.filteredJobs.count, 1)
    }
    
    // Test: Partial word search
    func testFilterJobs_PartialWordSearch() async {
        // Given
        await sut.fetchJobs()
        
        // When
        sut.searchText = "React"
        sut.filterJobs()
        try? await Task.sleep(nanoseconds: 400_000_000)
        
        // Then
        XCTAssertEqual(sut.filteredJobs.count, 1)
        XCTAssertTrue(sut.filteredJobs[0].title.contains("React"))
    }
    
    // Test: Refresh jobs maintains filter
    func testRefreshJobs_MaintainsFilter() async {
        // Given
        await sut.fetchJobs()
        sut.searchText = "iOS"
        sut.filterJobs()
        try? await Task.sleep(nanoseconds: 400_000_000)
        let filteredCount = sut.filteredJobs.count
        
        // When
        sut.refreshJobs()
        
        // Then
        XCTAssertEqual(sut.filteredJobs.count, filteredCount)
    }
    
    // Test: Update job applied status
    func testUpdateJobAppliedStatus() async {
        // Given
        await sut.fetchJobs()
        let jobId = sut.jobs[0].id
        XCTAssertFalse(sut.jobs[0].isApplied)
        
        // When
        sut.updateJobAppliedStatus(jobId: jobId)
        
        // Then
        XCTAssertTrue(sut.jobs[0].isApplied)
        XCTAssertTrue(sut.filteredJobs[0].isApplied)
    }
    
    // Test: Update multiple jobs applied status
    func testUpdateMultipleJobAppliedStatus() async {
        // Given
        await sut.fetchJobs()
        let firstJobId = sut.jobs[0].id
        let secondJobId = sut.jobs[1].id
        
        // When
        sut.updateJobAppliedStatus(jobId: firstJobId)
        sut.updateJobAppliedStatus(jobId: secondJobId)
        
        // Then
        XCTAssertTrue(sut.jobs[0].isApplied)
        XCTAssertTrue(sut.jobs[1].isApplied)
    }
    
    // Test: Update non-existent job doesn't crash
    func testUpdateJobAppliedStatus_NonExistentJob() async {
        // Given
        await sut.fetchJobs()
        let nonExistentId = "999"
        
        // When
        sut.updateJobAppliedStatus(jobId: nonExistentId)
        
        // Then
        XCTAssertEqual(sut.jobs.count, 3)
    }
    
    // Test: Handle fetch error
    func testFetchJobs_HandlesError() async {
        // Given
        mockService.shouldReturnError = true
        
        // When
        await sut.fetchJobs()
        
        // Then
        if case .error(let message) = sut.viewState {
            XCTAssertEqual(message, JobServiceError.networkError.localizedDescription)
        } else {
            XCTFail("Expected error state")
        }
    }
    
    // Test: Empty state when no jobs
    func testEmptyState_WhenNoJobs() async {
        // Given
        mockService.mockJobs = []
        
        // When
        await sut.fetchJobs()
        
        // Then
        XCTAssertEqual(sut.viewState, .empty)
        XCTAssertTrue(sut.jobs.isEmpty)
    }
    
    // Test: Filter maintains during error
    func testFilterDuringError() async {
        // Given
        await sut.fetchJobs()
        sut.searchText = "iOS"
        sut.filterJobs()
        try? await Task.sleep(nanoseconds: 400_000_000)
        
        // When
        mockService.shouldReturnError = true
        await sut.fetchJobs()
        
        // Then
        XCTAssertEqual(sut.filteredJobs.count, 0)
    }
}
