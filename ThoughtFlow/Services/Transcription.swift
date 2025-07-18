//
//  Transcription.swift
//  ThoughtFlow
//
//  Created by Ryan Williams on 2025-07-17.
//

import Foundation
import WhisperKit
import Combine

class TranscriptionService: ObservableObject {
    func transcribe(audioURL: URL) async throws -> String {
        // 1. Initialize WhisperKit
        let whisperKit = try await WhisperKit()
        
        // 2. Transcribe
        let results = try await whisperKit.transcribe(audioPath: audioURL.path)
        guard !results.isEmpty else {
            throw NSError(domain: "Transcription", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "No transcription result"])
        }
        
        // 3. Join segments
        let fullText = results
            .map { $0.text.trimmingCharacters(in: .whitespacesAndNewlines) }
            .joined(separator: " ")
        
        return fullText
    }
}
