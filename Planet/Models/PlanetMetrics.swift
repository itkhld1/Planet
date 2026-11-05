//
//  PlanetMetrics.swift
//  Planet
//

import Foundation

/// Numeric facts for a planet.
///
/// `Planet` stores its figures as display strings ("12,742 km"), which are
/// fine to show but can't be compared or sorted. These are the same values in
/// a usable form, taken from the descriptions in `PlanetDetails`.
struct PlanetMetrics {
    let diameterKm: Double
    let distanceFromSunKm: Double
    /// Length of one rotation, in Earth hours.
    let dayLengthHours: Double
    /// Length of one orbit, in Earth days.
    let yearLengthDays: Double
    /// Surface gravity relative to Earth.
    let gravity: Double
    let moonCount: Int

    static let byName: [String: PlanetMetrics] = [
        "Mercury": PlanetMetrics(diameterKm: 4_880, distanceFromSunKm: 57_900_000,
                                 dayLengthHours: 1_407.6, yearLengthDays: 88,
                                 gravity: 0.38, moonCount: 0),
        "Venus": PlanetMetrics(diameterKm: 12_104, distanceFromSunKm: 108_200_000,
                               dayLengthHours: 5_832, yearLengthDays: 225,
                               gravity: 0.91, moonCount: 0),
        "Earth": PlanetMetrics(diameterKm: 12_742, distanceFromSunKm: 149_600_000,
                               dayLengthHours: 24, yearLengthDays: 365.25,
                               gravity: 1.0, moonCount: 1),
        "Mars": PlanetMetrics(diameterKm: 6_779, distanceFromSunKm: 227_900_000,
                              dayLengthHours: 24.6, yearLengthDays: 687,
                              gravity: 0.38, moonCount: 2),
        "Jupiter": PlanetMetrics(diameterKm: 142_984, distanceFromSunKm: 778_500_000,
                                 dayLengthHours: 9.93, yearLengthDays: 4_333,
                                 gravity: 2.34, moonCount: 95),
        "Saturn": PlanetMetrics(diameterKm: 120_536, distanceFromSunKm: 1_434_000_000,
                                dayLengthHours: 10.7, yearLengthDays: 10_756,
                                gravity: 1.06, moonCount: 146),
        "Uranus": PlanetMetrics(diameterKm: 50_724, distanceFromSunKm: 2_871_000_000,
                                dayLengthHours: 17.24, yearLengthDays: 30_687,
                                gravity: 0.92, moonCount: 27),
        "Neptune": PlanetMetrics(diameterKm: 49_244, distanceFromSunKm: 4_495_000_000,
                                 dayLengthHours: 16.11, yearLengthDays: 60_190,
                                 gravity: 1.19, moonCount: 14)
    ]

    static func metrics(for planet: String) -> PlanetMetrics? {
        byName[planet]
    }
}

/// Anything the compare screen can put on one side of the table.
///
/// The Sun doesn't fit `PlanetMetrics`: it has no distance from itself and no
/// meaningful year, so those rows carry display text instead of numbers. The
/// optional sort keys are what drives the "larger value" highlight — when
/// either side is `nil` the row simply isn't ranked.
struct BodyMetrics: Identifiable {
    let id = UUID()
    let name: String
    let imageName: String
    let diameterKm: Double
    let dayLengthHours: Double
    let gravity: Double
    let distanceKm: Double?
    let yearDays: Double?
    let satelliteCount: Int?

    // The display strings are computed, not stored. `all` is a `static let`
    // built once, so storing them would freeze the Compare screen in whichever
    // language the app happened to launch in.

    var distanceText: String {
        guard let distanceKm else { return String(localized: "It is the centre", bundle: Bundle.appLanguage) }
        return MetricFormat.km(distanceKm)
    }

    var yearText: String {
        guard let yearDays else { return String(localized: "~230 million years", bundle: Bundle.appLanguage) }
        return MetricFormat.days(yearDays)
    }

    /// "Moons" for a planet; the Sun's satellites are planets, so it says so.
    var satellitesLabel: String {
        satelliteCount == nil ? "Orbiting bodies" : "Moons"
    }

    var satellitesText: String {
        guard let satelliteCount else { return String(localized: "8 planets", bundle: Bundle.appLanguage) }
        return MetricFormat.grouped(Double(satelliteCount))
    }

    init(planet: Planet, metrics: PlanetMetrics) {
        name = planet.name
        imageName = planet.imageName
        diameterKm = metrics.diameterKm
        dayLengthHours = metrics.dayLengthHours
        gravity = metrics.gravity
        distanceKm = metrics.distanceFromSunKm
        yearDays = metrics.yearLengthDays
        satelliteCount = metrics.moonCount
    }

