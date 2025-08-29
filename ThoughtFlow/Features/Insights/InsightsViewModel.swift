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

    private let calendar = Calendar.current

    init() {
        loadMockData()
    }
    
    func generateInsights(for day: Insights) {
            guard let index = days.firstIndex(where: { $0.id == day.id }) else { return }

            // Replace with your future insight generation service
            days[index].text = """
            ✨ Auto-generated insights for \(day.date.formatted(date: .abbreviated, time: .omitted))
            """
            selectedDay = days[index]
        }

    private func loadMockData() {
        // Helper to get a date n days ago
        func daysAgo(_ n: Int) -> Date {
            Calendar.current.date(byAdding: .day, value: -n, to: Date())!
        }
        
        let mockDays: [Insights] = [
            // Current month
            Insights(date: daysAgo(1), text: mockInsightText),  // yesterday
            Insights(date: daysAgo(2), text: nil),
            Insights(date: daysAgo(3), text: mockInsightText),
            Insights(date: daysAgo(7), text: nil),              // start of last week
            Insights(date: daysAgo(10), text: mockInsightText),
            
            // Previous month
            Insights(date: daysAgo(15), text: nil),
            Insights(date: daysAgo(18), text: mockInsightText),
            Insights(date: daysAgo(22), text: nil),
            Insights(date: daysAgo(25), text: mockInsightText),
        ]
        
        // Assign to your data source property
        self.days = mockDays
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
