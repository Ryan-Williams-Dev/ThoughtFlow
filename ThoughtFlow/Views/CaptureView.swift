//
//  CaptureView.swift
//  ThoughtFlow
//
//  Created by Ryan Williams on 2025-07-09.
//

import SwiftData
import SwiftUI

struct CaptureView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var speechService = SpeechService()
    @State private var isRecording = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Capture your thoughts")
                    .font(.title)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(
                    "Let out what is one your mind in one go. A stream of conciousness if you will.\nAllow us to oragnise it into something useful "
                )
                .font(.headline)
                .foregroundStyle(.opacity(0.7))
                .multilineTextAlignment(.leading)

                Text(
                    speechService.transcript.isEmpty
                        ? "Let it all out..." : speechService.transcript
                )
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .glassEffect(in: .rect(cornerRadius: 32))

                Button(action: {
                    if isRecording {
                        speechService.stopRecording()

                        // Save the transcript if not empty
                        if !speechService.transcript.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ).isEmpty {
                            let newNote = Note(text: speechService.transcript)
                            modelContext.insert(newNote)
                        }

                    } else {
                        speechService.startRecording()
                    }

                    isRecording.toggle()
                }) {
                    Image(
                        systemName: isRecording
                            ? "stop.circle.fill" : "mic.circle.fill"
                    )
                    .font(.system(size: 80))
                    .glassEffect(
                        .regular.interactive()
                    )
                }
            }
            .padding()

        }
    }

}

#Preview {
    CaptureView()
}
