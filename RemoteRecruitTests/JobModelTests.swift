//
//  JobModelTests.swift
//  RemoteRecruitTests
//
//  Created by Mehul Variya on 13/06/26.
//

import XCTest
@testable import RemoteRecruit

final class JobModelTests: XCTestCase {
    
    var testJob: Job!
    
    override func setUp() {
        super.setUp()
        testJob = Job(
            id: "1",
            title: "Test iOS Developer",
            company: "Test Company",
            companyDescription: "Test Description",
            location: "Remote",
            salaryMin: 80000,
            salaryMax: 120000,
            description: "Test job description",
            requirements: "Swift, UIKit, Combine",
            benefits: "Health, Dental, 401k"
        )
    }
    
    override func tearDown() {
        testJob = nil
        super.tearDown()
    }
    
    // Test: Salary range formatting
    func testSalaryRange_Formatting() {
        // When
        let salaryRange = testJob.salaryRange
        
        // Then
        XCTAssertTrue(salaryRange.contains("$80,000") || salaryRange.contains("80000"))
        XCTAssertTrue(salaryRange.contains("$120,000") || salaryRange.contains("120000"))
        XCTAssertTrue(salaryRange.contains("-"))
    }
    
    // Test: Salary range with different values
    func testSalaryRange_DifferentValues() {
        // Given
        let lowSalaryJob = Job(
            id: "2", title: "Junior", company: "Test", companyDescription: "Test",
            location: "Remote", salaryMin: 50000, salaryMax: 70000,
            description: "Test", requirements: "Test", benefits: "Test"
        )
        
        let highSalaryJob = Job(
            id: "3", title: "Senior", company: "Test", companyDescription: "Test",
            location: "Remote", salaryMin: 150000, salaryMax: 200000,
            description: "Test", requirements: "Test", benefits: "Test"
        )
        
        // Then
        XCTAssertTrue(lowSalaryJob.salaryRange.contains("$50,000") || lowSalaryJob.salaryRange.contains("50000"))
        XCTAssertTrue(highSalaryJob.salaryRange.contains("$200,000") || highSalaryJob.salaryRange.contains("200000"))
    }
    
    // Test: Job properties are correctly set
    func testJobProperties() {
        // Then
        XCTAssertEqual(testJob.id, "1")
        XCTAssertEqual(testJob.title, "Test iOS Developer")
        XCTAssertEqual(testJob.company, "Test Company")
        XCTAssertEqual(testJob.location, "Remote")
        XCTAssertEqual(testJob.salaryMin, 80000)
        XCTAssertEqual(testJob.salaryMax, 120000)
    }
    
    // Test: Mock job creation
    func testMockJob() {
        // When
        let mockJob = Job.mock
        
        // Then
        XCTAssertNotNil(mockJob)
        XCTAssertEqual(mockJob.id, "1")
        XCTAssertEqual(mockJob.title, "Sample Job")
    }
    
    // Test: Requirements parsing
    func testRequirements_CommaSeparated() {
        // Given
        let requirements = testJob.requirements.components(separatedBy: ", ")
        
        // Then
        XCTAssertEqual(requirements.count, 3)
        XCTAssertTrue(requirements.contains("Swift"))
        XCTAssertTrue(requirements.contains("UIKit"))
        XCTAssertTrue(requirements.contains("Combine"))
    }
    
    // Test: Benefits parsing
    func testBenefits_CommaSeparated() {
        // Given
        let benefits = testJob.benefits.components(separatedBy: ", ")
        
        // Then
        XCTAssertEqual(benefits.count, 3)
        XCTAssertTrue(benefits.contains("Health"))
        XCTAssertTrue(benefits.contains("Dental"))
        XCTAssertTrue(benefits.contains("401k"))
    }
    
    // Test: isApplied property
    func testIsAppliedProperty() {
        // Then
        XCTAssertNotNil(testJob.isApplied)
        XCTAssertFalse(testJob.isApplied) // Initially false
    }
}
