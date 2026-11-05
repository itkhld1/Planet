//
//  TestSupport.swift
//  PlanetTests
//

import Foundation

/// A throwaway UserDefaults suite, so tests never touch the app's own data.
func scratchDefaults() -> UserDefaults {
    let name = "PlanetTests.\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: name)!
    defaults.removePersistentDomain(forName: name)
    return defaults
}

/// Noon UTC on a calendar day.
func day(_ year: Int, _ month: Int, _ day: Int) -> Date {
    var components = DateComponents(year: year, month: month, day: day, hour: 12)
    components.timeZone = TimeZone(identifier: "UTC")
    return Calendar(identifier: .gregorian).date(from: components)!
}
