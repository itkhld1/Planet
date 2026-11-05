//
//  PlanetCalculator.swift
//  Planet
//
//  The weight and age calculators' maths, built on `PlanetMetrics` so the
//  gravity and year lengths live in one place.
//

import Foundation

enum PlanetCalculator {
    /// Earth first, as a reference row, then outwards from the Sun.
    static let planets = ["Earth", "Mercury", "Venus", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune"]

    static let poundsPerKilogram = 2.20462

    /// What an Earth weight becomes on each planet (same unit in and out).
    static func weights(forEarthWeight weight: Double) -> [(planet: String, value: Double)] {
        planets.compactMap { name in
            PlanetMetrics.metrics(for: name).map { (name, weight * $0.gravity) }
        }
    }

    /// How many orbits of the Sun an Earth age is on each planet.
    static func ages(forEarthAge age: Double) -> [(planet: String, value: Double)] {
        guard let earthYear = PlanetMetrics.metrics(for: "Earth")?.yearLengthDays else { return [] }
        return planets.compactMap { name in
            PlanetMetrics.metrics(for: name).map { (name, age * earthYear / $0.yearLengthDays) }
        }
    }

    static func convert(_ weight: Double, from old: WeightUnit, to new: WeightUnit) -> Double {
        switch (old, new) {
        case (.kilograms, .pounds): return weight * poundsPerKilogram
        case (.pounds, .kilograms): return weight / poundsPerKilogram
        default: return weight
        }
    }
}
