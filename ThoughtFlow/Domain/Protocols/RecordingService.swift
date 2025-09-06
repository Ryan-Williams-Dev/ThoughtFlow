//
//  RecordingService.swift
//  ThoughtFlow
//
//  Created by Ryan Williams on 2025-07-19.
//

import Combine
import Foundation

protocol RecordingServiceProtocol {
    // Begins audio capture. Throws if the engine can't start.
    func startRecording() async throws

    // Stops capture and returns the file URL. Throws on failure.
    func stopRecording() async throws -> URL
}
