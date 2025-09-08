//
//  InsightsRepository.swift
//  ThoughtFlow
//
//  Created by Ryan Williams on 2025-07-28.
//

import Foundation
import SwiftData

class InsightsRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func insert(insights: Insights) throws -> Insights {
        modelContext.insert(insights)
        try modelContext.save()
        return insights
    }

    func fetchInsights(for date: Date) throws -> Insights? {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let descriptor = FetchDescriptor<Insights>(
            predicate: #Predicate { $0.date == startOfDay }
        )
        let results = try modelContext.fetch(descriptor)
        return results.first
    }
    
    func fetchAllInsights() throws -> [Insights] {
        let descriptor = FetchDescriptor<Insights>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    func deleteInsights(for date: Date) throws {
        if let insights = try fetchInsights(for: date) {
            modelContext.delete(insights)
            try modelContext.save()
        }
    }
    
}
