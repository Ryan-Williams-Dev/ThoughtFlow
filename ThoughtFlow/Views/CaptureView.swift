//
//  CaptureView.swift
//  ThoughtFlow
//
//  Created by Ryan Williams on 2025-07-09.
//

import Combine
import SwiftData
import SwiftUI

struct CaptureView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var speechService = SpeechService()
    @State private var isRecording = false
    @State private var isProcessing = false
    @State private var isSaved = false
    @State private var timerText = "00:00"
    @State private var startTime: Date?

    // Timer publisher for updating elapsed time
    private let timer = Timer.publish(every: 1, on: .main, in: .common)
        .autoconnect()

    var body: some View {
        VStack(spacing: 20) {
            Text("Capture your thoughts")
                .font(.title)

            Text(
                "Let out what is on your mind in one go. A stream of consciousness if you will.\nAllow us to organize it into something useful."
            )
            .font(.headline)
            .foregroundStyle(.opacity(0.7))
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)

            if !speechService.transcript.isEmpty {
                Text(speechService.transcript)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(32)
            }

            Spacer()

            // Display timer
            Text(timerText)
                .font(.headline)
                .monospacedDigit()
                .foregroundColor(.secondary)

            // Record / Stop / Processing / Saved button
            Button(action: { buttonTapped() }) {
                ZStack {
                    if isProcessing {
                        ProgressView()
                            .scaleEffect(4)
                            .frame(width: 100, height: 100)
                            .foregroundColor(.primary)
                            .cornerRadius(100)

                    } else if isSaved {
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.green)
                    } else {
                        Image(
                            systemName: isRecording
                                ? "stop.circle.fill" : "mic.circle.fill"
                        )
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundStyle(isRecording ? .red : .primary)
                    }
                }
            }
            .disabled(isProcessing)
            .padding(.bottom)
        }
        .padding()
        .onReceive(timer) { _ in updateTimer() }

    }

    // MARK: - Actions

    private func buttonTapped() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        speechService.startRecording()
        isRecording = true
        isSaved = false
        startTime = Date()
        timerText = "00:00"
    }

    private func stopRecording() {
        speechService.stopRecording()

        let finalText = speechService.transcript
            .trimmingCharacters(in: .whitespacesAndNewlines)

        isRecording = false
        isProcessing = true

        if !finalText.isEmpty {
            let newNote = Note(text: finalText)
            modelContext.insert(newNote)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isProcessing = false
            isSaved = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                isSaved = false
                timerText = "00:00"
                speechService.transcript = ""
            }
        }
    }

    private func updateTimer() {
        guard isRecording, let start = startTime else { return }
        let elapsed = Int(Date().timeIntervalSince(start))
        let minutes = String(format: "%02d", elapsed / 60)
        let seconds = String(format: "%02d", elapsed % 60)
        timerText = "\(minutes):\(seconds)"
    }
}

#Preview {
    CaptureView()
}
