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

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var speechService = SpeechService()
    
    @State var selectedTab: Tabs = .home
    @State var searchText: String = ""

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house", value: Tabs.home, role: nil) {
                NotesListView()
            }
            
            Tab("Insights", systemImage: "atom", value: Tabs.insights) {
                NotesListView()
            }

            Tab("Settings", systemImage: "gear", value: Tabs.settings, role: nil) {
                SettingsView()
            }
            
            Tab(value: Tabs.search, role: .search) {
                NotesListView()
            }
        }
        .tabViewBottomAccessory {
//            RecordingButton(
//                speechService: speechService,
//            )
            RecordButton()
        }
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Note.self, inMemory: true)
}
