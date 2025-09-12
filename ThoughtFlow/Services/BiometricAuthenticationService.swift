//
//  BiometricAuthenticationService.swift
//  ThoughtFlow
//
//  Created by Ryan Williams on 2025-09-12.
//

import Foundation
import LocalAuthentication
import Combine

class BiometricAuthenticationService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var authenticationError: String?
    
    func checkBiometricAvailability() -> Bool {
        let context = LAContext()
        var error: NSError?
        
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }
    
    func authenticateWithBiometrics() async {
        let context = LAContext()
        var error: NSError?
        
        // Check if biometric authentication is available
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            await MainActor.run {
                self.authenticationError = error?.localizedDescription ?? "Biometric authentication not available"
            }
            return
        }
        
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Authenticate to access ThoughtFlow"
            )
            
            await MainActor.run {
                self.isAuthenticated = success
                self.authenticationError = nil
            }
        } catch {
            await MainActor.run {
                self.authenticationError = error.localizedDescription
                self.isAuthenticated = false
            }
        }
    }
    
    func reset() {
        isAuthenticated = false
        authenticationError = nil
    }
}
