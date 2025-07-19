//
//  ContentView.swift
//  ThoughtFlow
//
//  Created by Ryan Williams on 2025-07-09.
//

import SwiftData
import SwiftUI

enum Tabs {
    case home
    case insights
    case settings
    case search
}

// ContentView.swift

import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    @State var selectedTab: Tabs = .home
    @State var searchText: String = ""

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house", value: Tabs.home) {
                NotesListView()
            }
            
            Tab("Insights", systemImage: "atom", value: Tabs.insights) {
                Insights()
            }

            Tab("Settings", systemImage: "gear", value: Tabs.settings) {
                SettingsView()
            }
            
            Tab(value: Tabs.search, role: .search) {
                NotesListView()
            }
        }
        .tabViewBottomAccessory {
            RecordButton(
                vm: .init(
                    recorder: AudioRecorder(),
                    transcriber: TranscriptionService(),
                    notesRepo: NoteRepository(modelContext: modelContext)
                )
            )
        }
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Note.self, inMemory: true)
}

