//
//  QuizView.swift
//  Planet
//
//  Created by itkhld on 2024-09-30.
//

import SwiftUI

struct QuizQuestion {
    let question: String
    let options: [String]
    let correctAnswer: String
}

struct QuizView: View {
    @State private var currentQuestionIndex = 0
    @State private var score = 0
    @State private var showResult = false
    @State private var isGradientAnimating = false
    @State private var selectedAnswer = ""
    @State private var selectedQuestions: [QuizQuestion] = []
    @State private var timeRemaining = 10
    @State private var timer: Timer?
    @State private var countdownTimer: Timer?
    @State private var countdownValue = 4
    @State private var highScore = UserDefaults.standard.integer(forKey: "HighScore")
    let totalTime = 10
    private let numberOfQuestionsToAsk = 10
    
    var body: some View {
        Group {
            if deviceType() == "iPhone" {
                NavigationView {
                    mainContent
                }
            } else if deviceType() == "iPad" {
                NavigationStack {
                    mainContent
                }
            }
        }
    }
    
    var mainContent: some View {
        ZStack {
            if deviceType() == "iPhone" {
                LinearGradient(gradient: Gradient(colors: isGradientAnimating ? [Color("Q1"), Color("Q2"), Color("Q3"), Color("Q4"), Color("Q5")] : [Color("Q5"), Color("Q4"), Color("Q3"), Color("Q2"), Color("Q1")]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
                .animation(Animation.linear(duration: 5).repeatForever(autoreverses: true), value: isGradientAnimating)
                .onAppear { isGradientAnimating = true }
            } else {
                LinearGradient(gradient: Gradient(colors: isGradientAnimating ? [Color("Q1"), Color("Q2"), Color("Q3"), Color("Q4"), Color("Q5")] : [Color("Q5"), Color("Q4"), Color("Q3"), Color("Q2"), Color("Q1")]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            }
            
            if countdownValue > 0 {
                CountdownView(countdownValue: $countdownValue, deviceType: deviceType())
            } else {
                quizContent
            }
        }
        .onAppear(perform: resetQuiz)
        .onDisappear {
            stopTimer()
            countdownTimer?.invalidate()
        }
    }
    
    var quizContent: some View {
        Group {
            if showResult {
                resultView
            } else {
                VStack {
                    progressViews
                    Spacer()
                    questionView
                    optionsView
                    Spacer()
                }
            }
        }
    }
    
    var resultView: some View {
        VStack {
            Text("Quiz Finished!")
                .font(.custom("AvenirNext-Regular", size: deviceType() == "iPhone" ? 28 : 38))
                .foregroundColor(.white)
                .padding()
            
            Text("Your Score: \(score) / \(numberOfQuestionsToAsk)")
                .foregroundColor(.white)
                .font(.custom("AvenirNext-Regular", size: deviceType() == "iPhone" ? 24 : 34))
            
            Text("High Score: \(highScore)")
                .foregroundColor(.yellow)
                .font(.custom("AvenirNext-Regular", size: deviceType() == "iPhone" ? 20 : 30))
                .padding()
            
            Button(action: restartQuiz) {
                Text("Try Again")
                    .font(.custom("AvenirNext-Regular", size: deviceType() == "iPhone" ? 20 : 30))
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(deviceType() == "iPhone" ? 25 : 25)
            }
        }
    }
    
    var progressViews: some View {
        VStack {
            ProgressView(value: Double(currentQuestionIndex + 1), total: Double(numberOfQuestionsToAsk)) {
                Text("Question #\(currentQuestionIndex + 1)")
            }
            .progressViewStyle(LinearProgressViewStyle(tint: .green))
            .padding()
            
            ProgressView(value: Double(totalTime - timeRemaining) / Double(totalTime)) {
                Text("Time Remaining")
            } currentValueLabel: {
                Text("\(timeRemaining)s")
            }
            .progressViewStyle(LinearProgressViewStyle(tint: .red))
            .padding()
        }
        .padding(.horizontal)
        .font(.custom("AvenirNext-Regular", size: deviceType() == "iPhone" ? 14 : 22))
        .bold()
        .foregroundColor(.white)
    }
    
    var questionView: some View {
        Group {
            if currentQuestionIndex < selectedQuestions.count {
                Text(selectedQuestions[currentQuestionIndex].question)
                    .font(.custom("AvenirNext-Regular", size: deviceType() == "iPhone" ? 20 : 30))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding(50)
            }
        }
    }
    
    var optionsView: some View {
        Group {
            if currentQuestionIndex < selectedQuestions.count {
                ForEach(selectedQuestions[currentQuestionIndex].options, id: \.self) { option in
                    Button(action: { answerSelected(option) }) {
                        Text(option)
                            .font(.custom("AvenirNext-Regular", size: deviceType() == "iPhone" ? 18 : 28))
                            .frame(width: deviceType() == "iPhone" ? 150 : 250,
                                   height: deviceType() == "iPhone" ? 20 : 40)
                            .padding()
                            .background(selectedAnswer == option ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(.white)
                            .cornerRadius(25)
                    }
                    .padding(.vertical, deviceType() == "iPhone" ? 5 : 15)
                }
            }
        }
    }
    
    private func answerSelected(_ answer: String) {
        let HapticTouch = UIImpactFeedbackGenerator(style: .medium)
        HapticTouch.impactOccurred()
        stopTimer()
        selectedAnswer = answer
        if answer == selectedQuestions[currentQuestionIndex].correctAnswer {
            score += 1
        }
        moveToNextQuestion()
    }
    
    private func moveToNextQuestion() {
        if currentQuestionIndex < selectedQuestions.count - 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                currentQuestionIndex += 1
                selectedAnswer = ""
                setTimer()
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                showResult = true
                stopTimer()
                saveHighScore()
            }
        }
    }
    
    private func setTimer() {
        timeRemaining = totalTime
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()
                if selectedAnswer.isEmpty {
                    moveToNextQuestion()
                }
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
    }
    
    private func restartQuiz() {
        let HapticTouch = UIImpactFeedbackGenerator(style: .medium)
        HapticTouch.impactOccurred()
        resetQuiz()
    }
    
    private func resetQuiz() {
        currentQuestionIndex = 0
        score = 0
        showResult = false
        selectedAnswer = ""
        timeRemaining = 10
        selectedQuestions = questions.shuffled().prefix(numberOfQuestionsToAsk).map { $0 }
        
        countdownValue = 4
        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if countdownValue > 0 {
                countdownValue -= 1
            } else {
                countdownTimer?.invalidate()
                setTimer()
            }
        }
    }
    
    private func saveHighScore() {
        if score > highScore {
            UserDefaults.standard.set(score, forKey: "HighScore")
            highScore = score
        }
    }
}

struct CountdownView: View {
    @Binding var countdownValue: Int
    let deviceType: String
    
    var body: some View {
        VStack {
            Spacer()
            Text(countdownText)
                .font(.custom("AvenirNext-Regular", size: textSize))
                .foregroundColor(.white)
                .bold()
                .scaleEffect(scaleValue)
                .animation(animation, value: countdownValue)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var countdownText: String {
        countdownValue == 4 ? "GET READY" : "\(countdownValue)"
    }
    
    private var textSize: CGFloat {
        if countdownValue == 4 {
            return deviceType == "iPhone" ? 40 : 60
        }
        return deviceType == "iPhone" ? 80 : 120
    }
    
    private var scaleValue: CGFloat {
        countdownValue == 4 ? 1.0 : 1.5
    }
    
    private var animation: Animation {
        .spring(response: 0.3, dampingFraction: 0.5)
    }
}

#Preview {
    QuizView()
}

//import SwiftUI
//
//struct QuizQuestion {
//    let question: String
//    let options: [String]
//    let correctAnswer: String
//}
//
//struct QuizView: View {
//    @State private var currentQuestionIndex = 0
//    @State private var score = 0
//    @State private var showResult = false
//    @State private var isGradientAnimating = false
//    @State private var selectedAnswer = ""
//    @State private var starAngle: Double = 0
//    @State private var selectedQuestions: [QuizQuestion] = []
//    @State private var timeRemaining = 10
//    @State private var timer: Timer?
//    @State private var highScore = UserDefaults.standard.integer(forKey: "HighScore")
//    @State private var titleColor: Color = .black
//    let totalTime = 10
//    private let numberOfQuestionsToAsk = 10
//
//    var body: some View {
//        if deviceType() == "iPhone" {
//            NavigationView {
//                ZStack {
//                    LinearGradient(gradient: Gradient(colors: isGradientAnimating ? [Color("Q1"), Color("Q2"), Color("Q3"), Color("Q4"), Color("Q5")] : [Color("Q5"), Color("Q4") ,Color("Q3"), Color("Q2"), Color("Q1")]), startPoint: .topLeading, endPoint: .bottomTrailing)
//                        .edgesIgnoringSafeArea(.all)
//                        .animation(Animation.linear(duration: 5).repeatForever(autoreverses: true), value: isGradientAnimating)
//                        .onAppear {
//                            isGradientAnimating = true
//                        }
//                    VStack {
//                        if showResult {
//                            Text("Quiz Finished!")
//                                .font(.custom("AvenirNext-Regular", size: 28))
//                                .foregroundColor(.white)
//                                .padding()
//                            Text("Your Score: \(score) / \(numberOfQuestionsToAsk)")
//                                .foregroundColor(.white)
//                                .font(.custom("AvenirNext-Regular", size: 24))
//
//                            Text("High Score: \(highScore)")
//                                .foregroundColor(.yellow)
//                                .font(.custom("AvenirNext-Regular", size: 20))
//                                .padding()
//
//                            Button(action: {
//                                let HapticTouch = UIImpactFeedbackGenerator(style: .medium)
//                                HapticTouch.impactOccurred()
//                                resetQuiz()
//                            }) {
//                                Text("Try Again")
//                                    .font(.custom("AvenirNext-Regular", size: 20))
//                                    .padding()
//                                    .background(Color.green)
//                                    .foregroundColor(.white)
//                                    .cornerRadius(25)
//                            }
//                        } else {
//                            VStack {
//                                ProgressView(value: Double(currentQuestionIndex + 1), total: Double(numberOfQuestionsToAsk)){
//                                    Text("Question #\(currentQuestionIndex + 1)")
//                                }
//                                .progressViewStyle(LinearProgressViewStyle(tint: .green))
//                                .padding()
//
//                                ProgressView(value: Double(totalTime - timeRemaining) / Double(totalTime)){
//                                    Text("Time Remaining")
//                                } currentValueLabel: {
//                                    Text("\(timeRemaining)s")
//                                }
//                                .progressViewStyle(LinearProgressViewStyle(tint: .red))
//                                .padding()
//                            }
//                            .padding(.horizontal)
//                            .font(.custom("AvenirNext-Regular", size: 14))
//                            .bold()
//                            .foregroundColor(.white)
//
//                            if currentQuestionIndex < selectedQuestions.count {
//                                Text(selectedQuestions[currentQuestionIndex].question)
//                                    .frame(height: 100)
//                                    .frame(maxWidth: .infinity)
//                                    .font(.custom("AvenirNext-Regular", size: 20))
//                                    .multilineTextAlignment(.center)
//                                    .foregroundColor(.white)
//                                    .padding(50)
//
//                                ForEach(selectedQuestions[currentQuestionIndex].options, id: \.self) { option in
//                                    Button(action: {
//                                        let HapticTouch = UIImpactFeedbackGenerator(style: .medium)
//                                        HapticTouch.impactOccurred()
//                                        answerSelected(option)
//                                    }) {
//                                        Text(option)
//                                            .font(.custom("AvenirNext-Regular", size: 18))
//                                            .frame(width: 150, height: 20)
//                                            .padding()
//                                            .background(selectedAnswer == option ? Color.blue : Color.gray.opacity(0.2))
//                                            .foregroundColor(.white)
//                                            .cornerRadius(25)
//                                    }
//                                    .padding(.vertical, 5)
//                                }
//
//                            }
//                            Spacer()
//                        }
//                    }
//                    .onAppear {
//                        resetQuiz()
//                    }
//
//                    .onDisappear {
//                        stopTimer()
//                    }
//                }
//            }
//        }
//        else if deviceType() == "iPad" {
//            NavigationStack {
//                ZStack {
//                    LinearGradient(gradient: Gradient(colors: isGradientAnimating ? [Color("Q1"), Color("Q2"), Color("Q3"), Color("Q4"), Color("Q5")] : [Color("Q5"), Color("Q4") ,Color("Q3"), Color("Q2"), Color("Q1")]), startPoint: .topLeading, endPoint: .bottomTrailing)
//                        .edgesIgnoringSafeArea(.all)
//                    .animation(Animation.linear(duration: 5).repeatForever(autoreverses: true), value: isGradientAnimating)
//
//                    VStack {
//                        if showResult {
//                            Text("Quiz Finished!")
//                                .font(.custom("AvenirNext-Regular", size: 38))
//                                .foregroundColor(.white)
//                                .padding()
//                            Text("Your Score: \(score) / \(numberOfQuestionsToAsk)")
//                                .foregroundColor(.white)
//                                .font(.custom("AvenirNext-Regular", size: 34))
//
//                            Text("High Score: \(highScore)")
//                                .foregroundColor(.yellow)
//                                .font(.custom("AvenirNext-Regular", size: 30))
//                                .padding()
//
//                            Button(action: {
//                                let HapticTouch = UIImpactFeedbackGenerator(style: .medium)
//                                HapticTouch.impactOccurred()
//                                resetQuiz()
//                            }) {
//                                Text("Try Again")
//                                    .font(.custom("AvenirNext-Regular", size: 30))
//                                    .padding()
//                                    .background(Color.green)
//                                    .foregroundColor(.white)
//                                    .cornerRadius(10)
//                            }
//                        } else {
//                            VStack {
//                                ProgressView(value: Double(currentQuestionIndex + 1), total: Double(numberOfQuestionsToAsk)){
//                                    Text("Question #\(currentQuestionIndex + 1)")
//                                }
//                                .progressViewStyle(LinearProgressViewStyle(tint: .green))
//                                .padding()
//
//                                ProgressView(value: Double(totalTime - timeRemaining) / Double(totalTime)){
//                                    Text("Time Remaining")
//                                } currentValueLabel: {
//                                    Text("\(timeRemaining)s")
//                                        .font(.custom("AvenirNext-Regular", size: 20))
//
//                                }
//                                .progressViewStyle(LinearProgressViewStyle(tint: .red))
//                                .padding()
//                            }
//                            .padding(.horizontal)
//                            .font(.custom("AvenirNext-Regular", size: 22))
//                            .bold()
//                            .foregroundColor(.white)
//
//                            Spacer()
//
//                            if currentQuestionIndex < selectedQuestions.count {
//                                Text(selectedQuestions[currentQuestionIndex].question)
//                                    .font(.custom("AvenirNext-Regular", size: 30))
//                                    .multilineTextAlignment(.center)
//                                    .foregroundColor(.white)
//                                    .padding(50)
//
//                                ForEach(selectedQuestions[currentQuestionIndex].options, id: \.self) { option in
//                                    Button(action: {
//                                        let HapticTouch = UIImpactFeedbackGenerator(style: .medium)
//                                        HapticTouch.impactOccurred()
//                                        answerSelected(option)
//                                    }) {
//                                        Text(option)
//                                            .font(.custom("AvenirNext-Regular", size: 28))
//                                            .frame(width: 250, height: 40)
//                                            .padding()
//                                            .background(selectedAnswer == option ? Color.blue : Color.gray.opacity(0.2))
//                                            .foregroundColor(.white)
//                                            .cornerRadius(25)
//                                    }
//                                    .padding(.vertical, 15)
//                                }
//
//                            }
//                            Spacer()
//                        }
//                    }
//
//                    .onAppear {
//                        resetQuiz()
//                    }
//
//                    .onDisappear {
//                        stopTimer()
//                    }
//                }
//            }
//        }
//    }
//
//    private func answerSelected(_ answer: String) {
//        stopTimer() // stop the timer when an answer is selected
//        selectedAnswer = answer
//        if answer == selectedQuestions[currentQuestionIndex].correctAnswer {
//            score += 1
//        }
//        moveToNextQuestion()
//    }
//
//    private func moveToNextQuestion() {
//        if currentQuestionIndex < selectedQuestions.count - 1 {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                currentQuestionIndex += 1
//                selectedAnswer = ""
//                setTimer() // restart the timer for the next question
//            }
//        } else {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                showResult = true
//                stopTimer() // stop the timer when the quiz is end
//                saveHighScore()
//            }
//        }
//    }
//
//    private func setTimer() {
//        timeRemaining = 10 // reset the timeRemaining for each question
//        timer?.invalidate() // Stop any existing timer
//        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
//            if timeRemaining > 0 {
//                timeRemaining -= 1
//            } else {
//                timer?.invalidate()
//                if selectedAnswer.isEmpty { // Only move to next question if no answer was selected
//                    moveToNextQuestion()
//                }
//            }
//
//        }
//    }
//
//    private func stopTimer() {
//        timer?.invalidate()
//    }
//
//    private func resetQuiz() {
//        currentQuestionIndex = 0
//        score = 0
//        showResult = false
//        selectedAnswer = ""
//        timeRemaining = 10
//        selectedQuestions = questions.shuffled().prefix(numberOfQuestionsToAsk).map { $0 }
//        setTimer() // Start the timer at the beginning of the quiz
//    }
//
//    private func saveHighScore() {
//        if score > highScore {
//            UserDefaults.standard.set(score, forKey: "HighScore")
//            highScore = score
//        }
//    }
//}
//
//#Preview {
//    QuizView()
//}
