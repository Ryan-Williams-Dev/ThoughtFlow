//
//  Transcription.swift
//  ThoughtFlow
//
//  Created by Ryan Williams on 2025-07-17.
//

import Foundation
import WhisperKit
import Combine

class TranscriptionService: ObservableObject, TranscriptionServiceProtocol {
    func transcribe(audioURL: URL) async throws -> String {
        let whisperKit = try await WhisperKit()
        
        let results = try await whisperKit.transcribe(audioPath: audioURL.path)
        guard !results.isEmpty else {
            throw NSError(domain: "Transcription", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "No transcription result"])
        }
        
        let fullText = results
            .map { $0.text.trimmingCharacters(in: .whitespacesAndNewlines) }
            .joined(separator: " ")
        
        return fullText
    }
}
