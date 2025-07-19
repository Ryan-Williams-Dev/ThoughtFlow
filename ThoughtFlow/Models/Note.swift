//
//  Note.swift
//  ThoughtFlow
//
//  Created by Ryan Williams on 2025-07-09.
//

import Foundation
import SwiftData

@Model
class Note: Hashable {
    var id: UUID
    var text: String
    var createdAt: Date
    
    init(id: UUID = UUID(), text: String, createdAt: Date = Date()) {
        self.id = id
        self.text = text
        self.createdAt = createdAt
    }
    
    var title: String {
        let firstLine = text.components(separatedBy: .newlines).first ?? ""
        if firstLine.isEmpty {
            return "New Note"
        }
        if firstLine.count > 40 {
            let index = firstLine.index(firstLine.startIndex, offsetBy: 40)
            return String(firstLine[..<index]) + "…"
        }
        return firstLine
    }
    
    var dayString: String {
        createdAt.formatted(date: .complete, time: .omitted)
    }
    
    var dateOnly: Date {
        Calendar.current.startOfDay(for: createdAt)
    }
    
    static func == (lhs: Note, rhs: Note) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
