//
//  Job.swift
//  RemoteRecruit
//
//  Created by Mehul Variya on 13/06/26.
//

import Foundation

struct JobResponse: Codable {
    let jobs: [Job]
}

// MARK: - Job Model
struct Job: Identifiable, Codable {
    let id: String
    let title: String
    let company: String
    let companyDescription: String
    let location: String
    let salaryMin: Int
    let salaryMax: Int
    let description: String
    let requirements: String
    let benefits: String
    
    // Tracks if user already applied to this job
    var isApplied: Bool = false
    
    // Formats salary range with currency symbol and no decimal places
    var salaryRange: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        
        let minFormatted = formatter.string(from: NSNumber(value: salaryMin)) ?? "$\(salaryMin)"
        let maxFormatted = formatter.string(from: NSNumber(value: salaryMax)) ?? "$\(salaryMax)"
        
        return "\(minFormatted) - \(maxFormatted)"
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, company, companyDescription, location, salaryMin, salaryMax, description, requirements, benefits
    }
    
    // Custom decoder needed to check if job was previously applied
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        company = try container.decode(String.self, forKey: .company)
        companyDescription = try container.decode(String.self, forKey: .companyDescription)
        location = try container.decode(String.self, forKey: .location)
        salaryMin = try container.decode(Int.self, forKey: .salaryMin)
        salaryMax = try container.decode(Int.self, forKey: .salaryMax)
        description = try container.decode(String.self, forKey: .description)
        requirements = try container.decode(String.self, forKey: .requirements)
        benefits = try container.decode(String.self, forKey: .benefits)
        
        // Check UserDefaults to see if user already applied
        isApplied = AppliedJobsService.shared.isJobApplied(id)
    }
    
    // Encode job data back to JSON if needed
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(company, forKey: .company)
        try container.encode(companyDescription, forKey: .companyDescription)
        try container.encode(location, forKey: .location)
        try container.encode(salaryMin, forKey: .salaryMin)
        try container.encode(salaryMax, forKey: .salaryMax)
        try container.encode(description, forKey: .description)
        try container.encode(requirements, forKey: .requirements)
        try container.encode(benefits, forKey: .benefits)
    }
    
    // Regular initializer used for mock data and previews
    init(id: String, title: String, company: String, companyDescription: String, location: String, salaryMin: Int, salaryMax: Int, description: String, requirements: String, benefits: String) {
        self.id = id
        self.title = title
        self.company = company
        self.companyDescription = companyDescription
        self.location = location
        self.salaryMin = salaryMin
        self.salaryMax = salaryMax
        self.description = description
        self.requirements = requirements
        self.benefits = benefits
        // Need to check UserDefaults for existing applications
        self.isApplied = AppliedJobsService.shared.isJobApplied(id)
    }
}

// MARK: - Mock Data for Previews
extension Job {
    static var mock: Job {
        Job(
            id: "1",
            title: "Sample Job",
            company: "Sample Company",
            companyDescription: "This is a sample company description",
            location: "Remote",
            salaryMin: 50000,
            salaryMax: 100000,
            description: "Sample job description",
            requirements: "Sample requirements",
            benefits: "Sample benefits"
        )
    }
}
