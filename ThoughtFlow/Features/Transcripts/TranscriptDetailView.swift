//
//  TranscriptDetailView.swift
//  ThoughtFlow
//
//  Created by Ryan Williams on 2025-07-09.
//

import SwiftData
import SwiftUI

struct TranscriptDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    var transcript: Transcript
    let onDelete: () -> Void

    @State private var showDeleteConfirmation = false

    var body: some View {
        ScrollView {
            Text(transcript.text)
                .font(.body)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)
        }
        .navigationTitle(transcript.createdAt.formatted(date: .abbreviated, time: .omitted))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                .tint(.red)
                .confirmationDialog(
                    "Are you sure you want to delete this transcript?",
                    isPresented: $showDeleteConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("Delete Transcript", role: .destructive) {
                        onDelete()
                    }
                    Button("Cancel", role: .cancel) { }
                }
            }
        }
    }
}

#Preview {
    let previewTranscript = Transcript(text: "This is a sample transcript for previewing!\nAdd more lines as needed.", createdAt: Date())
    TranscriptDetailView(transcript: previewTranscript, onDelete: {})
        .modelContainer(for: Transcript.self, inMemory: true)
}
