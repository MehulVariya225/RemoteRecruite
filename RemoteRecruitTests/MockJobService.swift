//
//  MockJobService.swift
//  RemoteRecruitTests
//
//  Created by Mehul Variya on 13/06/26.
//

import Foundation
@testable import RemoteRecruit

class MockJobService: JobServiceProtocol {
    var shouldReturnError = false
    var mockJobs: [Job] = []
    
    func fetchJobs() async throws -> [Job] {
        if shouldReturnError {
            throw JobServiceError.networkError
        }
        
        if mockJobs.isEmpty {
            // Return default mock data
            return [
                Job(
                    id: "1",
                    title: "Senior iOS Developer",
                    company: "TechCorp Solutions",
                    companyDescription: "Leading technology company specializing in mobile applications",
                    location: "San Francisco, CA (Remote)",
                    salaryMin: 120000,
                    salaryMax: 180000,
                    description: "We are looking for an experienced iOS developer",
                    requirements: "5+ years iOS development experience, Swift, SwiftUI",
                    benefits: "Health insurance, 401k matching, Home office stipend"
                ),
                Job(
                    id: "2",
                    title: "Backend Engineer",
                    company: "CloudScale Systems",
                    companyDescription: "Cloud infrastructure solutions provider",
                    location: "Austin, TX (Remote)",
                    salaryMin: 130000,
                    salaryMax: 190000,
                    description: "Join our backend team to build scalable microservices",
                    requirements: "4+ years backend experience, Node.js/Python, AWS",
                    benefits: "Remote-first culture, Stock options, Health benefits"
                ),
                Job(
                    id: "3",
                    title: "Frontend React Developer",
                    company: "WebWizards Studio",
                    companyDescription: "Creative digital agency",
                    location: "New York, NY (Remote)",
                    salaryMin: 90000,
                    salaryMax: 140000,
                    description: "Looking for a frontend developer passionate about React",
                    requirements: "3+ years React experience, TypeScript, Next.js",
                    benefits: "Work from anywhere, Education budget, Gym membership"
                )
            ]
        }
        
        return mockJobs
    }
}
