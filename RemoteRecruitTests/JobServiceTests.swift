//
//  JobServiceTests.swift
//  RemoteRecruitTests
//
//  Created by Mehul Variya on 13/06/26.
//

import XCTest
@testable import RemoteRecruit

@MainActor
final class JobServiceTests: XCTestCase {
    
    var sut: JobService!
    
    override func setUp() {
        super.setUp()
        sut = JobService()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // Test: Fetch jobs successfully from actual JSON
    func testFetchJobs_Success() async throws {
        // When
        let jobs = try await sut.fetchJobs()
        
        // Then
        XCTAssertNotNil(jobs)
        XCTAssertGreaterThan(jobs.count, 0)
    }
    
    // Test: First job has valid properties
    func testFetchJobs_FirstJobHasValidProperties() async throws {
        // When
        let jobs = try await sut.fetchJobs()
        let firstJob = jobs[0]
        
        // Then
        XCTAssertNotNil(firstJob.id)
        XCTAssertFalse(firstJob.id.isEmpty)
        XCTAssertNotNil(firstJob.title)
        XCTAssertFalse(firstJob.title.isEmpty)
        XCTAssertNotNil(firstJob.company)
        XCTAssertFalse(firstJob.company.isEmpty)
        XCTAssertNotNil(firstJob.location)
        XCTAssertFalse(firstJob.location.isEmpty)
        XCTAssertGreaterThan(firstJob.salaryMin, 0)
        XCTAssertGreaterThan(firstJob.salaryMax, firstJob.salaryMin)
    }
    
    // Test: Salary range formatting
    func testFetchJobs_SalaryRangeFormatting() async throws {
        // Given
        let jobs = try await sut.fetchJobs()
        let job = jobs[0]
        
        // When
        let salaryRange = job.salaryRange
        
        // Then
        XCTAssertTrue(salaryRange.contains("$"))
        XCTAssertTrue(salaryRange.contains("-"))
        XCTAssertTrue(salaryRange.contains("000"))
    }
    
    // Test: All jobs have unique IDs
    func testFetchJobs_AllJobsHaveUniqueIDs() async throws {
        // When
        let jobs = try await sut.fetchJobs()
        let ids = jobs.map { $0.id }
        let uniqueIds = Set(ids)
        
        // Then
        XCTAssertEqual(ids.count, uniqueIds.count)
    }
    
    // Test: Job salaries are reasonable
    func testFetchJobs_SalariesAreReasonable() async throws {
        // When
        let jobs = try await sut.fetchJobs()
        
        // Then
        for job in jobs {
            XCTAssertGreaterThanOrEqual(job.salaryMin, 30000)
            XCTAssertLessThanOrEqual(job.salaryMax, 500000)
            XCTAssertLessThan(job.salaryMin, job.salaryMax)
        }
    }
}

// MARK: - Mock JobService Tests
@MainActor
final class MockJobServiceTests: XCTestCase {
    
    var mockService: MockJobService!
    
    override func setUp() {
        super.setUp()
        mockService = MockJobService()
    }
    
    override func tearDown() {
        mockService = nil
        super.tearDown()
    }
    
    // Test: Mock service returns mock data
    func testMockService_ReturnsMockData() async throws {
        // When
        let jobs = try await mockService.fetchJobs()
        
        // Then
        XCTAssertEqual(jobs.count, 3)
        XCTAssertEqual(jobs[0].title, "Senior iOS Developer")
        XCTAssertEqual(jobs[1].company, "CloudScale Systems")
    }
    
    // Test: Mock service can return custom data
    func testMockService_ReturnsCustomData() async throws {
        // Given
        let customJob = Job(
            id: "999",
            title: "Custom Job",
            company: "Custom Company",
            companyDescription: "Custom Description",
            location: "Custom Location",
            salaryMin: 100000,
            salaryMax: 150000,
            description: "Custom Description",
            requirements: "Custom Requirements",
            benefits: "Custom Benefits"
        )
        mockService.mockJobs = [customJob]
        
        // When
        let jobs = try await mockService.fetchJobs()
        
        // Then
        XCTAssertEqual(jobs.count, 1)
        XCTAssertEqual(jobs[0].title, "Custom Job")
        XCTAssertEqual(jobs[0].company, "Custom Company")
    }
    
    // Test: Mock service can simulate errors
    func testMockService_SimulatesError() async {
        // Given
        mockService.shouldReturnError = true
        
        // When/Then
        do {
            _ = try await mockService.fetchJobs()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as? JobServiceError, JobServiceError.networkError)
        }
    }
}
