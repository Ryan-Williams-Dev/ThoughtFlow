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
    @State private var expandedMonths: Set<String> = []
    @State private var expandedDays: Set<String> = []

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedTranscript) {
                ForEach(groupTranscriptsByMonth(transcripts: transcripts), id: \.id) { monthSection in
                    DisclosureGroup(
                        monthSection.displayName,
                        isExpanded: Binding(
                            get: { expandedMonths.contains(monthSection.id) },
                            set: { isExpanded in
                                if isExpanded {
                                    expandedMonths.insert(monthSection.id)
                                } else {
                                    expandedMonths.remove(monthSection.id)
                                }
                            }
                        )
                    ) {
                        ForEach(monthSection.days, id: \.self) { day in
                            let transcriptsForDay = groupedTranscripts[day] ?? []
                            let dayString = day.formatted(date: .abbreviated, time: .omitted)
                            let dayId = day.formatted(date: .complete, time: .omitted)
                            
                            DisclosureGroup(
                                dayString,
                                isExpanded: Binding(
                                    get: { expandedDays.contains(dayId) },
                                    set: { isExpanded in
                                        if isExpanded {
                                            expandedDays.insert(dayId)
                                        } else {
                                            expandedDays.remove(dayId)
                                        }
                                    }
                                )
                            ) {
                                ForEach(transcriptsForDay) { transcript in
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
                }
            }
            .navigationTitle("Transcripts")
            .toolbar {
                // Testing button - remove this in production
                Button("Add Test Data") {
                    Task {
                        await addMockTranscriptsForTesting()
                    }
                }
            }
            .onAppear {
                // Auto-expand the most recent month and day
                let monthSections = groupTranscriptsByMonth(transcripts: transcripts)
                if let mostRecentMonth = monthSections.first {
                    expandedMonths.insert(mostRecentMonth.id)
                    
                    // Also expand the most recent day in that month
                    if let mostRecentDay = mostRecentMonth.days.first {
                        let dayId = mostRecentDay.formatted(date: .complete, time: .omitted)
                        expandedDays.insert(dayId)
                    }
                }
            }
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
    
    private func groupTranscriptsByMonth(transcripts: [Transcript]) -> [TranscriptMonthSection] {
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy" // e.g., "August 2025"
        
        // Group transcripts by year and month combination
        let groupedByYearMonth = Dictionary(grouping: transcripts) { transcript in
            let year = calendar.component(.year, from: transcript.createdAt)
            let month = calendar.component(.month, from: transcript.createdAt)
            return "\(year)-\(month)"
        }
        
        let monthSections = groupedByYearMonth.map { (yearMonthKey, transcriptsInMonth) in
            // Get year and month from the first transcript in this group
            let firstTranscript = transcriptsInMonth.first!
            let year = calendar.component(.year, from: firstTranscript.createdAt)
            let month = calendar.component(.month, from: firstTranscript.createdAt)
            
            // Get unique days in this month
            let daysInMonth = Set(transcriptsInMonth.map { calendar.startOfDay(for: $0.createdAt) })
            let sortedDays = Array(daysInMonth).sorted(by: >)
            
            return TranscriptMonthSection(
                id: yearMonthKey,
                year: year,
                month: month,
                displayName: dateFormatter.string(from: firstTranscript.createdAt),
                days: sortedDays
            )
        }
        
        // Sort months by date (most recent first)
        return monthSections.sorted { section1, section2 in
            if section1.year != section2.year {
                return section1.year > section2.year
            }
            return section1.month > section2.month
        }
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
    
    // MARK: - Testing Helper
    private func addMockTranscriptsForTesting() async {
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
        let startOfYesterday = calendar.startOfDay(for: yesterday)
        
        // Create mock transcripts for yesterday
        let mockTranscripts = [
            Transcript(
                text: "Had a really productive morning today. I woke up early and went for a run, which gave me so much energy for the rest of the day. I think I should make this a regular habit.",
                createdAt: calendar.date(byAdding: .hour, value: 7, to: startOfYesterday)!
            ),
            Transcript(
                text: "Feeling a bit overwhelmed with all the tasks I have to do. I need to prioritize better and maybe delegate some of the smaller tasks. The key is to focus on what's most important.",
                createdAt: calendar.date(byAdding: .hour, value: 14, to: startOfYesterday)!
            ),
            Transcript(
                text: "Just finished a great conversation with my colleague about the new project. We came up with some innovative ideas that could really make a difference. I'm excited to start implementing them tomorrow.",
                createdAt: calendar.date(byAdding: .hour, value: 16, to: startOfYesterday)!
            ),
            Transcript(
                text: "Reflecting on today, I realize I need to work on my time management. I spent too much time on social media instead of focusing on my goals. Tomorrow I'll set specific time blocks for different activities.",
                createdAt: calendar.date(byAdding: .hour, value: 21, to: startOfYesterday)!
            )
        ]
        
        // Insert mock transcripts
        for transcript in mockTranscripts {
            modelContext.insert(transcript)
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving mock transcripts: \(error)")
        }
    }
}

struct TranscriptMonthSection: Identifiable {
    let id: String
    let year: Int
    let month: Int
    let displayName: String
    var days: [Date]
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
