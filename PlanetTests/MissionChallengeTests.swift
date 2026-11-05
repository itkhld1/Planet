//
//  MissionChallengeTests.swift
//  PlanetTests
//
//  The challenge header promises every challenge can earn three stars and
//  always has a launch window on the slider. These tests hold it to that.
//

import Foundation
import Testing
@testable import Planet

@Suite("Mission Control challenges")
struct MissionChallengeTests {
    /// Same arithmetic as the play screen's launch-day slider.
    private func launchDate(_ firstDay: Date, _ launchDay: Double) -> Date {
        firstDay.addingTimeInterval(launchDay.rounded() * 86_400 + 12 * 3_600)
    }

    private let firstDay = Calendar.current.startOfDay(for: day(2026, 11, 5))

    @Test func idsAreUnique() {
        let ids = MissionChallenge.all.map(\.id)
        #expect(Set(ids).count == ids.count)
    }

    @Test(arguments: MissionChallenge.all.map(\.id))
    func everyChallengeCanEarnThreeStars(id: String) throws {
        let challenge = try #require(MissionChallenge.all.first { $0.id == id })

        // A route speed that meets both the fuel budget and the deadline…
        let speeds = stride(from: 0.0, through: 1.0, by: 0.01).compactMap { speed -> TransferOrbit? in
            guard let t = challenge.transfer(speed: speed) else { return nil }
            return t.totalDeltaV <= challenge.fuelBudget && t.travelDays <= challenge.deadlineDays ? t : nil
        }
        let transfer = try #require(speeds.first, "No route speed meets fuel and time for \(id)")

        // …and a launch day on the slider that hits the planet with it.
        let perfect = stride(from: 0.0, through: challenge.lastLaunchDay, by: 1).contains { launchDay in
            challenge.attempt(transfer: transfer, launchDate: launchDate(firstDay, launchDay),
                              launchDay: launchDay).stars == 3
        }
        #expect(perfect, "No launch day earns three stars for \(id)")
    }

    @Test(arguments: MissionChallenge.all.map(\.id))
    func suggestedShiftTurnsAMissIntoAHit(id: String) throws {
        let challenge = try #require(MissionChallenge.all.first { $0.id == id })
        let transfer = try #require(challenge.transfer(speed: 0))

        // Find a missed launch, then follow the hint.
        var launchDay = 0.0
        var attempt = challenge.attempt(transfer: transfer, launchDate: launchDate(firstDay, launchDay), launchDay: launchDay)
        while attempt.hit && launchDay < challenge.lastLaunchDay {
            launchDay += 7
            attempt = challenge.attempt(transfer: transfer, launchDate: launchDate(firstDay, launchDay), launchDay: launchDay)
        }
        try #require(!attempt.hit)
        let shift = try #require(attempt.shiftDays)

        let retryDay = launchDay + Double(shift)
        #expect((0...challenge.lastLaunchDay).contains(retryDay), "The hint must stay on the slider")
        let retry = challenge.attempt(transfer: transfer, launchDate: launchDate(firstDay, retryDay), launchDay: retryDay)
        #expect(retry.hit)
    }

    @Test func starsNeedAHit() {
        let miss = MissionChallenge.Attempt(hit: false, bullseye: false, missKm: 1, shiftDays: 3, fuelOK: true, timeOK: true)
        let hit = MissionChallenge.Attempt(hit: true, bullseye: false, missKm: 0, shiftDays: nil, fuelOK: true, timeOK: false)
        #expect(miss.stars == 0)
        #expect(hit.stars == 2)
    }

    @Test func eachChallengeUnlocksTheNext() {
        let first = MissionChallenge.all[0].id
        #expect(MissionChallenge.isUnlocked(0, stars: [:]))
        #expect(!MissionChallenge.isUnlocked(1, stars: [:]))
        #expect(MissionChallenge.isUnlocked(1, stars: [first: 1]))
        #expect(!MissionChallenge.isUnlocked(2, stars: [first: 3]))
    }
}
