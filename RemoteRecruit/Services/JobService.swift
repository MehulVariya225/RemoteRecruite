//
//  JobService.swift
//  RemoteRecruit
//
//  Created by Mehul Variya on 13/06/26.
//

import Foundation

protocol JobServiceProtocol {
    func fetchJobs() async throws -> [Job]
}

enum JobServiceError: Error {
    case invalidURL
    case fileNotFound
    case parsingError
    case networkError
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL configuration"
        case .fileNotFound:
            return "Jobs data file not found"
        case .parsingError:
            return "Error parsing job data"
        case .networkError:
            return "Network connection error"
        }
    }
}

class JobService: JobServiceProtocol {
    func fetchJobs() async throws -> [Job] {
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
        
        guard let url = Bundle.main.url(forResource: "jobs", withExtension: "json") else {
            throw JobServiceError.fileNotFound
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let response = try decoder.decode(JobResponse.self, from: data)
            return response.jobs
        } catch {
            print("Error loading jobs: \(error)")
            throw JobServiceError.parsingError
        }
    }
}
