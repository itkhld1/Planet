//
//  QuizBankTests.swift
//  PlanetTests
//
//  The Persian bank must line up with the English one question for question,
//  or a translated round would mark right answers wrong.
//

import Foundation
import Testing
@testable import Planet

@Suite("Quiz question banks")
struct QuizBankTests {
    @Test func banksHaveTheAdvertisedSize() {
        // The App Store description and onboarding promise 200 questions
        // ("over 200"), so the bank must never drop below that.
        #expect(questionsEn.count >= 200)
        #expect(questionsFa.count == questionsEn.count)
    }

    @Test(arguments: [("en", questionsEn), ("fa", questionsFa)])
    func everyQuestionIsAnswerable(language: String, bank: [QuizQuestion]) {
        for (i, q) in bank.enumerated() {
            #expect(q.options.count >= 2, "\(language) #\(i) has too few options")
            #expect(Set(q.options).count == q.options.count, "\(language) #\(i) repeats an option")
            #expect(q.options.indices.contains(q.correctIndex), "\(language) #\(i) has no correct option")
            #expect(!q.explanation.isEmpty, "\(language) #\(i) has no explanation")
        }
    }

    @Test func persianAnswersMatchEnglish() {
        for (i, (en, fa)) in zip(questionsEn, questionsFa).enumerated() {
            #expect(en.correctIndex == fa.correctIndex, "Question #\(i) answer differs")
            #expect(en.options.count == fa.options.count, "Question #\(i) option count differs")
        }
    }
}
