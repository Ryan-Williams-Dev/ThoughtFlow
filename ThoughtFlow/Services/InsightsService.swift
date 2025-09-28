//
//  InsightsService.swift
//  ThoughtFlow
//
//  Created by Ryan Williams on 2025-07-28.
//

import Foundation
import UIKit

@available(iOS 15.0, *)
class InsightsService: InsightServiceProtocol {
    let transcriptRepository: TranscriptRepository
    let insightsRepository: InsightsRepository
    private let insightsServerURL: String
    
    init(transcriptRepository: TranscriptRepository, insightsRepository: InsightsRepository, insightsServerURL: String? = nil) {
        self.transcriptRepository = transcriptRepository
        self.insightsRepository = insightsRepository
        
        // Use provided URL or fall back to configuration
        if let providedURL = insightsServerURL {
            self.insightsServerURL = providedURL
        } else {
            // Read from Info.plist configuration
            self.insightsServerURL = Bundle.main.object(forInfoDictionaryKey: "INSIGHTS_API_BASE_URL") as? String ?? "https://insights-api-production-be4a.up.railway.app"
        }
    }

    func generateInsights(for date: Date) async throws -> String {
        // Check if insights already exist for this date
        if let existingInsights = try insightsRepository.fetchInsights(for: date),
           let text = existingInsights.text, !text.isEmpty {
            return text
        }
        
        let allTranscripts = try transcriptRepository.fetchAllTranscripts()

        let startOfDay = Calendar.current.startOfDay(for: date)
        guard let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) else {
            throw NSError(domain: "InsightsService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid date range"])
        }

        let transcriptsForDay = allTranscripts.filter { $0.createdAt >= startOfDay && $0.createdAt < endOfDay }

        guard !transcriptsForDay.isEmpty else {
            return "No transcripts for this day."
        }

        let texts = transcriptsForDay.map { $0.text }
        let joinedText = texts.joined(separator: "\n\n")

        let insightsText = try await callInsightsServer(with: joinedText)
        
        // Save the generated insights to the repository
        let insights = Insights(date: date, text: insightsText)
        _ = try insightsRepository.insert(insights: insights)
        
        return insightsText
    }

    private func callInsightsServer(with transcripts: String) async throws -> String {
        guard let url = URL(string: "\(insightsServerURL)/api/insights") else {
            throw NSError(domain: "InsightsService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid insights server URL: \(insightsServerURL)"])
        }

        let requestBody = InsightsRequest(transcripts: transcripts)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(requestBody)
        request.timeoutInterval = 30 // 30 second timeout

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            // Check HTTP status code
            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw NSError(domain: "InsightsService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Server error \(httpResponse.statusCode): \(errorMessage)"])
            }

                    let decoded = try JSONDecoder().decode(InsightsResponse.self, from: data)
            return decoded.insights
            
        } catch let error as NSError {
            // Provide more helpful error messages
            if error.domain == NSURLErrorDomain {
                switch error.code {
                case NSURLErrorCannotConnectToHost, NSURLErrorNotConnectedToInternet:
                    throw NSError(domain: "InsightsService", code: error.code, userInfo: [NSLocalizedDescriptionKey: "Cannot connect to insights server at \(insightsServerURL). Make sure the server is running and both devices are on the same network."])
                case NSURLErrorTimedOut:
                    throw NSError(domain: "InsightsService", code: error.code, userInfo: [NSLocalizedDescriptionKey: "Request timed out. The server may be overloaded or slow to respond."])
                default:
                    throw NSError(domain: "InsightsService", code: error.code, userInfo: [NSLocalizedDescriptionKey: "Network error: \(error.localizedDescription)"])
                }
            }
            throw error
        }
    }
}

// MARK: - Request/Response Models

struct InsightsRequest: Codable {
    let transcripts: String
}

struct InsightsResponse: Codable {
    let insights: String
}
