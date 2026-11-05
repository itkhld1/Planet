//
//  LaunchWindow.swift
//  Planet
//
//

import Foundation

/// When the planets line up for a Hohmann transfer.
///
/// Positions come from JPL's mean orbital elements (J2000 mean longitude plus
/// its rate per century), treating orbits as circles. That's the same
/// simplification as `TransferOrbit`, and it lands within a few weeks of
/// real windows (Earth → Mars: May 2018, Sep 2024, Nov 2026).
enum LaunchWindow {
    /// Mean longitude at J2000 (degrees) and its rate (degrees per century).
    private static let elements: [String: (l0: Double, rate: Double)] = [
        "Mercury": (252.250_323_50, 149_472.674_111_75),
        "Venus": (181.979_099_50, 58_517.815_387_29),
        "Earth": (100.464_571_66, 35_999.372_449_81),
        "Mars": (-4.553_432_05, 19_140.302_684_99),
        "Jupiter": (34.396_440_51, 3_034.746_127_75),
        "Saturn": (49.954_244_23, 1_222.493_622_01),
        "Uranus": (313.238_104_51, 428.482_027_85),
        "Neptune": (-55.120_029_69, 218.459_453_25)
    ]

    /// 2000-01-01 12:00 TT, the J2000 epoch (as UTC — close enough here).
    private static let j2000 = Date(timeIntervalSince1970: 946_728_000)

    private static func daysSinceJ2000(_ date: Date) -> Double {
        date.timeIntervalSince(j2000) / 86_400
    }

    /// Mean motion, radians per day.
    static func meanMotion(_ planet: String) -> Double? {
        elements[planet].map { ($0.rate / 36_525) * .pi / 180 }
    }

    /// Mean longitude on a date, radians.
    static func longitude(_ planet: String, on date: Date) -> Double? {
        elements[planet].map { ($0.l0 + $0.rate * daysSinceJ2000(date) / 36_525) * .pi / 180 }
    }

    private static func wrap(_ angle: Double) -> Double {
        let r = angle.truncatingRemainder(dividingBy: 2 * .pi)
        return r < 0 ? r + 2 * .pi : r
    }

    /// The first launch window on or after `date`.
    ///
    /// The target has to be ahead of the origin by the angle the spacecraft
    /// sweeps (180° for Hohmann) minus the angle the target covers during the
    /// trip, so that both reach the meeting point at the same time.
    static func next(from origin: String, to target: String, travelDays: Double,
                     sweptAngle: Double = .pi, after date: Date) -> Date? {
        guard let nO = meanMotion(origin), let nT = meanMotion(target),
              let lO = longitude(origin, on: date), let lT = longitude(target, on: date),
              nO != nT else { return nil }

        let required = sweptAngle - nT * travelDays
        let current = lT - lO
        let relative = nT - nO      // how fast the gap between them changes
        let days = relative > 0
            ? wrap(required - current) / relative
            : wrap(current - required) / -relative
        return date.addingTimeInterval(days * 86_400)
    }

    /// Days between windows for this pair (the synodic period).
    static func synodicDays(_ origin: String, _ target: String) -> Double? {
        guard let nO = meanMotion(origin), let nT = meanMotion(target), nO != nT else { return nil }
        return 2 * .pi / abs(nT - nO)
    }

    /// The gap between gaps-closing speeds: how fast (radians per day) the
    /// target's lead over the origin changes. Negative when it shrinks.
    static func relativeRate(_ origin: String, _ target: String) -> Double? {
        guard let nO = meanMotion(origin), let nT = meanMotion(target) else { return nil }
        return nT - nO
    }

    /// Where the target is when the spacecraft reaches its orbit, measured
    /// from the meeting point: radians in (−π, π]. Zero is a perfect hit;
    /// positive means the target had already gone past.
    static func miss(from origin: String, to target: String, transfer: TransferOrbit, launch: Date) -> Double? {
        guard let lO = longitude(origin, on: launch), let lT = longitude(target, on: launch),
              let nT = meanMotion(target) else { return nil }
        let gap = wrap(lT + nT * transfer.travelDays - (lO + transfer.sweptAngle))
        return gap > .pi ? gap - 2 * .pi : gap
    }

    /// How far either side of the ideal day still counts as "in the window".
    /// Real windows last a few weeks; scaled down for pairs that line up often.
    static func tolerance(synodicDays: Double) -> Double {
        min(30, max(5, synodicDays * 0.03))
    }
}
