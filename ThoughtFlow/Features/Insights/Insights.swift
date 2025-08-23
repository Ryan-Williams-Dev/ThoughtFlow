//
//  Insights.swift
//  ThoughtFlow
//
//  Created by Ryan Williams on 2025-07-18.
//

import SwiftUI

import SwiftUI

struct Insights: View {
    // Placeholder states
    @State private var selectedTranscriptID: UUID?
    @State private var summary: String = "Your insights will appear here."
    @State private var isLoading: Bool = false
    
    // Placeholder transcript list
    let transcripts: [TranscriptPreview] = [
        TranscriptPreview(id: UUID(), title: "Transcript 1"),
        TranscriptPreview(id: UUID(), title: "Transcript 2"),
        TranscriptPreview(id: UUID(), title: "Transcript 3")
    ]
    
    var body: some View {
        NavigationSplitView {
            List(transcripts, selection: $selectedTranscriptID) { transcript in
                Text(transcript.title)
            }
            .navigationTitle("Transcripts")
            .toolbar {
                Button(action: {
                    // Placeholder for generating insights
                    isLoading.toggle()
                    summary = isLoading ? "Generating insights..." : "Your insights will appear here."
                }) {
                    Text("Generate Insights")
                }
            }
        } detail: {
            ScrollView {
                Text(summary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationTitle("Insights")
        }
    }
}

struct TranscriptPreview: Identifiable {
    let id: UUID
    let title: String
}

#Preview {
    Insights()
}

