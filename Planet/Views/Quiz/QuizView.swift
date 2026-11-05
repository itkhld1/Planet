//
//  QuizView.swift
//  Planet
//
//  Created by itkhld on 2024-09-30.
//

import SwiftUI
import StoreKit

struct QuizQuestion: Identifiable {
    let id = UUID()
    let question: String
    let options: [String]
    /// Index into `options`, not the answer text.
    ///
    /// Matching the answer by string used to mean a translator rendering
    /// "Mercury" differently in `options` than in the answer would silently
    /// leave the question with no correct choice. An index can't drift.
    let correctIndex: Int
    /// One-line reason the answer is right, shown when the answer is revealed.
    var explanation: String = ""

    var correctAnswer: String {
        options.indices.contains(correctIndex) ? options[correctIndex] : ""
    }
}

/// A question the player got wrong, kept for the end-of-quiz review.
struct MissedQuestion: Identifiable {
    let id = UUID()
    let question: QuizQuestion
    /// What the player picked, or nil if they ran out of time.
    let givenAnswer: String?
}

struct QuizView: View {
    @State private var currentQuestionIndex = 0
    @State private var score = 0
    @State private var showResult = false
    @State private var selectedAnswer = ""
    @State private var isAnswerRevealed = false
    @State private var selectedQuestions: [QuizQuestion] = []
    @State private var timeRemaining = 10
    @State private var timer: Timer?
    @State private var countdownTimer: Timer?
    @State private var countdownValue = 4
    @AppStorage(SettingsKey.highScore) private var highScore = 0
    @State private var isNewHighScore = false
    @State private var missedQuestions: [MissedQuestion] = []
    @Environment(\.requestReview) private var requestReview
    let totalTime = 10
    private let numberOfQuestionsToAsk = 10

    private var currentQuestion: QuizQuestion? {
        guard currentQuestionIndex < selectedQuestions.count else { return nil }
        return selectedQuestions[currentQuestionIndex]
    }

    /// Pushed onto Explore's stack, so it brings no NavigationStack of its own.
    var body: some View {
        mainContent
            .appNavigationStyle("Quiz")
    }

