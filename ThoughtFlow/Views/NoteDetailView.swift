//
//  NoteDetailView.swift
//  ThoughtFlow
//
//  Created by Ryan Williams on 2025-07-09.
//

import SwiftData
import SwiftUI

struct NoteDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    var note: Note
    let onDelete: () -> Void

    @State private var showDeleteConfirmation = false

    var body: some View {
        ScrollView {
            Text(note.text)
                .font(.body)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .textSelection(.enabled)
        }
        .navigationTitle(note.createdAt.formatted(date: .abbreviated, time: .omitted))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                .tint(.red)
                .confirmationDialog(
                    "Are you sure you want to delete this note?",
                    isPresented: $showDeleteConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("Delete Note", role: .destructive) {
                        onDelete()
                    }
                    Button("Cancel", role: .cancel) { }
                }
            }
        }
    }
}

#Preview {
    let previewNote = Note(text: "This is a sample note for previewing!\nAdd more lines as needed.", createdAt: Date())
    NoteDetailView(note: previewNote, onDelete: {})
        .modelContainer(for: Note.self, inMemory: true)
}
