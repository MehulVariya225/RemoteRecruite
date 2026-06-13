//
//  CollapsibleHomeView.swift
//  RemoteRecruit
//
//  Created by Mehul Variya on 13/06/26.
//

import SwiftUI

struct CollapsibleHomeView: View {
    @StateObject private var viewModel = JobListViewModel()
    @State private var headerHeight: CGFloat = 140
    @State private var lastScrollOffset: CGFloat = 0
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack(alignment: .top) {
                    // Scrollable Content
                    ScrollViewWithOffset(onScroll: { offset in
                        handleScroll(offset, geometry: geometry)
                    }) {
                        VStack(spacing: 12) {
                            Spacer()
                                .frame(height: headerHeight + 20)
                            
                            if viewModel.filteredJobs.isEmpty {
                                EmptyStateView(searchText: viewModel.searchText)
                                    .padding(.top, 50)
                            } else {
                                ForEach(viewModel.filteredJobs) { job in
                                    NavigationLink(destination: JobDetailView(job: job)) {
                                        JobCard(job: job)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // Sticky Header
                    VStack(spacing: 0) {
                        VStack(spacing: 8) {
                            Text("RemoteRecruit")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                                .opacity(Double((headerHeight - 60) / 80))
                                .scaleEffect(max(0.7, min(1.0, (headerHeight - 40) / 100)))
                            
                            if headerHeight > 80 {
                                Text("Find Your Dream Remote Job")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .transition(.opacity)
                            }
                        }
                        .frame(height: max(60, headerHeight))
                        .padding(.top, 50)
                        
                        EnhancedSearchBar(searchText: $viewModel.searchText,
                                        placeholder: "Search by job title or company...") {
                            viewModel.filterJobs()
                        }
                        .padding(.bottom, 12)
                        .background(
                            Rectangle()
                                .fill(.ultraThinMaterial)
                                .shadow(color: Color.black.opacity(0.05), radius: 5, y: 1)
                        )
                    }
                    .frame(height: headerHeight + 70)
                }
            }
            .navigationBarHidden(true)
        }
        .task {
            await viewModel.fetchJobs()
        }
    }
    
    private func handleScroll(_ offset: CGFloat, geometry: GeometryProxy) {
        let delta = offset - lastScrollOffset
        let newHeight = headerHeight - delta
        
        if delta < 0 && headerHeight > 60 {
            // Scrolling up - decrease header
            headerHeight = max(60, newHeight)
        } else if delta > 0 && headerHeight < 140 {
            // Scrolling down - increase header
            headerHeight = min(140, newHeight)
        }
        
        lastScrollOffset = offset
    }
}

// Custom ScrollView with offset tracking
struct ScrollViewWithOffset<Content: View>: View {
    let onScroll: (CGFloat) -> Void
    let content: Content
    
    init(onScroll: @escaping (CGFloat) -> Void, @ViewBuilder content: () -> Content) {
        self.onScroll = onScroll
        self.content = content()
    }
    
    var body: some View {
        ScrollView {
            GeometryReader { geometry in
                Color.clear
                    .preference(key: ScrollViewOffsetPreferenceKey.self,
                               value: geometry.frame(in: .named("scroll")).minY)
            }
            .frame(height: 0)
            
            content
        }
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { value in
            onScroll(value)
        }
    }
}

struct ScrollViewOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
