//
//  Insights.swift
//  ThoughtFlow
//
//  Created by Ryan Williams on 2025-08-25.
//

import Foundation

struct Insights: Identifiable, Hashable {
    let id = UUID()
    let date: Date
    var text: String?
}

// MARK: - Mock Data
extension Insights {
    static let mockDay = Insights(
        date: Date(),
        text: """
        Today was a particularly productive day. I noticed several recurring themes in my thoughts:
        
        • **Focus & Deep Work**: I had 3 solid hours of uninterrupted focus this morning. The key was turning off all notifications and using the Pomodoro technique.
        
        • **Creative Insights**: Had a breakthrough idea about the project structure while taking a walk. Physical movement seems to unlock creative thinking.
        
        • **Emotional Patterns**: Felt anxious around 2 PM when checking emails. This seems to be a recurring pattern - afternoon email checks trigger stress responses.
        
        • **Energy Levels**: Peak energy was 9-11 AM and 7-9 PM. The post-lunch dip was significant today, lasting until about 3:30 PM.
        
        **Key Takeaway**: Morning routines are crucial for setting the tone. When I start with meditation and journaling, the entire day flows better. Tomorrow I want to experiment with a 10-minute meditation instead of 5.
        
        **Action Items**:
        - Block calendar for deep work 9-11 AM
        - Take walking breaks every 90 minutes
        - Limit email checking to 11 AM and 4 PM only
        """
    )
    
    static let mockDayWithoutInsights = Insights(
        date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
        text: nil
    )
    
    static let mockDaysForPreview: [Insights] = [
        Insights(
            date: Date(),
            text: "Today's insights about productivity and focus patterns."
        ),
        Insights(
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            text: "Reflection on yesterday's creative breakthroughs."
        ),
        Insights(
            date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
            text: nil
        ),
        Insights(
            date: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(),
            text: "Weekly review of thought patterns and emotional insights."
        ),
        Insights(
            date: Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date(),
            text: "Monthly reflection on personal growth and habits."
        )
    ]
}
