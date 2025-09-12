//
//  ThoughtFlowApp.swift
//  ThoughtFlow
//
//  Created by Ryan Williams on 2025-07-09.
//

import SwiftUI
import SwiftData
import UIKit

@main
struct ThoughtFlowApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Transcript.self,
            Insights.self,
        ])
        
        // Try to create with persistent storage first
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            print("Failed to create persistent ModelContainer: \(error)")
            
            // Fallback to in-memory storage if persistent storage fails
            let inMemoryConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            do {
                print("Falling back to in-memory storage")
                return try ModelContainer(for: schema, configurations: [inMemoryConfiguration])
            } catch {
                fatalError("Could not create ModelContainer even with in-memory storage: \(error)")
            }
        }
    }()
    
    @StateObject private var audioRecorder = AudioRecorder()
    @StateObject private var transcriptionService = TranscriptionService()
    @StateObject private var setupManager: AppSetupManager
    @StateObject private var userDefaults = UserDefaultsManager.shared
    @State private var isSetupComplete = false
    @State private var isAuthenticated = false
    @Environment(\.scenePhase) private var scenePhase

    init() {
        // Create shared instances
        let audioRecorder = AudioRecorder()
        let transcriptionService = TranscriptionService()
        
        // Pass the same instances to setup manager
        let setupManager = AppSetupManager(audioRecorder: audioRecorder, transcriptionService: transcriptionService)
        
        _audioRecorder = StateObject(wrappedValue: audioRecorder)
        _transcriptionService = StateObject(wrappedValue: transcriptionService)
        _setupManager = StateObject(wrappedValue: setupManager)
    }

    var body: some Scene {
        WindowGroup {
            if !isSetupComplete {
                SetupView(setupManager: setupManager) {
                    isSetupComplete = true
                }
                .task {
                    await setupManager.performInitialSetup()
                }
            } else if userDefaults.requireFaceIDOnLaunch && !isAuthenticated {
                LockScreenView {
                    isAuthenticated = true
                }
            } else {
                ContentView(isAuthenticated: $isAuthenticated)
                    .environmentObject(audioRecorder)
                    .environmentObject(transcriptionService)
                    .onChange(of: scenePhase) { _, newPhase in
                        if newPhase == .background && userDefaults.requireFaceIDOnLaunch {
                            isAuthenticated = false
                        }
                    }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
