//
//  RecordButton.swift
//  ThoughtFlow
//
//  Created by Ryan Williams on 2025-07-15.
//

import Combine
import SwiftUI

struct RecordButton: View {

    @State private var isRecording = false
    @State private var isProcessing = false
    @State private var isSuccess = false
    @State private var isLockedOn = false
    @State private var dragOffset: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            let lockThreshold = geometry.size.width * 0.6

            ZStack(alignment: .trailing) {
                HStack(spacing: 12) {
                    Circle()
                        .fill(circleColor)
                        .frame(width: 12, height: 12)
                        .scaleEffect(isRecording ? 1.2 : 1.0)

                    Text(buttonText)

                    Spacer()
                }
                .padding(.horizontal, 20)
                .offset(x: min(dragOffset, lockThreshold))

                Group {
                    if !isLockedOn && isRecording {
                        Image(systemName: "lock.open.fill")
                    } else if isLockedOn || dragOffset > lockThreshold {
                        Image(systemName: "lock.fill")
                    }
                }
                .padding(.trailing, 20)
                .foregroundStyle(.secondary)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        handleDragChanged(value, lockThreshold: lockThreshold)
                    }
                    .onEnded { value in
                        handleDragEnded(value, lockThreshold: lockThreshold)
                    }
            )
            .frame(maxHeight: .infinity)
            .background(backgroundColour)
            .glassEffect()
        }
    }

    private func handleDragChanged(
        _ value: DragGesture.Value,
        lockThreshold: CGFloat
    ) {
        let translation = value.translation.width

        if !isRecording && !isProcessing {
            // Start recording on initial press
            startRecording()
        }

        if translation > lockThreshold && !isLockedOn
            && dragOffset <= lockThreshold
        {
            lockRecording()
        }

        // Update drag offset for swipe-to-lock
        if translation > 0 && !isLockedOn {
            dragOffset = min(translation, lockThreshold)
        }
    }

    private func handleDragEnded(
        _ value: DragGesture.Value,
        lockThreshold: CGFloat
    ) {
        let translation = value.translation.width

        if isRecording {
            if isLockedOn && translation <= lockThreshold {
                // Tap to finish when locked (no significant drag)
                endRecording()
            } else if !isLockedOn {
                // Normal press and hold ended (not locked)
                endRecording()
            }
        }

        // Reset drag offset
        withAnimation(.easeOut(duration: 0.3)) {
            dragOffset = 0
        }
    }

    private func startRecording() {
        isRecording = true
        triggerInitialPressHaptic()
    }

    private func endRecording() {
        isRecording = false
        isLockedOn = false
        isProcessing = true

        DispatchQueue.main.asyncAfter(
            deadline: .now() + 2,
            execute: {
                self.isProcessing = false
                self.isSuccess = true
                triggerSuccessHaptic()

                DispatchQueue.main.asyncAfter(
                    deadline: .now() + 2,
                    execute: {
                        self.isSuccess = false
                    }
                )
            }
        )

    }

    private func lockRecording() {
        self.isLockedOn = true
        triggerLockHaptic()
    }

    private func triggerInitialPressHaptic() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }

    private func triggerLockHaptic() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
    }

    private func triggerSuccessHaptic() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
    }

    var circleColor: Color {
        if isRecording {
            Color.red
        } else if isProcessing {
            Color.blue
        } else if isSuccess {
            Color.green
        } else {
            Color.primary.opacity(0.6)
        }
    }

    var backgroundColour: Color {
        if isRecording {
            Color.red.opacity(0.1)
        } else if isProcessing {
            Color.blue.opacity(0.1)
        } else if isSuccess {
            Color.green.opacity(0.1)
        } else {
            Color.clear
        }
    }

    var buttonText: String {
        if isRecording && !isLockedOn {
            "Slide right to lock"
        } else if isProcessing {
            "Processing..."
        } else if isSuccess {
            "Done!"
        } else if isRecording && isLockedOn {
            "Tap to stop recording"
        } else {
            "Hold to record"
        }
    }
}

#Preview {
    RecordButton()
}
