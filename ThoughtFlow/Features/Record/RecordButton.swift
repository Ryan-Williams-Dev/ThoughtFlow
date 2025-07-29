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
        GeometryReader { geo in
            let threshold = geo.size.width * 0.6
            ZStack(alignment: .trailing) {
                buttonContent
                    .offset(x: min(vm.dragOffset, threshold))
                if vm.isRecording {
                    lockIcon(threshold: threshold)
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        vm.handleDragChanged(value.translation.width, lockThreshold: threshold)
                    }
                    .onEnded { value in
                        vm.handleDragEnded(value.translation.width, lockThreshold: threshold)
                    }
            )
            .frame(maxHeight: .infinity)
            .background(backgroundColor)
            .glassEffect()
        }
    }

    @ViewBuilder
    private var buttonContent: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(circleColor)
                .frame(width: 12, height: 12)
                .scaleEffect(vm.isRecording ? 1.2 : 1.0)
            Text(buttonText)
            Spacer()
        }
        .padding(.horizontal, 20)
    }

    private func lockIcon(threshold: CGFloat) -> some View {
        let showLocked = vm.isLockedOn || vm.dragOffset > threshold
        return Image(systemName: showLocked ? "lock.fill" : "lock.open.fill")
            .padding(.trailing, 20)
            .foregroundStyle(.secondary)
    }

    private var circleColor: Color {
        if !vm.isModelLoaded { return .orange }
        if vm.isRecording { return .red }
        if vm.isProcessing { return .blue }
        if vm.isSuccess    { return .green }
        return .primary.opacity(0.6)
    }

    private var backgroundColor: Color {
        if !vm.isModelLoaded { return Color.orange.opacity(0.1) }
        if vm.isRecording { return Color.red.opacity(0.1) }
        if vm.isProcessing { return Color.blue.opacity(0.1) }
        if vm.isSuccess    { return Color.green.opacity(0.1) }
        return .clear
    }

    private var buttonText: String {
        if !vm.isModelLoaded {
            return "Loading AI model..."
        }
        
        switch (vm.isRecording, vm.isLockedOn, vm.isProcessing, vm.isSuccess) {
        case (true,  false, _,    _):    return "Slide right to lock"
        case (_,     _,     true, _):    return "Processing..."
        case (_,     _,     _,    true): return "Done!"
        case (true,  true,  _,    _):    return "Tap to stop recording"
        default:                         return "Hold to record"
        }
    }
}

//#Preview {
//    // Example injection for preview
//    let recorder = AudioRecorder()
//    let transcriber = TranscriptionService()
//    let notesRepo = SwiftDataNoteRepository(context: ModelContext())
//    RecordButton(vm: .init(recorder: recorder,
//                           transcriber: transcriber,
//                           notesRepo: notesRepo))
//}

