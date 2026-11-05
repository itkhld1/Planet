//
//  TransferOrbitTests.swift
//  PlanetTests
//

import Foundation
import Testing
@testable import Planet

@Suite("Transfer orbits")
struct TransferOrbitTests {
    private func orbit(_ from: String, _ to: String, speed: Double = 0) -> TransferOrbit? {
        guard let o = PlanetMetrics.metrics(for: from), let t = PlanetMetrics.metrics(for: to) else { return nil }
        return TransferOrbit(from: o, to: t, speed: speed)
    }

    @Test func earthToMarsHohmannMatchesRealMissions() throws {
        let t = try #require(orbit("Earth", "Mars"))
        // About 8.5 months, the textbook Hohmann figure.
        #expect((250...265).contains(t.travelDays))
        // Heliocentric Δv for Earth → Mars is about 5.6 km/s.
        #expect((5.4...5.8).contains(t.totalDeltaV))
        #expect(abs(t.sweptAngle - .pi) < 1e-9)
    }

    @Test func inboundTripTakesTheSameTimeAsOutbound() throws {
        let out = try #require(orbit("Earth", "Mars"))
        let back = try #require(orbit("Mars", "Earth"))
        #expect(abs(out.travelDays - back.travelDays) < 0.5)
        #expect(abs(out.totalDeltaV - back.totalDeltaV) < 0.01)
    }

    @Test func sameOrbitHasNoTransfer() {
        #expect(orbit("Earth", "Earth") == nil)
    }

    @Test(arguments: ["Mercury", "Venus", "Mars", "Jupiter", "Neptune"])
    func fasterRoutesAreShorterAndCostMoreFuel(target: String) throws {
        var previous = try #require(orbit("Earth", target, speed: 0))
        for speed in stride(from: 0.25, through: 1.0, by: 0.25) {
            let next = try #require(orbit("Earth", target, speed: speed))
            #expect(next.travelDays < previous.travelDays)
            #expect(next.totalDeltaV > previous.totalDeltaV)
            previous = next
        }
    }

    @Test func positionRunsFromOriginToTargetOrbit() throws {
        let t = try #require(orbit("Earth", "Jupiter", speed: 0.4))
        let start = t.position(at: 0)
        let end = t.position(at: 1)
        #expect(abs(start.r - t.originRadius) / t.originRadius < 1e-6)
        #expect(abs(end.r - t.targetRadius) / t.targetRadius < 1e-6)
        #expect(abs(start.swept) < 1e-9)
        #expect(abs(end.swept - t.sweptAngle) < 1e-6)
    }

    @Test func pathIsLongerThanTheStraightGap() throws {
        let t = try #require(orbit("Earth", "Mars"))
        #expect(t.transferDistanceKm > t.targetRadius - t.originRadius)
        // Half an ellipse with a ≈ 188.75 million km is roughly π·a ≈ 590 million km.
        #expect((550e6...630e6).contains(t.transferDistanceKm))
    }
}
