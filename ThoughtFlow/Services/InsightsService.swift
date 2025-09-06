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
    private let insightsServerURL: String
    
    init(transcriptRepository: TranscriptRepository, insightsServerURL: String = "http://192.168.1.6:3000") {
        self.transcriptRepository = transcriptRepository
        self.insightsServerURL = insightsServerURL
    }

    func generateInsights(for date: Date) async throws -> String {
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

        return try await callInsightsServer(with: joinedText)
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
    
    // MARK: - RTF Helper
    func convertRTFToAttributedString(_ rtfString: String) -> AttributedString? {
        guard let rtfData = rtfString.data(using: .utf8) else { return nil }
        
        do {
            // Convert RTF to NSAttributedString first, then to AttributedString
            let nsAttributedString = try NSAttributedString(
                data: rtfData,
                options: [.documentType: NSAttributedString.DocumentType.rtf],
                documentAttributes: nil
            )
            return AttributedString(nsAttributedString)
        } catch {
            print("Error converting RTF to AttributedString: \(error)")
            return nil
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
