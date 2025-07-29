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
                ForEach(sortedDates, id: \.self) { date in
                    let notesForDate = groupedNotes[date] ?? []
                    let dateString = date.formatted(date: .complete, time: .omitted)
                    
                    DisclosureGroup(dateString) {
                        ForEach(notesForDate) { note in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(note.title)
                                    .font(.headline)
                                    .lineLimit(1)
                                Text(note.createdAt.formatted(date: .omitted, time: .shortened))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 4)
                            .tag(note)
                            .swipeActions(edge: .trailing) {
                                Button("Delete", role: .destructive) {
                                    deleteNote(note)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Notes")
        } detail: {
            Group {
                if let note = selectedNote {
                    NoteDetailView(note: note, onDelete: { deleteNote(selectedNote) })
                } else {
                    ContentUnavailableView("Select a Note", systemImage: "note.text")
                }
            }
        }
    }
    
    // Group notes by date
    private var groupedNotes: [Date: [Note]] {
        Dictionary(grouping: notes) { note in
            Calendar.current.startOfDay(for: note.createdAt)
        }
    }
    
    private var sortedDates: [Date] {
        groupedNotes.keys.sorted(by: >)
    }
    
    private func deleteNote(_ note: Note?) {
        guard let note else { return }
        modelContext.delete(note)
        if selectedNote?.id == note.id {
            selectedNote = nil
        }
    }
    
    private func deleteNote(_ note: Note) {
        modelContext.delete(note)
        if selectedNote?.id == note.id {
            selectedNote = nil
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: Note.self)
    let context = container.mainContext
    
    // Add dummy notes with different dates
    context.insert(Note(text: "Sample Note 1\nThis is the body of note 1.", createdAt: .now))
    context.insert(Note(text: "Second note from today.", createdAt: .now.addingTimeInterval(-3600)))
    context.insert(Note(text: "Yesterday's note\nContent from yesterday.", createdAt: .now.addingTimeInterval(-86400)))
    context.insert(Note(text: "Another yesterday note.", createdAt: .now.addingTimeInterval(-90000)))
    context.insert(Note(text: "Note from two days ago.", createdAt: .now.addingTimeInterval(-172800)))
    
    return NotesListView()
        .modelContainer(container)
}
