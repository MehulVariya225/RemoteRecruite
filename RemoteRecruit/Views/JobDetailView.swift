//
//  JobDetailView.swift
//  RemoteRecruit
//
//  Created by Mehul Variya on 13/06/26.
//

import SwiftUI

struct JobDetailView: View {
    let job: Job
    @Environment(\.presentationMode) var presentationMode
    @State private var isApplied: Bool
    @State private var showAlert = false
    
    // Need to check if user already applied when opening
    init(job: Job) {
        self.job = job
        _isApplied = State(initialValue: job.isApplied)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                // Title and company header
                VStack(alignment: .leading, spacing: 15) {
                    Text(job.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(job.company)
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .padding(.bottom, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Two column layout for salary and location
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 15),
                    GridItem(.flexible(), spacing: 15)
                ], spacing: 15) {
                    InfoCardEqual(
                        icon: "dollarsign.circle.fill",
                        title: "Salary Range",
                        value: job.salaryRange,
                        color: .green
                    )
                    
                    InfoCardEqual(
                        icon: "location.fill",
                        title: "Location",
                        value: job.location,
                        color: .orange
                    )
                }
                
                // Full job description
                SectionCardEqual(title: "Job Description", icon: "doc.text.fill") {
                    Text(job.description)
                        .font(.body)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // List of requirements with checkmarks
                SectionCardEqual(title: "Requirements", icon: "checklist") {
                    VStack(alignment: .leading, spacing: 8) {
                        let requirementsList = job.requirements.components(separatedBy: ", ")
                        ForEach(requirementsList, id: \.self) { requirement in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                    .padding(.top, 2)
                                Text(requirement.trimmingCharacters(in: .whitespaces))
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
                
                // List of benefits with seal icons
                SectionCardEqual(title: "Benefits", icon: "star.fill") {
                    VStack(alignment: .leading, spacing: 8) {
                        let benefitsList = job.benefits.components(separatedBy: ", ")
                        ForEach(benefitsList, id: \.self) { benefit in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .padding(.top, 2)
                                Text(benefit.trimmingCharacters(in: .whitespaces))
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
                
                // Company background information
                SectionCardEqual(title: "About the Company", icon: "building.2.fill") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(job.company)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(job.companyDescription)
                            .font(.body)
                            .foregroundColor(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                
                // Apply button - changes to green after applying
                Button(action: {
                    if !isApplied {
                        AppliedJobsService.shared.applyForJob(job.id)
                        isApplied = true
                        showAlert = true
                        
                        // Let home screen know to update the badge
                        NotificationCenter.default.post(
                            name: NSNotification.Name("JobApplied"),
                            object: nil,
                            userInfo: ["jobId": job.id]
                        )
                    }
                }) {
                    HStack {
                        if isApplied {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Applied")
                                .fontWeight(.semibold)
                        } else {
                            Image(systemName: "paperplane.fill")
                            Text("Apply Now")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isApplied ? Color.green : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(isApplied)
                .padding(.top, 8)
            }
            .padding()
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Application Submitted!"),
                message: Text("You have successfully applied for \(job.title) at \(job.company). Good luck!"),
                dismissButton: .default(Text("OK"))
            )
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGray6))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    let activityVC = UIActivityViewController(
                        activityItems: ["Check out this job: \(job.title) at \(job.company)"],
                        applicationActivities: nil
                    )
                    
                    // iOS 15+ compatible way to present
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let rootVC = windowScene.windows.first?.rootViewController {
                        rootVC.present(activityVC, animated: true)
                    }
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
    }
}

// MARK: - Reusable Info Card Component
struct InfoCardEqual: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .center, spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
                .frame(height: 35)
            
            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 130) // Keeping both cards identical height
        .padding(.horizontal, 12)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Reusable Section Card Component
struct SectionCardEqual<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
