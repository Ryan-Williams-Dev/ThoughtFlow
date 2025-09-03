//
//  TranscriptRepository.swift
//  ThoughtFlow
//
//  Created by Ryan Williams on 2025-07-19.
//

import SwiftData
import Foundation

class TranscriptRepository: TranscriptRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func insert(transcript: Transcript) throws -> Transcript {
        modelContext.insert(transcript)
        try modelContext.save()
        return transcript
    }

    func save(transcript: Transcript) throws {
        try modelContext.save()
    }

    func delete(transcript: Transcript) throws {
        modelContext.delete(transcript)
        try modelContext.save()
    }

    func fetchAllTranscripts() throws -> [Transcript] {
        let descriptor = FetchDescriptor<Transcript>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
}
