//
//  QuizGetReady.swift
//  Planet
//
//  Created by itkhld on 2.02.2025.
//

import SwiftUI

struct QuizGetReady: View {
    
    @State private var currentStep = 0
    @State private var fadeIn = false
    @State private var showQuizView = false
    @State private var showCountDown = false
    @State private var showInstruction = true
    
    let countDownMessage = ["GET READY", "3", "2", "1"]
    
    var body: some View {
        if showQuizView {
            QuizView()
        } else if showInstruction {
            InstructionView {
                withAnimation {
                    showInstruction = false
                    showCountDown = true
                    startCountDown()
                }
            }
        } else if showCountDown {
            ZStack {
                Color.blue.ignoresSafeArea()
                Text(countDownMessage[currentStep])
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .bold()
                    .opacity(fadeIn ? 1 : 0)
                    .animation(.easeInOut(duration: 0.8), value: fadeIn)
                    .onAppear {
                        fadeIn = true
                    }
            }
        }
    }
    
    private func startCountDown() {
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { timer in
            if currentStep < countDownMessage.count - 1 {
                currentStep += 1
                fadeIn = false
                triggerHapticFeedback()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    fadeIn = true
                }
            } else {
                timer.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    showQuizView = true
                }
            }
        }
    }
    
    private func triggerHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
}


struct InstructionView: View {
    var onComplete: () -> Void
    
    var body: some View {
        ZStack {
            Color.blue.ignoresSafeArea()
            VStack {
                Text("Ok")
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                onComplete()
            }
        }
    }
}

#Preview {
    QuizGetReady()
}

