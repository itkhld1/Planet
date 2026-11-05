//
//  CalculatorTests.swift
//  PlanetTests
//

import Foundation
import Testing
@testable import Planet

@Suite("Weight, age and number entry")
struct CalculatorTests {
    private func value(_ rows: [(planet: String, value: Double)], _ planet: String) -> Double? {
        rows.first { $0.planet == planet }?.value
    }

    @Test func weightScalesWithGravity() throws {
        let rows = PlanetCalculator.weights(forEarthWeight: 70)
        #expect(rows.count == 8)
        #expect(try #require(value(rows, "Earth")) == 70)
        #expect(abs(try #require(value(rows, "Jupiter")) - 163.8) < 0.01)
        #expect(abs(try #require(value(rows, "Mars")) - 26.6) < 0.01)
    }

    @Test func ageCountsOrbitsOfTheSun() throws {
        let rows = PlanetCalculator.ages(forEarthAge: 10)
        #expect(try #require(value(rows, "Earth")) == 10)
        #expect(abs(try #require(value(rows, "Mars")) - 5.32) < 0.01)
        #expect(abs(try #require(value(rows, "Mercury")) - 41.5) < 0.1)
    }

    @Test func unitConversionRoundTrips() {
        let pounds = PlanetCalculator.convert(70, from: .kilograms, to: .pounds)
        #expect(abs(pounds - 154.32) < 0.01)
        #expect(abs(PlanetCalculator.convert(pounds, from: .pounds, to: .kilograms) - 70) < 1e-9)
        #expect(PlanetCalculator.convert(70, from: .pounds, to: .pounds) == 70)
    }

    @Test(arguments: [("70", 70.0), ("۷۰", 70), ("۱۲٫۵", 12.5), ("1,234", 1_234), ("۱٬۲۳۴", 1_234), ("12.5", 12.5)])
    func parsesTypedNumbersInAnyDigits(text: String, expected: Double) {
        #expect(MetricFormat.parse(text) == expected)
    }

    @Test func rejectsNonNumbers() {
        #expect(MetricFormat.parse("abc") == nil)
        #expect(MetricFormat.parse("") == nil)
    }
}
