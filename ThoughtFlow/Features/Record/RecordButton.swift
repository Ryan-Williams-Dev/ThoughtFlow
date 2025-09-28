//
//  RecordButton.swift
//  ThoughtFlow
//
//  Created by Ryan Williams on 2025-07-19.
//

import SwiftUI
import SwiftData

struct RecordButton: View {
    @StateObject private var vm: RecordViewModel

    init(vm: RecordViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }

    var body: some View {
        buttonContent
            .onTapGesture {
                vm.handleTap()
            }
            .disabled(vm.isModelLoading && vm.modelLoadingError == nil)
            .frame(maxHeight: .infinity)
            .background(backgroundColor)
    }

    @ViewBuilder
    private var buttonContent: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(circleColor)
                .frame(width: 12, height: 12)
                .scaleEffect(vm.isRecording ? 1.3 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: vm.isRecording)
            
            Text(buttonText)
                .font(.system(size: 16, weight: .medium))
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }


    private var circleColor: Color {
        if vm.modelLoadingError != nil { return .red }
        if vm.isModelLoading { return .orange }
        if !vm.isModelLoaded { return .orange }
        if vm.isRecording { return .recording }
        if vm.isProcessing { return .processing }
        if vm.isSuccess { return .success }
        return .primary.opacity(0.7)
    }

    private var backgroundColor: Color {
        if vm.modelLoadingError != nil { return .red.opacity(0.5) }
        if vm.isModelLoading { return Color.orange.opacity(0.5) }
        if !vm.isModelLoaded { return Color.orange.opacity(0.5) }
        if vm.isRecording { return .recording.opacity(0.5) }
        if vm.isProcessing { return .processing.opacity(0.5) }
        if vm.isSuccess { return .success.opacity(0.5) }
        return .brandPrimary.opacity(0.5)
    }

    private var buttonText: String {
        if let error = vm.modelLoadingError {
            return "Model failed to load: \(error.localizedDescription) - Tap to retry"
        }
        if vm.isModelLoading {
            return "Loading AI model..."
        }
        if !vm.isModelLoaded {
            return "Loading AI model..."
        }
        
        switch (vm.isRecording, vm.isProcessing, vm.isSuccess) {
        case (_,     true, _):    return "Processing..."
        case (_,     _,    true): return "Done!"
        case (true,  _,    _):    return "Tap to stop recording"
        default:                  return "Tap to record"
        }
    }
}

//#Preview {
//    // Example injection for preview
//    let recorder = AudioRecorder()
//    let transcriber = TranscriptionService()
//    let transcriptRepo = SwiftDataTranscriptRepository(context: ModelContext())
//    RecordButton(vm: .init(recorder: recorder,
//                           transcriber: transcriber,
//                           transcriptRepo: transcriptRepo))
//}

