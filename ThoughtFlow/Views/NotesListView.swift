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
                EditButton().glassEffect()
            }
            
        } detail: {
            Group {
                if let note = selectedNote {
                    NoteDetailView(note: note)
                } else {
                    ContentUnavailableView("Select a Note", systemImage: "note.text")
                }
            }
            // Give it an “editor” role so bottomBar is positioned correctly
            .toolbarRole(.editor)
            .toolbar {
                // these buttons only appear in your detail view
                ToolbarItemGroup(placement: .keyboard) {
                    Button() {
                        print("yip")
                    } label: {
                        Label("Summarize", systemImage: "apple.intelligence")
                    }
                }
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
    let container = try! ModelContainer(for: Note.self)
    let context = container.mainContext
    // Add dummy notes
    context.insert(Note(text: "Sample Note 1\nThis is the body of note 1.", createdAt: .now))
    context.insert(Note(text: "Second note body goes here.", createdAt: .now.addingTimeInterval(-3600)))
    
    return NotesListView()
        .modelContainer(container)
}
