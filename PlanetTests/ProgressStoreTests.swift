//
//  ProgressStoreTests.swift
//  PlanetTests
//

import Foundation
import Testing
@testable import Planet

@Suite("Progress store")
struct ProgressStoreTests {
    @Test func keepsTheBestStars() {
        let store = ProgressStore(defaults: scratchDefaults())
        #expect(store.recordStars(2, for: "first-flight"))
        #expect(!store.recordStars(1, for: "first-flight"))
        #expect(store.stars(for: "first-flight") == 2)
        #expect(store.recordStars(3, for: "first-flight"))
        #expect(store.campaignStars == 3)
    }

    @Test func progressSurvivesARelaunch() {
        let defaults = scratchDefaults()
        let store = ProgressStore(defaults: defaults)
        store.recordStars(3, for: "morning-star")
        store.recordVisit(to: "Venus", on: day(2026, 3, 1))
        store.spacecraftName = "Comet"
        store.spacecraftColor = 2
        store.crew = [CrewMember(name: "Sara", age: 12)]
        store.recordQuizScore(8)

        let relaunched = ProgressStore(defaults: defaults)
        #expect(relaunched.stars(for: "morning-star") == 3)
        #expect(relaunched.firstVisit(to: "Venus") == day(2026, 3, 1))
        #expect(relaunched.spacecraftName == "Comet")
        #expect(relaunched.spacecraftColor == 2)
        #expect(relaunched.crew.map(\.name) == ["Sara"])
        #expect(relaunched.quizHighScore == 8)
    }

    /// Saved data from before the store existed must still load.
    @Test func readsTheOldAppStorageFormat() throws {
        let defaults = scratchDefaults()
        defaults.set(#"{"first-flight":2,"daily-2026-11-01":1}"#, forKey: "missionChallengeStars")
        defaults.set(#"{"Mars":1767225600}"#, forKey: "missionPassport")
        let crew = try JSONEncoder().encode([CrewMember(name: "Ali", age: 40)])
        defaults.set(String(data: crew, encoding: .utf8), forKey: "spacecraftCrew")
        defaults.set("Voyager", forKey: "spacecraftName")
        defaults.set(7, forKey: "HighScore")

        let store = ProgressStore(defaults: defaults)
        #expect(store.stars(for: "first-flight") == 2)
        #expect(store.stars(for: "daily-2026-11-01") == 1)
        #expect(store.firstVisit(to: "Mars") == Date(timeIntervalSince1970: 1_767_225_600))
        #expect(store.crew.first?.name == "Ali")
        #expect(store.spacecraftDisplayName == "Voyager")
        #expect(store.quizHighScore == 7)
    }

    @Test func onlyTheFirstVisitIsStamped() {
        let store = ProgressStore(defaults: scratchDefaults())
        store.recordVisit(to: "Mars", on: day(2026, 1, 1))
        store.recordVisit(to: "Mars", on: day(2027, 1, 1))
        #expect(store.firstVisit(to: "Mars") == day(2026, 1, 1))
    }

    @Test func aStarCountsAsAVisitWithoutADate() {
        let store = ProgressStore(defaults: scratchDefaults())
        #expect(!store.hasVisited("Mars"))
        store.recordStars(1, for: "first-flight")   // Earth → Mars
        #expect(store.hasVisited("Mars"))
        #expect(store.firstVisit(to: "Mars") == nil)
        #expect(store.visitedPlanetCount == 1)
    }

    @Test func quizHighScoreOnlyGoesUpUntilReset() {
        let store = ProgressStore(defaults: scratchDefaults())
        #expect(store.recordQuizScore(6))
        #expect(!store.recordQuizScore(4))
        #expect(store.quizHighScore == 6)
        store.resetQuizHighScore()
        #expect(store.quizHighScore == 0)
    }

    @Test func blankSpacecraftNameFallsBackToTheDefault() {
        let store = ProgressStore(defaults: scratchDefaults())
        store.spacecraftName = "   "
        #expect(!store.spacecraftDisplayName.trimmingCharacters(in: .whitespaces).isEmpty)
    }
}
