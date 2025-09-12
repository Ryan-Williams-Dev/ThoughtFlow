//
//  RecordButtonV2.swift
//  ThoughtFlow
//
//  Created by Ryan Williams on 2025-09-09.
//

import SwiftUI

struct RecordButtonV2: View {
    @StateObject private var vm: RecordViewModel

    init(vm: RecordViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }

    
    var body: some View {
        Group {
            if vm.isProcessing {
                ProgressView()
                    .scaleEffect(3.0)
                    .foregroundStyle(iconColor ?? .primary)
            } else {
                Image(systemName: icon)
                    .font(.system(size: 60))
                    .foregroundStyle(iconColor ?? .primary)
            }
        }
        .scaleEffect(vm.isRecording ? 1.1 : 1.0)
        .animation(
            vm.isRecording ?
                .easeInOut(duration: 0.8).repeatForever(autoreverses: true) :
                .easeInOut(duration: 0.3),
            value: vm.isRecording
        )
        .frame(width: 150, height: 150)
        .glassEffect(.regular.interactive().tint(tintColor))
        .onTapGesture {
            vm.handleTap()
        }
        .disabled(isDisabled)
        .sensoryFeedback(.success, trigger: vm.isSuccess)
        .sensoryFeedback(.start, trigger: vm.isRecording)
    }
    
    private var tintColor: Color? {
        if vm.modelLoadingError != nil { return Color.red.opacity(0.15) }
        if vm.isModelLoading { return Color.orange.opacity(0.15) }
        if !vm.isModelLoaded { return Color.orange.opacity(0.15) }
        if vm.isRecording { return Color.red.opacity(0.25) }
        if vm.isProcessing { return Color.blue.opacity(0.15) }
        if vm.isSuccess { return Color.green.opacity(0.15) }
        return nil
    }
    
    private var icon: String {
        if vm.isSuccess { return "checkmark" }
        if vm.isProcessing { return "arrow.clockwise" }
        return "mic.fill"
    }
    
    private var iconColor: Color? {
        if vm.isRecording { return .red }
        if vm.isSuccess { return .green }
        return nil
    }
    
    private var isDisabled: Bool {
        vm.isProcessing || vm.isSuccess || vm.isModelLoading || vm.modelLoadingError != nil || !vm.isModelLoaded
    }
}





// MARK: - Preview
#Preview {
    RecordButtonV2(vm: MockRecordViewModel())
}

// MARK: - Mock Services for Preview

class MockRecordingService: RecordingServiceProtocol {
    func startRecording() async throws {
        // Mock implementation - just simulate success
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second delay
    }
    
    func stopRecording() async throws -> URL {
        // Mock implementation - return a dummy URL
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second delay
        return URL(fileURLWithPath: "/tmp/mock_audio.m4a")
    }
}

class MockTranscriptionService: TranscriptionServiceProtocol {
    func transcribe(audioURL: URL) async throws -> String {
        // Mock implementation - return sample transcript
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay
        return "This is a mock transcription for preview purposes."
    }
}

class MockTranscriptRepository: TranscriptRepositoryProtocol {
    func save(transcript: Transcript) throws {
        // Mock implementation - do nothing
    }
    
    func delete(transcript: Transcript) throws {
        // Mock implementation - do nothing
    }
    
    func insert(transcript: Transcript) throws -> Transcript {
        // Mock implementation - return the same transcript
        return transcript
    }
    
    func fetchAllTranscripts() throws -> [Transcript] {
        // Mock implementation - return empty array
        return []
    }
}

class MockRecordViewModel: RecordViewModel {
    init() {
        super.init(
            recorder: MockRecordingService(),
            transcriber: MockTranscriptionService(),
            transcriptRepo: MockTranscriptRepository()
        )
        
        // Set some mock state for preview
        self.isModelLoaded = true
        self.isRecording = false
        self.isProcessing = false
        self.isSuccess = false
    }
}

