//
//  SpeechService.swift
//  ThoughtFlow
//
//  Created by Ryan Williams on 2025-07-09.
//

import Foundation
import Speech
import AVFoundation
import Combine

class SpeechService: NSObject, ObservableObject {
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let audioEngine = AVAudioEngine()
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    @Published var transcript: String = ""

    override init() {
        super.init()
        SFSpeechRecognizer.requestAuthorization { authStatus in
            if authStatus != .authorized {
                print("Speech recognition not authorized")
            }
        }
    }

    func startRecording() {
        do {
            try startSession()
        } catch {
            print("Error starting recording: \(error.localizedDescription)")
        }
    }

    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        request?.endAudio()
        recognitionTask?.cancel()
    }

    private func startSession() throws {
        if audioEngine.isRunning { stopRecording() }

        request = SFSpeechAudioBufferRecognitionRequest()
        guard let request = request else { return }

        let node = audioEngine.inputNode
        let format = node.outputFormat(forBus: 0)

        node.removeTap(onBus: 0) // clear any previous taps
        node.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            request.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()

        recognitionTask = recognizer?.recognitionTask(with: request) { [weak self] result, error in
            guard let self = self, let result = result else { return }
            DispatchQueue.main.async {
                self.transcript = result.bestTranscription.formattedString
            }
        }
    }
}
