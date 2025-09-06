//
//  AudioRecorder.swift
//  ThoughtFlow
//
//  Created by Ryan Williams on 2025-07-17.
//

import AVFoundation
import Combine

enum RecordingError: LocalizedError {
    case failedToStart
    case fileNotSaved

    var errorDescription: String? {
        switch self {
        case .failedToStart:
            return "Audio recorder was not initialized."
        case .fileNotSaved:
            return "Recorded file could not be saved."
        }
    }
}

final class AudioRecorder: NSObject, ObservableObject, RecordingServiceProtocol {
    private var recorder: AVAudioRecorder?
    private(set) var audioURL: URL?
    private var audioSession: AVAudioSession = AVAudioSession.sharedInstance()

    func startRecording() async throws {
        // Audio session and permissions are already configured during app setup
        // Just start recording directly
        try await MainActor.run {
            try self.startRecordingInternal()
        }
    }
    
    private func startRecordingInternal() throws {
        let filename = UUID().uuidString + ".m4a"
        let path = FileManager.default.temporaryDirectory
            .appendingPathComponent(filename)
        self.audioURL = path

        print("🎙️ Starting audio recording to: \(path.lastPathComponent)")

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
        ]

        do {
            recorder = try AVAudioRecorder(url: path, settings: settings)
            recorder?.prepareToRecord()
            guard recorder?.record() == true else {
                throw RecordingError.failedToStart
            }
        } catch {
            throw error
        }
    }

    func stopRecording() async throws -> URL {
        return try await MainActor.run {
            guard let recorder = recorder else {
                throw RecordingError.failedToStart
            }

            if recorder.isRecording {
                recorder.stop()
            }

            let url = recorder.url

            let fileExists = FileManager.default.fileExists(atPath: url.path)
            if !fileExists {
                throw RecordingError.fileNotSaved
            }

            print("🛑 Stopped audio recording: \(url.lastPathComponent)")
            self.recorder = nil
            return url
        }
    }
}
