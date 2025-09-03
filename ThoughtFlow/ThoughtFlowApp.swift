//
//  ThoughtFlowApp.swift
//  ThoughtFlow
//
//  Created by Ryan Williams on 2025-07-09.
//

import SwiftUI
import SwiftData

@main
struct ThoughtFlowApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Transcript.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @StateObject private var audioRecorder = AudioRecorder()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(audioRecorder)
        }
        .modelContainer(sharedModelContainer)
    }
}
