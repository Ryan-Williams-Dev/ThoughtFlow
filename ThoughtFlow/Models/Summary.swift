//
//  Summary.swift
//  ThoughtFlow
//
//  Created by Ryan Williams on 2025-07-28.
//

import Foundation
import SwiftData

@Model
class Summary: Identifiable, Hashable {
    var id: UUID
    var date: Date
    var text: String
    var createdAt: Date

    init(id: UUID = UUID(), date: Date, text: String, createdAt: Date = Date())
    {
        self.id = id
        self.date = Calendar.current.startOfDay(for: date)
        self.text = text
        self.createdAt = createdAt
    }

    static func == (lhs: Summary, rhs: Summary) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
