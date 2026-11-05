//
//  ReviewPromptTests.swift
//  PlanetTests
//

import Foundation
import Testing
@testable import Planet

@Suite("Review prompt rules")
struct ReviewPromptTests {
    @Test func needsTwoLaunchDaysAndAGoodScore() {
        let defaults = scratchDefaults()
        ReviewPrompt.recordLaunch(on: day(2026, 11, 1), defaults: defaults)
        ReviewPrompt.recordLaunch(on: day(2026, 11, 1), defaults: defaults)   // same day counts once
        #expect(!ReviewPrompt.shouldAsk(afterScore: 10, outOf: 10, defaults: defaults, version: "2.0.0"))

        ReviewPrompt.recordLaunch(on: day(2026, 11, 2), defaults: defaults)
        #expect(!ReviewPrompt.shouldAsk(afterScore: 6, outOf: 10, defaults: defaults, version: "2.0.0"))
        #expect(ReviewPrompt.shouldAsk(afterScore: 7, outOf: 10, defaults: defaults, version: "2.0.0"))
    }

    @Test func asksOncePerVersion() {
        let defaults = scratchDefaults()
        ReviewPrompt.recordLaunch(on: day(2026, 11, 1), defaults: defaults)
        ReviewPrompt.recordLaunch(on: day(2026, 11, 2), defaults: defaults)
        #expect(ReviewPrompt.shouldAsk(afterScore: 9, outOf: 10, defaults: defaults, version: "2.0.0"))
        #expect(!ReviewPrompt.shouldAsk(afterScore: 10, outOf: 10, defaults: defaults, version: "2.0.0"))
        #expect(ReviewPrompt.shouldAsk(afterScore: 10, outOf: 10, defaults: defaults, version: "2.1.0"))
    }

    @Test func asksAfterEnoughPlanetVisits() {
        let defaults = scratchDefaults()
        for _ in 1..<ReviewPrompt.interactionsBeforeAsking {
            ReviewPrompt.recordInteraction(defaults: defaults)
        }
        #expect(!ReviewPrompt.shouldAskAfterInteractions(defaults: defaults, version: "2.0.0"))
        ReviewPrompt.recordInteraction(defaults: defaults)
        #expect(ReviewPrompt.shouldAskAfterInteractions(defaults: defaults, version: "2.0.0"))
    }

    @Test func emptyRoundNeverAsks() {
        let defaults = scratchDefaults()
        ReviewPrompt.recordLaunch(on: day(2026, 11, 1), defaults: defaults)
        ReviewPrompt.recordLaunch(on: day(2026, 11, 2), defaults: defaults)
        #expect(!ReviewPrompt.shouldAsk(afterScore: 0, outOf: 0, defaults: defaults, version: "2.0.0"))
    }
}
