//
//  RecordingButton.swift
//  ThoughtFlow
//
//  Created by Ryan Williams on 2025-07-14.
//
import SwiftUI
import Combine

struct RecordingButton: View {
    @ObservedObject var speechService: SpeechService
    @State private var isRecording = false
    @State private var isProcessing = false
    @State private var isLocked = false
    @State private var dragOffset: CGFloat = 0
    @State private var buttonScale: CGFloat = 1.0
    
    // Optional callbacks for additional functionality
//    var onRecordingStart: () -> Void = {}
//    var onRecordingEnd: () -> Void = {}
//    var onProcessingComplete: () -> Void = {}
//
//    private let buttonWidth: CGFloat = 280
//    private let buttonHeight: CGFloat = 56
    private let lockThreshold: CGFloat = 200
    
    var body: some View {
        ZStack(alignment: .trailing) {
            // Content that moves with drag
            HStack(spacing: 12) {
                // Recording indicator
                Circle()
                    .fill(currentTintColor)
                    .frame(width: 12, height: 12)
                    .scaleEffect(isRecording ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: isRecording)
                
                // Button text
                Text(buttonText)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .offset(x: min(dragOffset, lockThreshold))
            
            // Fixed lock icon at right edge
            if isRecording {
                Image(systemName: dragOffset > lockThreshold || isLocked ? "lock.fill" : "lock.open.fill")
                    .padding(.trailing, 20)
            }
        }
        .scaleEffect(buttonScale)
        .animation(.easeInOut(duration: 0.15), value: buttonScale)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    handleDragChanged(value)
                }
                .onEnded { value in
                    handleDragEnded(value)
                }
        )
    }
    
    private var currentTintColor: Color {
        if isProcessing {
            return .green
        } else if isRecording {
            return .red
        } else {
            return .gray.opacity(0.6)
        }
    }
    
    private var buttonText: String {
        if isProcessing {
            return "Processing..."
        } else if isRecording {
            return isLocked ? "Tap to Stop" : "Recording..."
        } else {
            return "Hold to Record"
        }
    }
    
    private func handleDragChanged(_ value: DragGesture.Value) {
        let translation = value.translation.width
        
        if !isRecording && !isProcessing {
            // Start recording on initial press
            startRecording()
        }
        
        // Update drag offset for swipe-to-lock
        if translation > 0 && !isLocked {
            dragOffset = min(translation, lockThreshold)
        }
        
        // Scale effect for press feedback
        buttonScale = 0.95
    }
    
    private func handleDragEnded(_ value: DragGesture.Value) {
        let translation = value.translation.width
        
        buttonScale = 1.0
        
        if isLocked {
            // If locked, toggle recording state
            if isRecording {
                stopRecording()
            }
        } else if translation > lockThreshold {
            // Swipe to lock
            lockRecording()
        } else {
            // Normal press and hold ended
            if isRecording {
                stopRecording()
            }
        }
        
        // Reset drag offset
        withAnimation(.easeOut(duration: 0.3)) {
            dragOffset = 0
        }
    }
    
    private func startRecording() {
        guard !isRecording && !isProcessing else { return }
        
        isRecording = true
        speechService.startRecording()
//        onRecordingStart()
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func stopRecording() {
        guard isRecording else { return }
        
        isRecording = false
        isLocked = false
        speechService.stopRecording()
//        onRecordingEnd()
        
        // Start processing
        startProcessing()
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    private func lockRecording() {
        guard isRecording else { return }
        
        isLocked = true
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
    }
    
    private func startProcessing() {
        isProcessing = true
        
        // Show processing state briefly, then complete
        // The transcript is already being updated in real-time by SpeechService
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            completeProcessing()
        }
    }
    
    private func completeProcessing() {
        isProcessing = false
//        onProcessingComplete()
        
        // Add haptic feedback
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
    }
}

#if DEBUG
class MockSpeechService: SpeechService {
    @Published var isRecording = false
    
    override func startRecording() {
        isRecording = true
        print("Mock: Started recording")
    }
    
    override func stopRecording() {
        isRecording = false
        print("Mock: Stopped recording")
    }
    
    func pauseRecording() {
        print("Mock: Paused recording")
    }
    
    func resumeRecording() {
        print("Mock: Resumed recording")
    }
}
#endif

struct RecordingButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Default state
            RecordingButton(speechService: MockSpeechService())
                .previewDisplayName("Default")
            
            // Recording state
            RecordingButton(speechService: {
                let mock = MockSpeechService()
                mock.isRecording = true
                return mock
            }())
                .previewDisplayName("Recording")
            
            // Interactive preview
            PreviewContainer()
                .previewDisplayName("Interactive")
        }
        .previewLayout(.sizeThatFits)
        .padding()
        .background(Color.gray.opacity(0.1))
    }
}

#if DEBUG
struct PreviewContainer: View {
    @StateObject private var mockService = MockSpeechService()
    
    var body: some View {
        VStack(spacing: 20) {
            RecordingButton(speechService: mockService)
                .frame(height: 56)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(28)
            
            // Controls for testing
            VStack(spacing: 10) {
                Text("Preview Controls")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Button("Toggle Recording") {
                        mockService.isRecording.toggle()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Update Transcript") {
                        mockService.transcript = "New transcript: \(Date().formatted(.dateTime.hour().minute().second()))"
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .padding()
    }
}
#endif

