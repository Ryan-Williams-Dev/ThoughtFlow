//
//  NotesListView.swift
//  ThoughtFlow
//
//  Created by Ryan Williams on 2025-07-09.
//

import SwiftUI
import SwiftData

struct NotesListView: View {
    @Query(sort: \Note.createdAt, order: .reverse) var notes: [Note]
    @Environment(\.modelContext) private var modelContext
    @State private var selectedNote: Note?

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedNote) {
                ForEach(notes) { note in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(note.title)
                            .font(.headline)
                            .lineLimit(1)
                        Text(note.createdAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 4)
                    .tag(note)
                }
                .onDelete(perform: deleteNotes)
            }
            .navigationTitle("Notes")
            .toolbar {
                EditButton()
            }
        } detail: {
            if let note = selectedNote {
                NoteDetailView(note: note)
            } else {
                ContentUnavailableView("Select a Note", systemImage: "note.text")
            }
        }
    }

    private func deleteNotes(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(notes[index])
        }
    }
}

#Preview {
    NotesListView()
}