    var mainContent: some View {
        ZStack {
            // Static full-screen gradient (no color-array swap, so it can't
            // "wipe in" from a corner and there's no repeating animation to
            // accumulate across tab switches).
            LinearGradient(
                gradient: Gradient(colors: [Color("Q1"), Color("Q2"), Color("Q3"), Color("Q4"), Color("Q5")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            StarFieldView(count: 40)

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
                ScrollView {
                    resultView
                        .padding(.bottom, 30)
                }
                .scrollIndicators(.hidden)
            } else {
                VStack {
                    progressViews
                    Spacer()
                    questionView
                    optionsView
                    explanationView
                    nextButton
                    Spacer()
                }
            }
        }
    }

    // MARK: - Result

    var resultView: some View {
        let percent = numberOfQuestionsToAsk == 0 ? 0 : Int((Double(score) / Double(numberOfQuestionsToAsk)) * 100)
        return VStack(spacing: 14) {
            Text(resultEmoji(percent))
                .font(.system(size: deviceType() == "iPhone" ? 72 : 100))

            Text("Quiz Finished!")
                .font(AppFont.bold(deviceType() == "iPhone" ? 28 : 38))
                .foregroundColor(.white)

            Text("\(score) / \(numberOfQuestionsToAsk)")
                .foregroundColor(.white)
                .font(AppFont.bold(deviceType() == "iPhone" ? 40 : 54))

            Text(resultMessage(percent))
                .foregroundColor(.white.opacity(0.85))
                .font(AppFont.regular(deviceType() == "iPhone" ? 17 : 26))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

            if isNewHighScore {
                Text("🏆 New High Score!")
                    .foregroundColor(.yellow)
                    .font(AppFont.bold(deviceType() == "iPhone" ? 20 : 30))
                    .padding(.top, 4)
            } else {
                Text("High Score: \(highScore)")
                    .foregroundColor(.yellow)
                    .font(AppFont.regular(deviceType() == "iPhone" ? 18 : 28))
                    .padding(.top, 4)
            }

            Button(action: restartQuiz) {
                Text("Try Again")
                    .font(AppFont.bold(deviceType() == "iPhone" ? 20 : 30))
                    .padding(.horizontal, 40)
                    .padding(.vertical, 14)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(25)
            }
            .padding(.top, 12)

            reviewSection
        }
        .padding()
    }

    /// Lets the player see what they missed, and why, rather than just a score.
    @ViewBuilder
    private var reviewSection: some View {
        if !missedQuestions.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Review")
                    .font(AppFont.bold(deviceType() == "iPhone" ? 20 : 28))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 20)

                ForEach(missedQuestions) { missed in
                    reviewCard(missed)
                }
            }
            .frame(maxWidth: 600)
        }
    }

    private func reviewCard(_ missed: MissedQuestion) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(missed.question.question)
                .font(AppFont.bold(deviceType() == "iPhone" ? 15 : 21))
                .foregroundColor(.white)

            // `givenAnswer` is already in the quiz's language; only the
            // fallback is ours to look up.
            Label(missed.givenAnswer ?? String(localized: "Ran out of time", bundle: Bundle.appLanguage),
                  systemImage: "xmark.circle.fill")
                .font(AppFont.regular(deviceType() == "iPhone" ? 14 : 19))
                .foregroundColor(.red)

            Label(missed.question.correctAnswer, systemImage: "checkmark.circle.fill")
                .font(AppFont.regular(deviceType() == "iPhone" ? 14 : 19))
                .foregroundColor(.green)

            if !missed.question.explanation.isEmpty {
                Text(missed.question.explanation)
                    .font(AppFont.regular(deviceType() == "iPhone" ? 13 : 18))
                    .foregroundColor(.white.opacity(0.75))
                    .lineSpacing(3)
                    .padding(.top, 2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.black.opacity(0.35))
        .cornerRadius(16)
        .accessibilityElement(children: .combine)
    }

    private func resultEmoji(_ percent: Int) -> String {
        switch percent {
        case 80...: return "🌟"
        case 50..<80: return "🚀"
        default: return "📚"
        }
    }

    /// Returns a `String` for `Text(...)`, so each message needs looking up —
    /// a bare literal here would render verbatim in English.
    private func resultMessage(_ percent: Int) -> String {
        switch percent {
        case 100: return String(localized: "Perfect! You're a true space explorer.", bundle: Bundle.appLanguage)
        case 80..<100: return String(localized: "Great job! You really know your planets.", bundle: Bundle.appLanguage)
        case 50..<80: return String(localized: "Nice work — keep reaching for the stars.", bundle: Bundle.appLanguage)
        default: return String(localized: "Keep exploring and try again!", bundle: Bundle.appLanguage)
        }
    }

    // MARK: - Quiz content

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
            .progressViewStyle(LinearProgressViewStyle(tint: timeRemaining <= 3 ? .red : .orange))
            .padding()
        }
        .padding(.horizontal)
        .font(AppFont.regular(deviceType() == "iPhone" ? 14 : 22))
        .bold()
        .foregroundColor(.white)
    }

    var questionView: some View {
        Group {
            if let currentQuestion {
                Text(currentQuestion.question)
                    .font(AppFont.bold(deviceType() == "iPhone" ? 22 : 32))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 20)
            }
        }
    }

    var optionsView: some View {
        Group {
            if let currentQuestion {
                VStack(spacing: deviceType() == "iPhone" ? 12 : 18) {
                    ForEach(currentQuestion.options, id: \.self) { option in
                        Button(action: { answerSelected(option) }) {
                            HStack {
                                Text(option)
                                    .font(AppFont.regular(deviceType() == "iPhone" ? 18 : 28))
                                Spacer()
                                if isAnswerRevealed {
                                    if option == currentQuestion.correctAnswer {
                                        Image(systemName: "checkmark.circle.fill")
                                    } else if option == selectedAnswer {
                                        Image(systemName: "xmark.circle.fill")
                                    }
                                }
                            }
                            .padding()
                            .frame(maxWidth: deviceType() == "iPhone" ? .infinity : 500)
                            .background(optionColor(option, correct: currentQuestion.correctAnswer))
                            .foregroundColor(.white)
                            .cornerRadius(25)
                        }
                        .disabled(isAnswerRevealed)
                    }
                }
                .padding(.horizontal, deviceType() == "iPhone" ? 30 : 0)
                .animation(.easeInOut(duration: 0.2), value: isAnswerRevealed)
            }
        }
    }

    @ViewBuilder
    private var nextButton: some View {
        if isAnswerRevealed {
            Button {
                playHaptic()
                advanceToNext()
            } label: {
                Text(currentQuestionIndex == selectedQuestions.count - 1 ? "See Results" : "Next Question")
                    .font(AppFont.bold(deviceType() == "iPhone" ? 17 : 24))
                    .padding(.horizontal, 40)
                    .padding(.vertical, 14)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(25)
            }
            .padding(.top, 16)
            .transition(.opacity)
        }
    }

    /// The teaching moment: why the right answer is right, shown on reveal.
    @ViewBuilder
    private var explanationView: some View {
        if isAnswerRevealed, let explanation = currentQuestion?.explanation, !explanation.isEmpty {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text(explanation)
                    .font(AppFont.regular(deviceType() == "iPhone" ? 14 : 20))
                    .foregroundColor(.white)
                    .lineSpacing(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(14)
            .background(Color.black.opacity(0.35))
            .cornerRadius(16)
            .padding(.horizontal, deviceType() == "iPhone" ? 30 : 0)
            .frame(maxWidth: deviceType() == "iPhone" ? .infinity : 500)
            .padding(.top, 14)
            .transition(.opacity.combined(with: .move(edge: .bottom)))
            .accessibilityElement(children: .combine)
        }
    }

    private func optionColor(_ option: String, correct: String) -> Color {
        guard isAnswerRevealed else {
            return selectedAnswer == option ? Color.blue : Color.white.opacity(0.15)
        }
        if option == correct { return Color.green }
        if option == selectedAnswer { return Color.red }
        return Color.white.opacity(0.15)
    }

    // MARK: - Answer flow

    private func answerSelected(_ answer: String) {
        guard !isAnswerRevealed else { return }
        playHaptic()
        stopTimer()
        selectedAnswer = answer
        if answer == currentQuestion?.correctAnswer {
            score += 1
        } else {
            recordMiss(given: answer)
        }
        reveal()
    }

    /// Called when the timer runs out with no selection.
    private func handleTimeout() {
        guard !isAnswerRevealed else { return }
        playNotificationHaptic(.warning)
        stopTimer()
        recordMiss(given: nil)
        reveal()
    }

    private func recordMiss(given: String?) {
        guard let currentQuestion else { return }
        missedQuestions.append(MissedQuestion(question: currentQuestion, givenAnswer: given))
    }

    /// Reveal the correct answer and its explanation, then wait for the player
    /// to tap Next — auto-advancing would cut the explanation off mid-sentence.
    private func reveal() {
        withAnimation { isAnswerRevealed = true }
    }

    private func advanceToNext() {
        if currentQuestionIndex < selectedQuestions.count - 1 {
            currentQuestionIndex += 1
            selectedAnswer = ""
            isAnswerRevealed = false
            setTimer()
        } else {
            showResult = true
            stopTimer()
            saveHighScore()
            askForReviewIfDeserved()
        }
    }

    // MARK: - Timers

    private func setTimer() {
        timeRemaining = totalTime
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()
                handleTimeout()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
    }

    // MARK: - Lifecycle

    private func restartQuiz() {
        playHaptic()
        resetQuiz()
    }

    private func resetQuiz() {
        currentQuestionIndex = 0
        score = 0
        showResult = false
        selectedAnswer = ""
        isAnswerRevealed = false
        isNewHighScore = false
        missedQuestions.removeAll()
        timeRemaining = totalTime
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

    /// A strong round is the moment someone is happiest with the app, so
    /// that's when to ask — never from a button, and at most once per version.
    private func askForReviewIfDeserved() {
        guard ReviewPrompt.shouldAsk(afterScore: score, outOf: selectedQuestions.count) else { return }
        // Let the results screen land first.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            requestReview()
        }
    }

    private func saveHighScore() {
        if score > highScore {
            highScore = score
            isNewHighScore = true
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
                .font(AppFont.bold(textSize))
                .foregroundColor(.white)
                .bold()
                .scaleEffect(scaleValue)
                .animation(animation, value: countdownValue)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// Built as a `String`, so both halves need explicit work: the phrase has to
    /// be looked up, and `"\(countdownValue)"` would print Western digits — the
    /// countdown should read ۳ ۲ ۱ in Persian.
    private var countdownText: String {
        countdownValue == 4
            ? String(localized: "GET READY", bundle: Bundle.appLanguage)
            : MetricFormat.grouped(Double(countdownValue))
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
    NavigationStack { QuizView() }
}
