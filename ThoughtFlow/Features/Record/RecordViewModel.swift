//
//  RecordViewModel.swift
//  ThoughtFlow
//
//  Created by Ryan Williams on 2025-07-19.
//

import Combine
import Foundation
import SwiftUI

@MainActor
class RecordViewModel: ObservableObject {
    // MARK: - View State
    @Published var isRecording = false
    @Published var isLockedOn = false
    @Published var dragOffset: CGFloat = 0
    @Published var isProcessing = false
    @Published var isSuccess = false
    @Published var isModelLoaded = false

    // MARK: - Injected Services
    private let recorder: RecordingServiceProtocol
    private let transcriber: TranscriptionServiceProtocol
    private let notesRepo: NoteRepositoryProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        recorder: RecordingServiceProtocol,
        transcriber: TranscriptionServiceProtocol,
        notesRepo: NoteRepositoryProtocol
    ) {
        self.recorder = recorder
        self.transcriber = transcriber
        self.notesRepo = notesRepo

        if let transcriptionService = transcriber as? TranscriptionService {
            transcriptionService.$isModelLoaded
                .receive(on: DispatchQueue.main)
                .assign(to: \.isModelLoaded, on: self)
                .store(in: &cancellables)
        }
    }

    // MARK: - Public Intents
    func handleDragChanged(_ translation: CGFloat, lockThreshold: CGFloat) {
        dragOffset = min(max(translation, 0), lockThreshold)
        if !isRecording && !isProcessing && !isSuccess {
            triggerInitialHaptic()
            Task {
                await startRecording()
            }
        }

        if translation > lockThreshold && !isLockedOn
            && dragOffset <= lockThreshold
        {
            lockRecording()
            triggerLockHaptic()
        }

        if translation > 0 && !isLockedOn {
            dragOffset = min(translation, lockThreshold)
        }
    }

    func handleDragEnded(_ translation: CGFloat, lockThreshold: CGFloat) {
        guard isModelLoaded else { return }
        
        Task {
            if isRecording {
                if isLockedOn && translation <= lockThreshold {
                    // Tap to finish when locked (no significant drag)
                    await stopRecording()
                } else if !isLockedOn {
                    // Normal press and hold ended (not locked)
                    await stopRecording()
                }
            }
            withAnimation(.easeOut(duration: 0.3)) {
                dragOffset = 0
            }
        }
    }

    // MARK: - Recording Lifecycle
    func startRecording() async {
        do {
            try await Task.detached { [weak self] in
                guard let self = self else { return }
                try await self.recorder.startRecording()
            }.value

            // Update state on main actor
            isRecording = true
        } catch {
            print("Failed to start recording: \(error)")
        }
    }

    func stopRecording() async {
        // immediately mark not recording
        isRecording = false
        // reset lock state
        isLockedOn = false
        isProcessing = true

        do {
            let url = try await Task.detached { [weak self] in
                guard let self = self else {
                    throw NSError(
                        domain: "RecordViewModel",
                        code: -1,
                        userInfo: nil
                    )
                }
                return try await self.recorder.stopRecording()
            }.value

            let transcript = try await transcriber.transcribe(audioURL: url)
            let note = Note(text: transcript)
            _ = try notesRepo.insert(note: note)

            isProcessing = false
            isSuccess = true
            triggerSuccessHaptic()

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.isSuccess = false
            }
        } catch {
            isProcessing = false
            print("Error stopping recording: \(error)")
        }
    }

    // MARK: - Helpers
    private func lockRecording() {
        isLockedOn = true
    }

    private func triggerInitialHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }

    private func triggerLockHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }

    private func triggerSuccessHaptic() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
