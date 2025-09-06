//
//  Transcription.swift
//  ThoughtFlow
//
//  Created by Ryan Williams on 2025-07-17.
//

import Foundation
import WhisperKit
import Combine

class TranscriptionService: ObservableObject, TranscriptionServiceProtocol {
    private var whisperKit: WhisperKit?
    @Published var isModelLoaded = false
    @Published var isModelLoading = false
    @Published var modelLoadingError: Error?
    
    var config = WhisperKitConfig(
        model: "small.en"
    )
    
    init() {
        print("🚀 TranscriptionService initializing...")
        Task {
            await preloadModel()
        }
    }
    
    private func preloadModel() async {
        print("🔄 Starting AI model preload...")
        await MainActor.run {
            self.isModelLoading = true
            self.modelLoadingError = nil
        }
        
        do {
            // Load model on background thread to prevent UI blocking
            let whisperKit = try await Task.detached {
                print("📥 Downloading/loading WhisperKit model...")
                return try await WhisperKit(self.config)
            }.value
            
            await MainActor.run {
                self.whisperKit = whisperKit
                self.isModelLoaded = true
                self.isModelLoading = false
                self.modelLoadingError = nil
            }
            print("✅ WhisperKit model loaded successfully")
            
            // Warm up the model to ensure it's fully ready for first transcription
            await warmUpModel(whisperKit: whisperKit)
        } catch {
            await MainActor.run {
                self.isModelLoaded = false
                self.isModelLoading = false
                self.modelLoadingError = error
            }
            print("❌ Failed to preload WhisperKit model: \(error)")
        }
    }
    
    func transcribe(audioURL: URL) async throws -> String {
        guard isModelLoaded, let loadedWhisperKit = self.whisperKit else {
            print("❌ Model not loaded when trying to transcribe")
            throw NSError(domain: "Transcription", code: 1,
                         userInfo: [NSLocalizedDescriptionKey: "Model not loaded"])
        }
        
        print("🎯 Starting transcription of: \(audioURL.lastPathComponent)")
        print("🔍 WhisperKit instance ready for transcription")
        
        let results = try await loadedWhisperKit.transcribe(audioPath: audioURL.path)
        guard !results.isEmpty else {
            throw NSError(domain: "Transcription", code: 0,
                          userInfo: [NSLocalizedDescriptionKey: "No transcription result"])
        }
        
        let fullText = results
            .map { $0.text.trimmingCharacters(in: .whitespacesAndNewlines) }
            .joined(separator: " ")
        
        print("✅ Transcription completed: \(fullText.prefix(50))...")
        
        // Cleanup audio file after successful transcription
        do {
            try FileManager.default.removeItem(at: audioURL)
            print("🗑️ Deleted audio file: \(audioURL.lastPathComponent)")
        } catch {
            print("⚠️ Warning: Failed to delete audio file at \(audioURL.lastPathComponent): \(error)")
        }
        
        return fullText
    }
    
    func retryModelLoading() async {
        await preloadModel()
    }
    
    /// Warm up the model to ensure it's fully ready for transcription
    private func warmUpModel(whisperKit: WhisperKit) async {
        do {
            print("🔥 Warming up model for first transcription...")
            
            // Create a minimal silent audio file for warm-up
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("warmup.wav")
            
            // Create a 1-second silent WAV file
            let sampleRate: Double = 16000
            let duration: Double = 1.0
            let numSamples = Int(sampleRate * duration)
            
            // Create silent audio data (16-bit PCM)
            var audioData = Data()
            for _ in 0..<numSamples {
                let sample: Int16 = 0 // Silent
                audioData.append(contentsOf: withUnsafeBytes(of: sample.littleEndian) { Data($0) })
            }
            
            // Write WAV header + data
            let wavData = createWAVHeader(sampleRate: sampleRate, numSamples: numSamples) + audioData
            try wavData.write(to: tempURL)
            
            // Perform warm-up transcription
            let _ = try await whisperKit.transcribe(audioPath: tempURL.path)
            
            // Clean up
            try? FileManager.default.removeItem(at: tempURL)
            
            print("✅ Model warm-up completed - ready for real transcriptions")
        } catch {
            print("⚠️ Model warm-up failed but continuing: \(error)")
        }
    }
    
    /// Create a minimal WAV header for silent audio
    private func createWAVHeader(sampleRate: Double, numSamples: Int) -> Data {
        let numChannels: UInt16 = 1
        let bitsPerSample: UInt16 = 16
        let byteRate = UInt32(sampleRate * Double(numChannels) * Double(bitsPerSample) / 8)
        let blockAlign = UInt16(numChannels * bitsPerSample / 8)
        let dataSize = UInt32(numSamples * Int(blockAlign))
        let fileSize = UInt32(36 + dataSize)
        
        var header = Data()
        header.append("RIFF".data(using: .ascii)!)
        header.append(contentsOf: withUnsafeBytes(of: fileSize.littleEndian) { Data($0) })
        header.append("WAVE".data(using: .ascii)!)
        header.append("fmt ".data(using: .ascii)!)
        header.append(contentsOf: withUnsafeBytes(of: UInt32(16).littleEndian) { Data($0) })
        header.append(contentsOf: withUnsafeBytes(of: UInt16(1).littleEndian) { Data($0) })
        header.append(contentsOf: withUnsafeBytes(of: numChannels.littleEndian) { Data($0) })
        header.append(contentsOf: withUnsafeBytes(of: UInt32(sampleRate).littleEndian) { Data($0) })
        header.append(contentsOf: withUnsafeBytes(of: byteRate.littleEndian) { Data($0) })
        header.append(contentsOf: withUnsafeBytes(of: blockAlign.littleEndian) { Data($0) })
        header.append(contentsOf: withUnsafeBytes(of: bitsPerSample.littleEndian) { Data($0) })
        header.append("data".data(using: .ascii)!)
        header.append(contentsOf: withUnsafeBytes(of: dataSize.littleEndian) { Data($0) })
        
        return header
    }
    
    func clearCache() {
        // Clear WhisperKit cache directory
        let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        let whisperKitCacheURL = cacheURL?.appendingPathComponent("com.argmax.whisperkit")
        
        if let cacheURL = whisperKitCacheURL {
            do {
                try FileManager.default.removeItem(at: cacheURL)
                print("Cleared WhisperKit cache")
            } catch {
                print("Failed to clear WhisperKit cache: \(error)")
            }
        }
        
        // Also clear HuggingFace cache
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let huggingFaceCacheURL = documentsURL?.appendingPathComponent("huggingface")
        
        if let cacheURL = huggingFaceCacheURL {
            do {
                try FileManager.default.removeItem(at: cacheURL)
                print("Cleared HuggingFace cache")
            } catch {
                print("Failed to clear HuggingFace cache: \(error)")
            }
        }
    }
}

