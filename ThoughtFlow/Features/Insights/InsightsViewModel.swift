//
//  InsightsViewModel.swift
//  ThoughtFlow
//
//  Created by Ryan Williams on 2025-08-25.
//

import Foundation
import Combine

@MainActor
class InsightsViewModel: ObservableObject {    
    @Published var days: [Insights] = []
    @Published var selectedDay: Insights? = nil
    @Published var isGeneratingInsights = false
    @Published var generatingForDate: Date? = nil

    private let calendar = Calendar.current
    let insightsService: InsightServiceProtocol

    init(insightsService: InsightServiceProtocol) {
        self.insightsService = insightsService
        loadDaysWithTranscripts()
        // No default selection - let user choose
    }
    
    func generateInsights(for day: Insights) async {
        // Prevent duplicate generation attempts
        guard !isGeneratingInsights && day.text == nil else { return }
        
        guard let index = days.firstIndex(where: { $0.id == day.id }) else { return }
        
        // Set loading state
        isGeneratingInsights = true
        generatingForDate = day.date
        
        do {
            // Call the insights service
            let insightsText = try await insightsService.generateInsights(for: day.date)
            
            // Update the insights with the generated text
            days[index].text = insightsText
            selectedDay = days[index]
            
        } catch {
            // Handle error - you might want to show an alert or error message
            print("Error generating insights: \(error)")
            // Set a more helpful error message
            if let nsError = error as NSError? {
                days[index].text = "Error: \(nsError.localizedDescription)"
            } else {
                days[index].text = "Error generating insights. Please try again."
            }
        }
        
        // Clear loading state
        isGeneratingInsights = false
        generatingForDate = nil
    }
    
    func canGenerateInsights(for day: Insights) -> Bool {
        return day.text == nil && !isGeneratingInsights
    }
    
    func isGeneratingInsightsForDate(_ date: Date) -> Bool {
        return isGeneratingInsights && generatingForDate == date
    }
    
    func refreshDaysWithTranscripts() {
        loadDaysWithTranscripts()
    }

    private func loadDaysWithTranscripts() {
        guard let insightsService = insightsService as? InsightsService else {
            // Fallback to mock data if service is not available
            loadMockData()
            return
        }
        
        do {
            let allTranscripts = try insightsService.transcriptRepository.fetchAllTranscripts()
            
            // Group transcripts by date
            let transcriptsByDate = Dictionary(grouping: allTranscripts) { transcript in
                calendar.startOfDay(for: transcript.createdAt)
            }
            
            // Create Insights objects only for days that have transcripts
            let daysWithTranscripts = transcriptsByDate.map { (date, transcripts) in
                // Check if insights already exist for this date
                // For now, we'll assume no insights exist (text: nil)
                // In a real app, you'd check a separate insights repository
                return Insights(date: date, text: nil)
            }
            
            // Filter out current day and sort by date (most recent first)
            let today = calendar.startOfDay(for: Date())
            self.days = daysWithTranscripts
                .filter { $0.date < today } // Only previous days
                .sorted { $0.date > $1.date }
            
        } catch {
            print("Error loading transcripts: \(error)")
            // Fallback to mock data
            loadMockData()
        }
    }
    
    private func loadMockData() {
        // Helper to get a date n days ago
        func daysAgo(_ n: Int) -> Date {
            Calendar.current.date(byAdding: .day, value: -n, to: Date())!
        }
        
        let mockDays: [Insights] = [
            // Previous days only - all without insights for testing
            Insights(date: daysAgo(1), text: nil),  // yesterday - perfect for testing
            Insights(date: daysAgo(2), text: nil),
            Insights(date: daysAgo(3), text: nil),
            Insights(date: daysAgo(7), text: nil),              // start of last week
            Insights(date: daysAgo(10), text: nil),
            
            // Previous month - all without insights for testing
            Insights(date: daysAgo(15), text: nil),
            Insights(date: daysAgo(18), text: nil),
            Insights(date: daysAgo(22), text: nil),
            Insights(date: daysAgo(25), text: nil),
        ]
        
        // Filter out current day and assign to data source
        let today = calendar.startOfDay(for: Date())
        self.days = mockDays.filter { $0.date < today }
    }
}

let mockInsightText = """
    Insights for --

    Yesterday you mentioned feeling scattered between tasks, but also proud that you pushed through a workout despite being tired. A theme that came up is energy management. When you had clarity (like during your walk), you felt more positive and productive. When your mind was cluttered (scrolling before bed, stressing about work emails), your mood dipped.

    Consider these takeaways:
    - Your body boosts your mind: Even when tired, movement gave you energy instead of draining it.
    - Mental clutter creates emotional clutter: When you wrote down what was bothering you, you felt calmer. Offloading seems to be your reset button.
    - Environment matters: You felt focused at the cafe but distracted at home. Small changes in setting can have a big impact.

    Going into today, you might try repeating yesterday's win: schedule movement early, and use writing to clear your head when it gets noisy.
    """
