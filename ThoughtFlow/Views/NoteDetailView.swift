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
    @Bindable var note: Note

    @State private var draftText: String = ""
    @State private var hasChanges: Bool = false
    @State private var showDeleteConfirmation = false

    var body: some View {
        VStack {
            TextEditor(text: $draftText)
                .padding()
                .font(.body)
                .scrollContentBackground(.hidden)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)
                .padding(.horizontal)
                .onChange(of: draftText) {
                    hasChanges = draftText != note.text
                }

            Spacer()

            if hasChanges {
                HStack {
                    Button(role: .cancel) {
                        draftText = note.text
                        hasChanges = false
                    } label: {
                        Label("Discard", systemImage: "xmark.circle")
                    }

                    Spacer()

                    Button {
                        note.text = draftText
                        hasChanges = false
                    } label: {
                        Label("Save", systemImage: "checkmark.circle")
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .transition(.opacity)
            }
        }
        .navigationTitle(note.createdAt.formatted(date: .abbreviated, time: .omitted))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem {
                Button {
                    print("Share")
                } label: {
                    Label("AI Tools", systemImage: "square.and.arrow.up")
                }
            }
            ToolbarSpacer()
            ToolbarItem {
                Button {
                    print("Taps Forehead")
                } label: {
                    Label("Done", systemImage: "apple.intelligence")
                }
            }
            ToolbarItem {
                Button {
                    print("Edit")
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
            }
            ToolbarSpacer()
            ToolbarItem {
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                .confirmationDialog(
                    "Are you sure you want to delete this note?",
                    isPresented: $showDeleteConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("Delete Note", role: .destructive) {
                        modelContext.delete(note)
                    }
                    Button("Cancel", role: .cancel) {
                        print("Survived to see another day...")
                    }
                }
            }
            ToolbarItem(placement: .keyboard) {
                Button {
                    print("Keyboard")
                } label: {
                    Text("Done")
                }
            }
        }
        .onAppear {
            draftText = note.text
        }

    }
}

//#Preview {
//    NoteDetailView()
//}
