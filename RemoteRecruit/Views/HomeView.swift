//
//  HomeView.swift
//  RemoteRecruit
//
//  Created by Mehul Variya on 13/06/26.
//

import SwiftUI

struct HomeView: View {
    
    @StateObject private var viewModel = JobListViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header section with gradient title
                VStack(spacing: 8) {
                    Text("Remote Recruit")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .blue.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("Find Your Dream Remote Job")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.top, 15)
                .padding(.bottom, 10)
                
                // Search bar with callback for filtering
                SearchBar(text: $viewModel.searchText) {
                    viewModel.filterJobs()
                }
                
                // Handle different UI states
                Group {
                    switch viewModel.viewState {
                    case .idle, .loading:
                        LoadingView()
                            .onAppear {
                                Task {
                                    await viewModel.fetchJobs()
                                }
                            }
                    case .loaded:
                        if viewModel.filteredJobs.isEmpty {
                            EmptyStateView(searchText: viewModel.searchText)
                        } else {
                            jobListView
                        }
                    case .error(let message):
                        ErrorStateView(errorMessage: message) {
                            Task {
                                await viewModel.fetchJobs()
                            }
                        }
                    case .empty:
                        EmptyStateView(searchText: viewModel.searchText)
                    }
                }
            }
            .navigationBarHidden(true)
            .background(Color(.systemGray6))
            // Listen for job applications from detail screen
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("JobApplied"))) { notification in
                if let jobId = notification.userInfo?["jobId"] as? String {
                    viewModel.updateJobAppliedStatus(jobId: jobId)
                } else {
                    viewModel.refreshJobs()
                }
            }
        }
    }
    
    // Job list with pull to refresh
    private var jobListView: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(viewModel.filteredJobs) { job in
                    NavigationLink(destination: JobDetailView(job: job)) {
                        JobCard(job: job)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.vertical, 8)
        }
        .refreshable {
            await viewModel.fetchJobs()
        }
    }
}
