//
//  AppSetupManager.swift
//  ThoughtFlow
//
//  Created by Ryan Williams on 2025-01-27.
//

import Foundation
import AVFoundation
import Combine

@MainActor
class AppSetupManager: ObservableObject {
    @Published var isSetupComplete = false
    @Published var setupProgress: String = "Initializing..."
    @Published var setupError: Error?
    
    private let audioRecorder: AudioRecorder
    private let transcriptionService: TranscriptionService
    
    init(audioRecorder: AudioRecorder, transcriptionService: TranscriptionService) {
        self.audioRecorder = audioRecorder
        self.transcriptionService = transcriptionService
    }
    
    func performInitialSetup() async {
        do {
            // Step 1: Request audio permissions
            setupProgress = "Requesting microphone permissions..."
            let hasPermission = await requestAudioPermissions()
            
            guard hasPermission else {
                throw SetupError.microphonePermissionDenied
            }
            
            // Step 2: Configure audio session
            setupProgress = "Configuring audio system..."
            try configureAudioSession()
            
            // Step 3: Preload AI model
            setupProgress = "Loading AI model..."
            try await preloadAIModel()
            
            // Step 4: Setup complete
            setupProgress = "Setup complete!"
            isSetupComplete = true
            
        } catch {
            setupError = error
            setupProgress = "Setup failed: \(error.localizedDescription)"
        }
    }
    
    private func requestAudioPermissions() async -> Bool {
        return await withCheckedContinuation { continuation in
            AVAudioApplication.requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }
    
    private func configureAudioSession() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
        try audioSession.setActive(true)
    }
    
    private func preloadAIModel() async throws {
        // The TranscriptionService already handles model loading in its init
        // We just need to wait for it to complete
        print("🔄 Waiting for AI model to load...")
        
        let startTime = Date()
        let timeout: TimeInterval = 60 // 60 second timeout
        
        while !transcriptionService.isModelLoaded && transcriptionService.modelLoadingError == nil {
            // Check for timeout
            if Date().timeIntervalSince(startTime) > timeout {
                print("⏰ AI model loading timed out after \(timeout) seconds")
                throw SetupError.modelLoadingFailed
            }
            
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
        }
        
        // Check if model loading failed
        if let error = transcriptionService.modelLoadingError {
            print("❌ AI model loading failed: \(error)")
            throw SetupError.modelLoadingFailed
        }
        
        // Verify model is actually loaded
        guard transcriptionService.isModelLoaded else {
            print("❌ AI model not loaded after waiting")
            throw SetupError.modelLoadingFailed
        }
        
        let loadTime = Date().timeIntervalSince(startTime)
        print("✅ AI model loaded successfully in \(String(format: "%.1f", loadTime)) seconds")
    }
    
    func retrySetup() async {
        setupError = nil
        setupProgress = "Retrying setup..."
        await performInitialSetup()
    }
}

enum SetupError: LocalizedError {
    case microphonePermissionDenied
    case audioSessionConfigurationFailed
    case modelLoadingFailed
    
    var errorDescription: String? {
        switch self {
        case .microphonePermissionDenied:
            return "Microphone permission is required to record audio. Please enable it in Settings."
        case .audioSessionConfigurationFailed:
            return "Failed to configure audio system."
        case .modelLoadingFailed:
            return "Failed to load AI model for transcription."
        }
    }
}