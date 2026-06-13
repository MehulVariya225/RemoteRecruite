//
//  AppliedJobsServiceTests.swift
//  RemoteRecruitTests
//
//  Created by Mehul Variya on 13/06/26.
//

import XCTest
@testable import RemoteRecruit

final class AppliedJobsServiceTests: XCTestCase {
    
    var sut: AppliedJobsService!
    let testJobId = "test_job_123"
    let testJobId2 = "test_job_456"
    
    override func setUp() {
        super.setUp()
        sut = AppliedJobsService.shared
        // Clear UserDefaults before each test
        UserDefaults.standard.removeObject(forKey: "applied_jobs")
    }
    
    override func tearDown() {
        // Clean up after tests
        UserDefaults.standard.removeObject(forKey: "applied_jobs")
        super.tearDown()
    }
    
    // Test: Initially no applied jobs
    func testInitiallyNoAppliedJobs() {
        // Then
        XCTAssertFalse(sut.isJobApplied(testJobId))
        XCTAssertEqual(sut.getAppliedJobs().count, 0)
    }
    
    // Test: Apply for a job
    func testApplyForJob() {
        // When
        sut.applyForJob(testJobId)
        
        // Then
        XCTAssertTrue(sut.isJobApplied(testJobId))
        XCTAssertEqual(sut.getAppliedJobs().count, 1)
        XCTAssertEqual(sut.getAppliedJobs().first, testJobId)
    }
    
    // Test: Apply for multiple jobs
    func testApplyForMultipleJobs() {
        // When
        sut.applyForJob(testJobId)
        sut.applyForJob(testJobId2)
        
        // Then
        XCTAssertTrue(sut.isJobApplied(testJobId))
        XCTAssertTrue(sut.isJobApplied(testJobId2))
        XCTAssertEqual(sut.getAppliedJobs().count, 2)
    }
    
    // Test: Apply same job twice (should not duplicate)
    func testApplySameJobTwice() {
        // When
        sut.applyForJob(testJobId)
        sut.applyForJob(testJobId)
        
        // Then
        XCTAssertTrue(sut.isJobApplied(testJobId))
        XCTAssertEqual(sut.getAppliedJobs().count, 1)
    }
    
    // Test: Get applied jobs returns correct IDs
    func testGetAppliedJobs_ReturnsCorrectIDs() {
        // Given
        sut.applyForJob(testJobId)
        sut.applyForJob(testJobId2)
        
        // When
        let appliedJobs = sut.getAppliedJobs()
        
        // Then
        XCTAssertEqual(appliedJobs.count, 2)
        XCTAssertTrue(appliedJobs.contains(testJobId))
        XCTAssertTrue(appliedJobs.contains(testJobId2))
    }
    
    // Test: Persistence across instances
    func testPersistenceAcrossInstances() {
        // Given
        sut.applyForJob(testJobId)
        
        // When
        let newInstance = AppliedJobsService.shared
        
        // Then
        XCTAssertTrue(newInstance.isJobApplied(testJobId))
        XCTAssertEqual(newInstance.getAppliedJobs().count, 1)
    }
    
    // Test: Check non-existent job
    func testIsJobApplied_NonExistent() {
        // Then
        XCTAssertFalse(sut.isJobApplied("non_existent_id"))
    }
}
