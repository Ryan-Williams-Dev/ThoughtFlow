//
//  SetupView.swift
//  ThoughtFlow
//
//  Created by Ryan Williams on 2025-01-27.
//

import SwiftUI

struct SetupView: View {
    @ObservedObject var setupManager: AppSetupManager
    let onSetupComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // App Icon/Logo
            Image(systemName: "waveform.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue)
            
            VStack(spacing: 16) {
                Text("ThoughtFlow")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Voice-to-Text Recording")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Setup Progress
            VStack(spacing: 20) {
                if let error = setupManager.setupError {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.red)
                        
                        Text("Setup Failed")
                            .font(.headline)
                            .foregroundStyle(.red)
                        
                        Text(error.localizedDescription)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Retry Setup") {
                            Task {
                                await setupManager.retrySetup()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                        
                        Text(setupManager.setupProgress)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .onChange(of: setupManager.isSetupComplete) { _, isComplete in
            if isComplete {
                onSetupComplete()
            }
        }
    }
}

#Preview {
    SetupView(
        setupManager: AppSetupManager(
            audioRecorder: AudioRecorder(),
            transcriptionService: TranscriptionService()
        )
    ) {
        print("Setup complete")
    }
}
