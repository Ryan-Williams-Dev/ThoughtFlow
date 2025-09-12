//
//  UserDefaultsManager.swift
//  ThoughtFlow
//
//  Created by Ryan Williams on 2025-09-12.
//

import Foundation
import Combine

class UserDefaultsManager: ObservableObject {
    static let shared = UserDefaultsManager()
    
    private init() {}
    
    var requireFaceIDOnLaunch: Bool {
        get {
            UserDefaults.standard.bool(forKey: "requireFaceIDOnLaunch")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "requireFaceIDOnLaunch")
            objectWillChange.send()
        }
    }
    
    var selectedAccent: String {
        get {
            UserDefaults.standard.string(forKey: "selectedAccent") ?? "unitedStates"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "selectedAccent")
            objectWillChange.send()
        }
    }
}
