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
    @EnvironmentObject private var audioRecorder: AudioRecorder
    @EnvironmentObject private var transcriptionService: TranscriptionService
    @StateObject private var userDefaults = UserDefaultsManager.shared

    @State var selectedTab: Tabs = .home
    @State var searchText: String = ""
    @Binding var isAuthenticated: Bool

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house", value: Tabs.home) {
                TranscriptsListView()
            }
            
            Tab("Insights", systemImage: "atom", value: Tabs.insights) {
                InsightsListView(vm: InsightsViewModel(
                    insightsService: InsightsService(
                        transcriptRepository: TranscriptRepository(modelContext: modelContext),
                        insightsRepository: InsightsRepository(modelContext: modelContext)
                    )
                ))
            }

            Tab("Settings", systemImage: "gear", value: Tabs.settings) {
                SettingsView()
            }
        }
        .tabViewBottomAccessory {
            RecordButton(
                vm: .init(
                    recorder: audioRecorder,
                    transcriber: transcriptionService,
                    transcriptRepo: TranscriptRepository(modelContext: modelContext)
                )
            )
        }
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}

#Preview {
    ContentView(isAuthenticated: .constant(true))
        .modelContainer(for: Transcript.self, inMemory: true)
        .environmentObject(AudioRecorder())
        .environmentObject(TranscriptionService())
}
