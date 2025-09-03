//
//  TranscriptRepositoryProtocol.swift
//  ThoughtFlow
//
//  Created by Ryan Williams on 2025-07-19.
//

protocol TranscriptRepositoryProtocol {
    func save(transcript: Transcript) throws
    func delete(transcript: Transcript) throws
    func insert(transcript: Transcript) throws -> Transcript
    func fetchAllTranscripts() throws -> [Transcript]
}
