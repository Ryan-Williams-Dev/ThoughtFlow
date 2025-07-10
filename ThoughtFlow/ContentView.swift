//
//  ContentView.swift
//  ThoughtFlow
//
//  Created by Ryan Williams on 2025-07-09.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        TabView {
            CaptureView()
                .tabItem { Label("Capture", systemImage: "mic.fill") }

            NotesListView()
                .tabItem { Label("Notes", systemImage: "note.text") }

            TasksView()
                .tabItem { Label("Tasks", systemImage: "checkmark.square") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gear") }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Note.self, inMemory: true)
}
