//
//  SettingsView.swift
//  ThoughtFlow
//
//  Created by Ryan Williams on 2025-07-09.
//

import SwiftUI

enum Accent: String, CaseIterable {
    case unitedStates
    case unitedKingdom
    case india
    case australia
    case canada
}

struct SettingsView: View {
    @State private var selectedAccent: Accent = .unitedStates

    @State private var requireFaceIDOnLaunch: Bool = false
    @State private var isPresentingDeleteAccountConfirmationSheet: Bool = false

    var body: some View {
        VStack {
            List {
                Section("Personalisation") {
                    Picker("Accent", selection: $selectedAccent) {
                        Text("United States").tag(Accent.unitedStates)
                        Text("United Kingdom").tag(Accent.unitedKingdom)
                        Text("India").tag(Accent.india)
                        Text("Australia").tag(Accent.australia)
                        Text("Canada").tag(Accent.canada)
                    }
                }

                Section("Privacy and Data") {
                    Toggle(
                        "Require Face ID on Launch",
                        isOn: $requireFaceIDOnLaunch
                    )
                    
                    Button("Export Data") {
                        print("exporting data...")
                    }
                }
                
                Section("Support") {
                    Button("Contact Support") {
                        print("Feeding back...")
                    }
                    
                    Text("Version 0.0")
                        .foregroundColor(.secondary)
                }
                
                Section("Danger Zone") {
                    Button("Delete Account", role: .destructive) {
                        isPresentingDeleteAccountConfirmationSheet = true
                    }
                    .confirmationDialog(
                        "Delete Account",
                        isPresented: $isPresentingDeleteAccountConfirmationSheet,
                        titleVisibility: .visible,
                    )   {
                        Button("Confirm Deletion", role: .destructive) {
                            print("boom!")
                        }
                    } message: {
                        Text("Are you sure you want to delete your account? This Action cannot be undone, and all your data will be permantly lost.")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
}
