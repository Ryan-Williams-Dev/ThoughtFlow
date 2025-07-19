//
//  NoteRespository.swift
//  ThoughtFlow
//
//  Created by Ryan Williams on 2025-07-19.
//

import SwiftData
import Foundation

class NoteRepository: NoteRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func insert(note: Note) throws -> Note {
        modelContext.insert(note)
        try modelContext.save()
        return note
    }

    func save(note: Note) throws {
        try modelContext.save()
    }

    func delete(note: Note) throws {
        modelContext.delete(note)
        try modelContext.save()
    }

    func fetchAllNotes() throws -> [Note] {
        let descriptor = FetchDescriptor<Note>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
}
