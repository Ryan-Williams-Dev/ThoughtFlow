//
//  SummaryRepository.swift
//  ThoughtFlow
//
//  Created by Ryan Williams on 2025-07-28.
//

import Foundation
import SwiftData

class SummaryRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func insert(summary: Summary) throws -> Summary {
        modelContext.insert(summary)
        try modelContext.save()
        return summary
    }

    func fetchSummary(for date: Date) throws -> Summary? {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let descriptor = FetchDescriptor<Summary>(
            predicate: #Predicate { $0.date == startOfDay }
        )
        let results = try modelContext.fetch(descriptor)
        return results.first
    }
}
