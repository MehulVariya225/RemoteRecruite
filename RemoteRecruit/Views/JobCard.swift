//
//  JobCard.swift
//  RemoteRecruit
//
//  Created by Mehul Variya on 13/06/26.
//

import SwiftUI

struct JobCard: View {
    let job: Job
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with Title and Applied Badge
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(job.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    // Company Name
                    HStack {
                        Image(systemName: "building.2")
                            .font(.caption)
                            .foregroundColor(.blue)
                        Text(job.company)
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                }
                
                Spacer()
                
                // ADD APPLIED BADGE
                if job.isApplied {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.green)
                        .font(.title3)
                }
            }
            
            // Location
            HStack {
                Image(systemName: "location")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(job.location)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // Salary Range
            HStack {
                Image(systemName: "dollarsign.circle")
                    .font(.caption)
                    .foregroundColor(.green)
                Text(job.salaryRange)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(job.isApplied ? Color.green.opacity(0.3) : Color.clear, lineWidth: job.isApplied ? 1 : 0)
        )
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}
