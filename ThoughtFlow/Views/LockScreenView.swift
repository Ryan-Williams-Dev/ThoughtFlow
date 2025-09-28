//
//  LockScreenView.swift
//  ThoughtFlow
//
//  Created by Ryan Williams on 2025-09-12.
//

import SwiftUI

struct LockScreenView: View {
    @StateObject private var authService = BiometricAuthenticationService()
    let onAuthenticated: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // App Logo/Icon
            Image(systemName: "lock.shield")
                .font(.system(size: 80))
                .foregroundColor(.brandPrimary)
            
            VStack(spacing: 16) {
                Text("Echo")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Locked for your privacy.\nAuthenticate to continue")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(spacing: 20) {
                if let error = authService.authenticationError {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                
                Button(action: {
                    Task {
                        await authService.authenticateWithBiometrics()
                    }
                }) {
                    HStack {
                        Image(systemName: "faceid")
                        Text("Authenticate with Face ID")
                    }
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.glassProminent)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .onChange(of: authService.isAuthenticated) { _, isAuthenticated in
            if isAuthenticated {
                onAuthenticated()
            }
        }
        .onAppear {
            // Automatically trigger authentication when view appears
            Task {
                await authService.authenticateWithBiometrics()
            }
        }
    }
}

#Preview {
    LockScreenView {
        print("Authenticated!")
    }
}
