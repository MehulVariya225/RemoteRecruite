//
//  JobListViewModel.swift
//  RemoteRecruit
//
//  Created by Mehul Variya on 13/06/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class JobListViewModel: ObservableObject {
    @Published var jobs: [Job] = []
    @Published var filteredJobs: [Job] = []
    @Published var searchText: String = ""
    @Published var viewState: ViewState = .idle
    
    private let jobService: JobServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    enum ViewState: Equatable {
        case idle
        case loading
        case loaded
        case error(String)
        case empty
    }
    
    init(jobService: JobServiceProtocol) {
        self.jobService = jobService
        setupSearchSubscription()
    }
    
    // Default initializer using real service
    convenience init() {
        self.init(jobService: JobService())
    }
    
    // Load jobs from the service
    func fetchJobs() async {
        viewState = .loading
        
        do {
            let fetchedJobs = try await jobService.fetchJobs()
            jobs = fetchedJobs
            filterJobs()
            
            // Show empty state if no jobs came back
            if jobs.isEmpty {
                viewState = .empty
            } else {
                viewState = .loaded
            }
        } catch {
            viewState = .error(error.localizedDescription)
        }
    }
    
    // Watches search text changes with debounce to avoid excessive filtering
    private func setupSearchSubscription() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.filterJobs()
            }
            .store(in: &cancellables)
    }
    
    // Filters jobs based on search text (title or company name)
    func filterJobs() {
        guard !searchText.isEmpty else {
            filteredJobs = jobs
            updateEmptyState()
            return
        }
        
        let lowercasedSearchText = searchText.lowercased()
        filteredJobs = jobs.filter { job in
            job.title.lowercased().contains(lowercasedSearchText) ||
            job.company.lowercased().contains(lowercasedSearchText)
        }
        
        updateEmptyState()
    }
    
    // Updates the UI state based on filtered results
    private func updateEmptyState() {
        // Don't interrupt loading or error states
        switch viewState {
        case .loading, .error:
            return
        default:
            if filteredJobs.isEmpty {
                viewState = .empty
            } else if viewState != .loaded {
                viewState = .loaded
            }
        }
    }
    
    // Forces UI refresh - useful after returning from detail screen
    func refreshJobs() {
        filterJobs()
        objectWillChange.send()
    }
    
    // Marks a job as applied and updates the list
    func updateJobAppliedStatus(jobId: String) {
        if let index = jobs.firstIndex(where: { $0.id == jobId }) {
            jobs[index].isApplied = true
            filterJobs()
        }
        objectWillChange.send()
    }
}
