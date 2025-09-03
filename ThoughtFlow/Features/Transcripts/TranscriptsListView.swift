//
//  TranscriptsListView.swift
//  ThoughtFlow
//
//  Created by Ryan Williams on 2025-07-09.
//

import SwiftUI
import SwiftData

struct TranscriptsListView: View {
    @Query(sort: \Transcript.createdAt, order: .reverse) var transcripts: [Transcript]
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTranscript: Transcript?

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedTranscript) {
                ForEach(sortedDates, id: \.self) { date in
                    let transcriptsForDate = groupedTranscripts[date] ?? []
                    let dateString = date.formatted(date: .complete, time: .omitted)
                    
                    DisclosureGroup(dateString) {
                        ForEach(transcriptsForDate) { transcript in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(transcript.title)
                                    .font(.headline)
                                    .lineLimit(1)
                                Text(transcript.createdAt.formatted(date: .omitted, time: .shortened))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 4)
                            .tag(transcript)
                            .swipeActions(edge: .trailing) {
                                Button("Delete", role: .destructive) {
                                    deleteTranscript(transcript)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Transcripts")
        } detail: {
            Group {
                if let transcript = selectedTranscript {
                    TranscriptDetailView(transcript: transcript, onDelete: { deleteTranscript(selectedTranscript) })
                } else {
                    ContentUnavailableView("Select a Transcript", systemImage: "note.text")
                }
            }
        }
    }
    
    // Group transcripts by date
    private var groupedTranscripts: [Date: [Transcript]] {
        Dictionary(grouping: transcripts) { transcript in
            Calendar.current.startOfDay(for: transcript.createdAt)
        }
    }
    
    private var sortedDates: [Date] {
        groupedTranscripts.keys.sorted(by: >)
    }
    
    private func deleteTranscript(_ transcript: Transcript?) {
        guard let transcript else { return }
        modelContext.delete(transcript)
        if selectedTranscript?.id == transcript.id {
            selectedTranscript = nil
        }
    }
    
    private func deleteTranscript(_ transcript: Transcript) {
        modelContext.delete(transcript)
        if selectedTranscript?.id == transcript.id {
            selectedTranscript = nil
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: Transcript.self)
    let context = container.mainContext
    
    // Add dummy transcripts with different dates
    context.insert(Transcript(text: "Sample Transcript 1\nThis is the body of transcript 1.", createdAt: .now))
    context.insert(Transcript(text: "Second transcript from today.", createdAt: .now.addingTimeInterval(-3600)))
    context.insert(Transcript(text: "Yesterday's transcript\nContent from yesterday.", createdAt: .now.addingTimeInterval(-86400)))
    context.insert(Transcript(text: "Another yesterday transcript.", createdAt: .now.addingTimeInterval(-90000)))
    context.insert(Transcript(text: "Transcript from two days ago.", createdAt: .now.addingTimeInterval(-172800)))
    
    return TranscriptsListView()
        .modelContainer(container)
}
