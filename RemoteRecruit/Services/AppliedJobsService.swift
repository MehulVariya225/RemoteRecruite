//
//  AppliedJobsService.swift
//  RemoteRecruit
//
//  Created by Mehul Variya on 13/06/26.
//

import Foundation

//MARK: Applied Job Services
class AppliedJobsService {
    static let shared = AppliedJobsService()
    private let userDefaults = UserDefaults.standard
    private let appliedJobsKey = "applied_jobs"
    
    func applyForJob(_ jobId: String) {
        var appliedJobs = getAppliedJobs()
        if !appliedJobs.contains(jobId) {
            appliedJobs.append(jobId)
            userDefaults.set(appliedJobs, forKey: appliedJobsKey)
        }
    }
    
    func getAppliedJobs() -> [String] {
        return userDefaults.stringArray(forKey: appliedJobsKey) ?? []
    }
    
    func isJobApplied(_ jobId: String) -> Bool {
        return getAppliedJobs().contains(jobId)
    }
}