    /// The Sun. Its nil values are what mark it out: no distance from itself,
    /// no meaningful year, and satellites that aren't moons.
    private init(sun: Star) {
        name = sun.name
        imageName = sun.imageName
        diameterKm = 1_392_000
        dayLengthHours = 609.6          // ~25.4 Earth days at the equator
        gravity = 27.94
        distanceKm = nil
        yearDays = nil                  // it orbits the galaxy, not the Sun
        satelliteCount = nil
    }

    static let sunBody = BodyMetrics(sun: sun)

    /// The Sun first, then the planets in orbital order. Built once so the
    /// identifiers stay stable across renders.
    static let all: [BodyMetrics] = [sunBody] + planets.compactMap { planet in
        PlanetMetrics.metrics(for: planet.name).map { BodyMetrics(planet: planet, metrics: $0) }
    }

    static func body(named name: String) -> BodyMetrics? {
        all.first { $0.name == name }
    }
}

/// Formatting helpers shared by the comparison screen.
enum MetricFormat {
    // The unit words are looked up rather than hardcoded. Worth care when more
    // languages arrive: English "billion" is French "milliard", so a careless
    // translation here is a factor-of-1000 error in a science app.
    //
    // The numbers go through `NumberFormatter` and reach the format string as
    // %@ rather than %f. Two reasons: `String(format: "%.1f", …)` always emits
    // Western digits, so Persian would read "25.4" instead of "۲۵٫۴"; and keys
    // differing only by their format specifier ("%.1f Earth days" vs
    // "%.0f Earth days") generate colliding symbols from the string catalog.

    private static func number(_ value: Double, decimals: Int) -> String {
        let formatter = NumberFormatter()
        // Follows the in-app choice, not the device: picking Persian while the
        // phone stays English must still give Persian digits.
        formatter.locale = AppLanguage.locale
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = decimals
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    /// A bare number in the app's language (Persian digits when Persian is selected).
    static func plain(_ value: Double, decimals: Int) -> String {
        number(value, decimals: decimals)
    }

    static func km(_ value: Double) -> String {
        if value >= 1_000_000_000 {
            return String(format: String(localized: "%@ billion km", bundle: Bundle.appLanguage), number(value / 1_000_000_000, decimals: 2))
        }
        if value >= 1_000_000 {
            return String(format: String(localized: "%@ million km", bundle: Bundle.appLanguage), number(value / 1_000_000, decimals: 1))
        }
        // A decimal below 100 so small moons keep their precision — Phobos is
        // 22.5 km, and rounding it to 23 would be a made-up number.
        return String(format: String(localized: "%@ km", bundle: Bundle.appLanguage),
                      number(value, decimals: value < 100 ? 1 : 0))
    }

    static func hours(_ value: Double) -> String {
        if value >= 48 {
            return String(format: String(localized: "%@ Earth days", bundle: Bundle.appLanguage), number(value / 24, decimals: 1))
        }
        return String(format: String(localized: "%@ hours", bundle: Bundle.appLanguage), number(value, decimals: 1))
    }

    static func days(_ value: Double) -> String {
        if value >= 365 {
            return String(format: String(localized: "%@ Earth years", bundle: Bundle.appLanguage), number(value / 365.25, decimals: 1))
        }
        return String(format: String(localized: "%@ Earth days", bundle: Bundle.appLanguage), number(value, decimals: 0))
    }

    /// Surface gravity relative to Earth.
    static func gravity(_ value: Double) -> String {
        String(format: String(localized: "%@ × Earth", bundle: Bundle.appLanguage), number(value, decimals: 2))
    }

    /// A plain number in the app's language — Persian digits and separators —
    /// with no trailing ".00" on whole values.
    static func decimal(_ value: Double, maxDecimals: Int = 2) -> String {
        number(value, decimals: maxDecimals)
    }

    /// Reads a number the user typed, in whatever digits they typed it.
    ///
    /// `Double("۷۰")` is nil: Swift only parses Latin digits with a "."
    /// separator. Persian keyboards produce ۰-۹ and "٫", so a valid weight
    /// would be rejected as invalid. This also has to keep working across a
    /// language switch, since the entered value is persisted — hence
    /// normalising rather than parsing with the current locale.
    static func parse(_ text: String) -> Double? {
        if let value = Double(text) { return value }

        var normalized = ""
        for character in text {
            if character.isNumber, let digit = character.wholeNumberValue {
                normalized.append(String(digit))          // ۷ -> 7
            } else if character == "٫" || character == "." {
                normalized.append(".")                    // decimal separator
            } else if character == "٬" || character == "," || character == " " {
                continue                                  // grouping separator
            } else {
                normalized.append(character)              // let Double reject it
            }
        }
        return Double(normalized)
    }

    static func grouped(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = AppLanguage.locale
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: value)) ?? "\(Int(value))"
    }
}
