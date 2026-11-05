//
//  LaunchWindowTests.swift
//  PlanetTests
//

import Foundation
import Testing
@testable import Planet

@Suite("Launch windows and mission plans")
struct LaunchWindowTests {
    private var hohmann: TransferOrbit {
        TransferOrbit(from: PlanetMetrics.metrics(for: "Earth")!, to: PlanetMetrics.metrics(for: "Mars")!)!
    }

    @Test func earthMarsSynodicPeriodIsAbout26Months() throws {
        let days = try #require(LaunchWindow.synodicDays("Earth", "Mars"))
        #expect((770...790).contains(days))
    }

    @Test func nextEarthMarsWindowIsLate2026() throws {
        // Real window: November 2026. The circular-orbit model lands within weeks.
        let t = hohmann
        let window = try #require(LaunchWindow.next(from: "Earth", to: "Mars", travelDays: t.travelDays,
                                                    sweptAngle: t.sweptAngle, after: day(2026, 1, 1)))
        #expect(window > day(2026, 9, 15))
        #expect(window < day(2027, 1, 15))
    }

    @Test func launchingOnTheWindowHitsTheTarget() throws {
        let t = hohmann
        let window = try #require(LaunchWindow.next(from: "Earth", to: "Mars", travelDays: t.travelDays,
                                                    sweptAngle: t.sweptAngle, after: day(2026, 1, 1)))
        let miss = try #require(LaunchWindow.miss(from: "Earth", to: "Mars", transfer: t, launch: window))
        #expect(abs(miss) < 1e-6)
    }

    @Test func planIsOpenOnTheWindowAndClosedTwoMonthsLater() throws {
        let t = hohmann
        let window = try #require(LaunchWindow.next(from: "Earth", to: "Mars", travelDays: t.travelDays,
                                                    sweptAngle: t.sweptAngle, after: day(2026, 1, 1)))
        let onTime = try #require(MissionPlan(origin: "Earth", target: "Mars", launchDate: window, speed: 0))
        #expect(onTime.windowStatus == .open)
        #expect(onTime.isAligned)

        let late = try #require(MissionPlan(origin: "Earth", target: "Mars",
                                            launchDate: window.addingTimeInterval(60 * 86_400), speed: 0))
        guard case .closed(let next) = late.windowStatus else {
            Issue.record("Expected a closed window 60 days late")
            return
        }
        // The next chance is one synodic period after the missed one.
        let gap = next.timeIntervalSince(window) / 86_400
        #expect((770...790).contains(gap))
    }

    @Test func earthMarsRoundTripIsAboutTwoAndAHalfYears() throws {
        let plan = try #require(MissionPlan(origin: "Earth", target: "Mars", launchDate: day(2026, 11, 20), speed: 0))
        let trip = try #require(plan.roundTrip)
        #expect(trip.waitDays > 0)
        #expect(abs(trip.returnDays - plan.transfer.travelDays) < 1)
        #expect((900...1_100).contains(trip.totalDays))
        #expect(trip.homeDate > plan.arrivalDay)
    }

    @Test func marsSignalDelayIsMinutes() throws {
        let plan = try #require(MissionPlan(origin: "Earth", target: "Mars", launchDate: day(2026, 11, 20), speed: 0))
        let seconds = try #require(plan.signalDelaySeconds)
        // Between closest approach (~3 min) and the far side of the Sun (~22 min).
        #expect((180...1_340).contains(seconds))
    }

    @Test func samePlanetHasNoPlan() {
        #expect(MissionPlan(origin: "Earth", target: "Earth", launchDate: Date(), speed: 0) == nil)
    }
}
