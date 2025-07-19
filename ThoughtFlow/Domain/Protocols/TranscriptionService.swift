//
//  TranscriptionService.swift
//  ThoughtFlow
//
//  Created by Ryan Williams on 2025-07-19.
//

import Foundation

protocol TranscriptionServiceProtocol {
  func transcribe(audioURL: URL) async throws -> String
}
