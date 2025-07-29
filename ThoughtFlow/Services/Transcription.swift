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
    private var whisperKit: WhisperKit?
    @Published var isModelLoaded = false
    
    var config = WhisperKitConfig(
        model: "medium.en"
    )
    
    init() {
        Task {
            await preloadModel()
        }
    }
    
    private func preloadModel() async {
        do {
            let whisperKit = try await WhisperKit(config)
            await MainActor.run {
                self.whisperKit = whisperKit
                self.isModelLoaded = true
            }
        } catch {
            print("Failed to preload WhisperKit model: \(error)")
        }
    }
    
    func transcribe(audioURL: URL) async throws -> String {
        let whisperKit: WhisperKit
        if let loadedWhisperKit = self.whisperKit {
            whisperKit = loadedWhisperKit
        } else {
            whisperKit = try await WhisperKit(config)
        }
        
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

