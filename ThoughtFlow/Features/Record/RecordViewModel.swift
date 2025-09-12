//
//  RecordViewModel.swift
//  ThoughtFlow
//
//  Created by Ryan Williams on 2025-07-19.
//

import Combine
import Foundation
import SwiftUI

/// ViewModel responsible for managing the recording interface and audio capture workflow.
/// Handles drag gestures, recording lifecycle, transcription, and user feedback.
@MainActor
class RecordViewModel: ObservableObject {
    // MARK: - View State
    /// Whether audio recording is currently active
    @Published var isRecording = false
    /// Whether transcription is in progress
    @Published var isProcessing = false
    /// Whether the last recording was successful
    @Published var isSuccess = false
    /// Whether the transcription model is loaded and ready
    @Published var isModelLoaded = false
    /// Whether the transcription model is currently loading
    @Published var isModelLoading = false
    /// Any error that occurred during model loading
    @Published var modelLoadingError: Error?

    // MARK: - Injected Services
    private let recorder: RecordingServiceProtocol
    private let transcriber: TranscriptionServiceProtocol
    private let transcriptRepo: TranscriptRepositoryProtocol
    
    /// Combine cancellables for managing subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    /// Initialize the RecordViewModel with required services
    /// - Parameters:
    ///   - recorder: Service for audio recording functionality
    ///   - transcriber: Service for converting audio to text
    ///   - transcriptRepo: Repository for persisting transcript data
    init(
        recorder: RecordingServiceProtocol,
        transcriber: TranscriptionServiceProtocol,
        transcriptRepo: TranscriptRepositoryProtocol
    ) {
        self.recorder = recorder
        self.transcriber = transcriber
        self.transcriptRepo = transcriptRepo

        // Subscribe to transcription service state changes if it's the concrete implementation
        if let transcriptionService = transcriber as? TranscriptionService {
            transcriptionService.$isModelLoaded
                .receive(on: DispatchQueue.main)
                .assign(to: \.isModelLoaded, on: self)
                .store(in: &cancellables)
            
            transcriptionService.$isModelLoading
                .receive(on: DispatchQueue.main)
                .assign(to: \.isModelLoading, on: self)
                .store(in: &cancellables)
            
            transcriptionService.$modelLoadingError
                .receive(on: DispatchQueue.main)
                .assign(to: \.modelLoadingError, on: self)
                .store(in: &cancellables)
        }
    }

    // MARK: - Public Intents
    
    /// Handle tap gesture - toggle recording on/off
    func handleTap() {
        // If model failed to load, allow tap to retry
        if modelLoadingError != nil {
            Task {
                await retryModelLoading()
            }
            return
        }
        
        guard isModelLoaded else {
            print("⚠️ Model not loaded, ignoring tap")
            return
        }
        
        Task {
            if isRecording {
                // Stop recording
                await stopRecording()
            } else {
                // Start recording
                await startRecording()
            }
        }
    }

    // MARK: - Recording Lifecycle
    
    /// Start audio recording if conditions are met
    func startRecording() async {
        // Prevent multiple simultaneous recording attempts
        guard !isRecording && !isProcessing else {
            print("⚠️ Recording already in progress, ignoring start request")
            return
        }
        
        do {
            // Start recording directly (it's already async and handles permissions)
            try await recorder.startRecording()

            // Update state on main actor
            await MainActor.run {
                self.isRecording = true
            }
        } catch {
            print("Failed to start recording: \(error)")
            await MainActor.run {
                self.isRecording = false
            }
        }
    }

    /// Stop audio recording and process the captured audio
    func stopRecording() async {
        // Immediately mark not recording
        isRecording = false
        isProcessing = true

        do {
            // Stop recording and get audio file URL
            let url = try await recorder.stopRecording()

            // Transcribe the audio
            let transcript = try await transcriber.transcribe(audioURL: url)
            let transcriptModel = Transcript(text: transcript)
            _ = try transcriptRepo.insert(transcript: transcriptModel)

            // Update UI state on main thread
            await MainActor.run {
                self.isProcessing = false
                self.isSuccess = true
            }

            // Auto-hide success state after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.isSuccess = false
            }
        } catch {
            // Handle errors gracefully
            await MainActor.run {
                self.isProcessing = false
            }
            
            print("Error stopping recording: \(error)")
            // Note: Audio file cleanup is handled by TranscriptionService.transcribe()
        }
    }

    // MARK: - Helpers
    
    // MARK: - Model Loading
    
    /// Retry loading the transcription model after a failure
    private func retryModelLoading() async {
        if let transcriptionService = transcriber as? TranscriptionService {
            await transcriptionService.retryModelLoading()
        }
    }
}
