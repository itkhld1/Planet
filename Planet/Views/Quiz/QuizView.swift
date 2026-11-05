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

    /// The same question with its options in a random order. Most answers in
    /// the bank are written first, so without this the right answer would
    /// nearly always be A.
    func withShuffledOptions() -> QuizQuestion {
        let order = options.indices.shuffled()
        return QuizQuestion(question: question,
                            options: order.map { options[$0] },
                            correctIndex: order.firstIndex(of: correctIndex) ?? 0,
                            explanation: explanation)
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
    /// Per question: true right, false wrong or timed out, nil not yet answered.
    @State private var outcomes: [Bool?] = []
    @State private var streak = 0
    @State private var bestStreak = 0
    @State private var timedOut = false
    /// Bumped on a wrong answer, to shake that option.
    @State private var shakeTrigger: CGFloat = 0

    // The question timer runs on a deadline, so the ring can drain smoothly
    // and freeze exactly where it was when the answer came in.
    @State private var deadline: Date?
    @State private var stoppedAt: Date?
    @State private var timeoutTask: Task<Void, Never>?

    @State private var countdownTimer: Timer?
    @State private var countdownValue = 4
    private var highScore: Int { ProgressStore.shared.quizHighScore }
    @State private var isNewHighScore = false
    @State private var missedQuestions: [MissedQuestion] = []
    @State private var resultAppeared = false
    @State private var confettiStart: Date?

    @Environment(\.requestReview) private var requestReview
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    let totalTime = 10
    private let numberOfQuestionsToAsk = 10
    private var isPhone: Bool { deviceType() == "iPhone" }

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
            AppGradientBackground(stars: 40)

            if countdownValue > 0 {
                CountdownView(countdownValue: $countdownValue, deviceType: deviceType())
            } else if showResult {
                ScrollView {
                    resultView
                        .padding(.bottom, 30)
                }
                .scrollIndicators(.hidden)
            } else {
                questionScreen
            }

            if let confettiStart {
                ConfettiView(start: confettiStart)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
        .onAppear(perform: resetQuiz)
        .onDisappear {
            stopTimer()
            countdownTimer?.invalidate()
        }
    }

    // MARK: - Question screen

    private var questionScreen: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 20)
                .padding(.top, 8)

            ScrollView(showsIndicators: false) {
                VStack(spacing: isPhone ? 14 : 20) {
                    if let currentQuestion {
                        // Each question slides in as the last one slides out.
                        VStack(spacing: isPhone ? 12 : 18) {
                            Text(currentQuestion.question)
                                .font(AppFont.bold(isPhone ? 22 : 32))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, isPhone ? 14 : 22)
                                .fixedSize(horizontal: false, vertical: true)

                            ForEach(Array(currentQuestion.options.enumerated()), id: \.offset) { index, option in
                                optionButton(option, index: index, question: currentQuestion)
                            }
                        }
                        .id(currentQuestionIndex)
                        .transition(reduceMotion ? .opacity : .asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)))
                    }

                    feedbackView
                    nextButton
                }
                .padding(.horizontal, isPhone ? 24 : 0)
                .frame(maxWidth: isPhone ? .infinity : 560)
                .frame(maxWidth: .infinity)
                .padding(.bottom, 24)
            }
            .scrollBounceBehavior(.basedOnSize)
        }
    }

    // MARK: Header

    private var header: some View {
        HStack(alignment: .center, spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Question \(currentQuestionIndex + 1) of \(numberOfQuestionsToAsk)")
                    .font(AppFont.bold(isPhone ? 14 : 20))
                    .foregroundColor(Palette.secondaryText)

                progressDots

                if streak >= 2 {
                    Text("🔥 \(streak) in a row")
                        .font(AppFont.bold(isPhone ? 12 : 17))
                        .foregroundColor(Palette.amber)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 10)
                        .background(Palette.amber.opacity(0.15), in: Capsule())
                        .transition(.scale.combined(with: .opacity))
                        .id(streak)
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: streak)

            Spacer(minLength: 0)

            timerRing
        }
    }

    /// One dot per question: green right, red wrong, outlined for the current one.
    private var progressDots: some View {
        HStack(spacing: 5) {
            ForEach(0..<numberOfQuestionsToAsk, id: \.self) { index in
                let outcome = outcomes.indices.contains(index) ? outcomes[index] : nil
                let isCurrent = index == currentQuestionIndex
                Capsule()
                    .fill(outcome.map { $0 ? Palette.success : Color.red } ?? Color.white.opacity(isCurrent ? 0.5 : 0.18))
                    .frame(width: isCurrent ? 22 : 14, height: 6)
                    .animation(.spring(response: 0.35, dampingFraction: 0.7), value: outcome)
                    .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isCurrent)
            }
        }
        .accessibilityElement()
        .accessibilityLabel(Text("Score: \(score) of \(numberOfQuestionsToAsk)"))
    }

    private var isTimerRunning: Bool { deadline != nil && stoppedAt == nil }

    /// Drains smoothly; turns red for the last three seconds.
    private var timerRing: some View {
        let size: CGFloat = isPhone ? 52 : 70
        return TimelineView(.animation(minimumInterval: 1.0 / 30, paused: !isTimerRunning)) { context in
            let remaining = remainingTime(at: context.date)
            let fraction = remaining / Double(totalTime)
            let urgent = remaining <= 3 && !isAnswerRevealed
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.15), lineWidth: 5)
                Circle()
                    .trim(from: 0, to: fraction)
                    .stroke(urgent ? Color.red : Palette.accent, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text(MetricFormat.grouped(ceil(remaining)))
                    .font(AppFont.bold(isPhone ? 17 : 24))
                    .monospacedDigit()
                    .foregroundColor(urgent ? .red : .white)
            }
            .frame(width: size, height: size)
            .scaleEffect(urgent && !reduceMotion ? 1 + 0.06 * sin(context.date.timeIntervalSinceReferenceDate * 2 * .pi) : 1)
        }
        .accessibilityElement()
        .accessibilityLabel("Time Remaining")
        .accessibilityValue(Text("\(Int(ceil(remainingTime(at: Date())))) s"))
    }

    /// Seconds left: counting down, or frozen at the moment of answering.
    private func remainingTime(at now: Date) -> Double {
        guard let deadline else { return Double(totalTime) }
        return max(0, deadline.timeIntervalSince(stoppedAt ?? now))
    }

    // MARK: Options

    private enum OptionState { case idle, correct, wrong, dimmed }

    private func optionState(_ option: String, question: QuizQuestion) -> OptionState {
        guard isAnswerRevealed else { return .idle }
        if option == question.correctAnswer { return .correct }
        if option == selectedAnswer { return .wrong }
        return .dimmed
    }

    private static let letterKeys: [String.LocalizationValue] = ["A", "B", "C", "D", "E", "F"]

    private func letter(_ index: Int) -> String {
        Self.letterKeys.indices.contains(index)
            ? String(localized: Self.letterKeys[index], bundle: Bundle.appLanguage)
            : "\(index + 1)"
    }

    private func optionButton(_ option: String, index: Int, question: QuizQuestion) -> some View {
        let state = optionState(option, question: question)
        let tint: Color? = switch state {
        case .correct: Palette.success
        case .wrong: .red
        default: nil
        }

        return Button { answerSelected(option) } label: {
            HStack(spacing: 12) {
                Text(letter(index))
                    .font(AppFont.bold(isPhone ? 15 : 20))
                    .foregroundColor(tint == nil ? .white : Palette.deepSpace)
                    .frame(width: isPhone ? 30 : 40, height: isPhone ? 30 : 40)
                    .background(Circle().fill(tint ?? Color.white.opacity(0.14)))

                Text(option)
                    .font(AppFont.regular(isPhone ? 17 : 26))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 0)

                if state == .correct {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Palette.success)
                        .transition(.scale.combined(with: .opacity))
                } else if state == .wrong {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .font(.system(size: isPhone ? 20 : 26))
            .padding(.vertical, isPhone ? 12 : 16)
            .padding(.horizontal, 14)
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 18).fill(tint?.opacity(0.25) ?? Palette.card))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(tint ?? Palette.cardStroke, lineWidth: tint == nil ? 1 : 2))
            .contentShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(QuizOptionStyle())
        .scaleEffect(state == .correct ? 1.03 : 1)
        .modifier(Shake(animatableData: state == .wrong ? shakeTrigger : 0))
        .opacity(state == .dimmed ? 0.5 : 1)
        .animation(.spring(response: 0.35, dampingFraction: 0.6), value: isAnswerRevealed)
        .disabled(isAnswerRevealed)
        .accessibilityLabel(Text("\(letter(index)), \(option)"))
    }

    // MARK: Feedback

    /// Right, wrong or out of time, and the reason the right answer is right.
    @ViewBuilder
    private var feedbackView: some View {
        if isAnswerRevealed, let question = currentQuestion {
            let correct = selectedAnswer == question.correctAnswer
            VStack(alignment: .leading, spacing: 10) {
                Label(correct ? "Correct!" : (timedOut ? "Time's up!" : "Not quite"),
                      systemImage: correct ? "checkmark.seal.fill" : (timedOut ? "hourglass" : "xmark.octagon.fill"))
                    .font(AppFont.bold(isPhone ? 16 : 22))
                    .foregroundColor(correct ? Palette.success : (timedOut ? Palette.warning : .red))

                if !question.explanation.isEmpty {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(Palette.amber)
                        Text(question.explanation)
                            .font(AppFont.regular(isPhone ? 14 : 20))
                            .foregroundColor(.white)
                            .lineSpacing(3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .appCard(cornerRadius: 16)
            .transition(.opacity.combined(with: .move(edge: .bottom)))
            .accessibilityElement(children: .combine)
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
                    .font(AppFont.bold(isPhone ? 17 : 24))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(Palette.accent)
                    .foregroundColor(Palette.deepSpace)
                    .cornerRadius(25)
            }
            .transition(.opacity)
        }
    }

    // MARK: - Result

    private var percent: Int {
        numberOfQuestionsToAsk == 0 ? 0 : Int((Double(score) / Double(numberOfQuestionsToAsk)) * 100)
    }

    /// One star from 40%, two from 70%, three from 90%.
    private var stars: Int {
        switch percent {
        case 90...: return 3
        case 70..<90: return 2
        case 40..<70: return 1
        default: return 0
        }
    }

    var resultView: some View {
        VStack(spacing: 14) {
            scoreRing
                .padding(.top, 10)

            HStack(spacing: 10) {
                ForEach(0..<3, id: \.self) { index in
                    let lit = index < stars
                    Image(systemName: "star.fill")
                        .font(.system(size: isPhone ? 30 : 42))
                        .foregroundColor(lit ? Palette.amber : .white.opacity(0.2))
                        .shadow(color: lit ? Palette.amber.opacity(0.6) : .clear, radius: 8)
                        .scaleEffect(resultAppeared || reduceMotion ? 1 : 0.2)
                        .opacity(resultAppeared || reduceMotion ? 1 : 0)
                        .animation(.spring(response: 0.45, dampingFraction: 0.55).delay(0.9 + 0.18 * Double(index)),
                                   value: resultAppeared)
                }
            }
            .accessibilityElement()
            .accessibilityLabel(Text("\(stars) of 3 stars"))

            Text(resultMessage(percent))
                .foregroundColor(.white.opacity(0.9))
                .font(AppFont.regular(isPhone ? 17 : 26))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)

            HStack(spacing: 12) {
                statChip(icon: "trophy.fill",
                         text: isNewHighScore ? Text("New High Score!") : Text("High Score: \(highScore)"))
                if bestStreak >= 2 {
                    statChip(icon: "flame.fill", text: Text("Best streak: \(bestStreak)"))
                }
            }

            Button(action: restartQuiz) {
                Text("Try Again")
                    .font(AppFont.bold(isPhone ? 18 : 28))
                    .frame(maxWidth: isPhone ? .infinity : 360)
                    .padding(.vertical, 15)
                    .background(Palette.accent)
                    .foregroundColor(Palette.deepSpace)
                    .cornerRadius(25)
            }
            .padding(.top, 8)
            .padding(.horizontal, 30)

            reviewSection
        }
        .padding()
        .onAppear {
            resultAppeared = true
            if percent >= 80 && !reduceMotion {
                confettiStart = Date()
            }
        }
    }

    /// The score as a ring that fills up when the results appear.
    private var scoreRing: some View {
        let size: CGFloat = isPhone ? 170 : 230
        let fraction = Double(score) / Double(max(numberOfQuestionsToAsk, 1))
        return ZStack {
            Circle()
                .stroke(Color.white.opacity(0.12), lineWidth: 12)
            Circle()
                .trim(from: 0, to: resultAppeared || reduceMotion ? fraction : 0)
                .stroke(AngularGradient(colors: [Palette.accent, Palette.success, Palette.accent], center: .center),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 1.1).delay(0.2), value: resultAppeared)
            VStack(spacing: 2) {
                Text("\(score) / \(numberOfQuestionsToAsk)")
                    .font(AppFont.bold(isPhone ? 38 : 52))
                    .foregroundColor(.white)
                Text("Quiz Finished!")
                    .font(AppFont.regular(isPhone ? 13 : 18))
                    .foregroundColor(Palette.secondaryText)
            }
        }
        .frame(width: size, height: size)
        .accessibilityElement(children: .combine)
    }

    private func statChip(icon: String, text: Text) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
            text
        }
        .font(AppFont.bold(isPhone ? 14 : 19))
        .foregroundColor(Palette.amber)
        .padding(.vertical, 7)
        .padding(.horizontal, 12)
        .background(Palette.amber.opacity(0.14), in: Capsule())
    }

    /// Lets the player see what they missed, and why, rather than just a score.
    @ViewBuilder
    private var reviewSection: some View {
        if !missedQuestions.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Review")
                    .font(AppFont.bold(isPhone ? 20 : 28))
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
                .font(AppFont.bold(isPhone ? 15 : 21))
                .foregroundColor(.white)

            // `givenAnswer` is already in the quiz's language; only the
            // fallback is ours to look up.
            Label(missed.givenAnswer ?? String(localized: "Ran out of time", bundle: Bundle.appLanguage),
                  systemImage: "xmark.circle.fill")
                .font(AppFont.regular(isPhone ? 14 : 19))
                .foregroundColor(.red)

            Label(missed.question.correctAnswer, systemImage: "checkmark.circle.fill")
                .font(AppFont.regular(isPhone ? 14 : 19))
                .foregroundColor(Palette.success)

            if !missed.question.explanation.isEmpty {
                Text(missed.question.explanation)
                    .font(AppFont.regular(isPhone ? 13 : 18))
                    .foregroundColor(Palette.secondaryText)
                    .lineSpacing(3)
                    .padding(.top, 2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .appCard(cornerRadius: 16)
        .accessibilityElement(children: .combine)
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

    // MARK: - Answer flow

    private func answerSelected(_ answer: String) {
        guard !isAnswerRevealed, let question = currentQuestion else { return }
        stopTimer()
        selectedAnswer = answer
        timedOut = false
        let correct = answer == question.correctAnswer
        record(correct: correct)
        if correct {
            playNotificationHaptic(.success)
        } else {
            playNotificationHaptic(.error)
            recordMiss(given: answer)
        }
        reveal(correct: correct)
    }

    /// Called when the timer runs out with no selection.
    private func handleTimeout() {
        guard !isAnswerRevealed else { return }
        playNotificationHaptic(.warning)
        stopTimer()
        timedOut = true
        record(correct: false)
        recordMiss(given: nil)
        reveal(correct: false)
    }

    private func record(correct: Bool) {
        if outcomes.indices.contains(currentQuestionIndex) {
            outcomes[currentQuestionIndex] = correct
        }
        if correct {
            score += 1
            streak += 1
            bestStreak = max(bestStreak, streak)
        } else {
            streak = 0
        }
    }

    private func recordMiss(given: String?) {
        guard let currentQuestion else { return }
        missedQuestions.append(MissedQuestion(question: currentQuestion, givenAnswer: given))
    }

    /// Reveal the correct answer and its explanation, then wait for the player
    /// to tap Next — auto-advancing would cut the explanation off mid-sentence.
    private func reveal(correct: Bool) {
        withAnimation { isAnswerRevealed = true }
        if !correct && !timedOut && !reduceMotion {
            withAnimation(.linear(duration: 0.45)) { shakeTrigger += 1 }
        }
        let message = correct
            ? String(localized: "Correct!", bundle: Bundle.appLanguage)
            : String(localized: "Not quite", bundle: Bundle.appLanguage)
        AccessibilityNotification.Announcement(message).post()
    }

    private func advanceToNext() {
        if currentQuestionIndex < selectedQuestions.count - 1 {
            withAnimation(.easeInOut(duration: 0.35)) {
                currentQuestionIndex += 1
                selectedAnswer = ""
                isAnswerRevealed = false
                timedOut = false
            }
            startTimer()
        } else {
            stopTimer()
            withAnimation { showResult = true }
            saveHighScore()
            askForReviewIfDeserved()
        }
    }

    // MARK: - Timer

    private func startTimer() {
        timeoutTask?.cancel()
        deadline = Date().addingTimeInterval(Double(totalTime))
        stoppedAt = nil
        let total = totalTime
        timeoutTask = Task {
            // A light tick for each of the last three seconds.
            try? await Task.sleep(for: .seconds(total - 3))
            for _ in 0..<3 {
                guard !Task.isCancelled else { return }
                playHaptic(.light)
                try? await Task.sleep(for: .seconds(1))
            }
            guard !Task.isCancelled else { return }
            handleTimeout()
        }
    }

    private func stopTimer() {
        timeoutTask?.cancel()
        timeoutTask = nil
        if deadline != nil && stoppedAt == nil {
            stoppedAt = Date()
        }
    }

    // MARK: - Lifecycle

    private func restartQuiz() {
        playHaptic()
        resetQuiz()
    }

    private func resetQuiz() {
        stopTimer()
        currentQuestionIndex = 0
        score = 0
        streak = 0
        bestStreak = 0
        showResult = false
        resultAppeared = false
        confettiStart = nil
        selectedAnswer = ""
        isAnswerRevealed = false
        timedOut = false
        isNewHighScore = false
        missedQuestions.removeAll()
        deadline = nil
        stoppedAt = nil
        selectedQuestions = questions.shuffled().prefix(numberOfQuestionsToAsk).map { $0.withShuffledOptions() }
        outcomes = Array(repeating: nil, count: selectedQuestions.count)

        countdownValue = 4
        countdownTimer?.invalidate()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if countdownValue > 0 {
                countdownValue -= 1
            } else {
                countdownTimer?.invalidate()
                startTimer()
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
        if ProgressStore.shared.recordQuizScore(score) {
            isNewHighScore = true
        }
    }
}

/// Answer buttons dip slightly while pressed.
private struct QuizOptionStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

/// A horizontal shake, three times back and forth per step of `animatableData`.
private struct Shake: GeometryEffect {
    var amount: CGFloat = 8
    var shakesPerUnit: CGFloat = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: amount * sin(animatableData * .pi * 2 * shakesPerUnit), y: 0))
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
