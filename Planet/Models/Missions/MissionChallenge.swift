//
//  MissionChallenges.swift
//  Planet
//
//  Mission Control's challenges: Mission Builder turned into a game. Each challenge sets a
//  route, a fuel budget and a deadline. The player picks a launch day and a
//  route speed, presses Launch, and — after a 3-2-1 countdown and liftoff —
//  watches whether the spacecraft and the planet meet.
//
//  ★    reach the planet (launch when it's lined up)
//  ★★   … and stay within the fuel budget
//  ★★★  … and beat the deadline
//
//  Every budget/deadline pair was checked against `TransferOrbit` so that a
//  band of route speeds earns all three stars, and the launch-day range
//  covers a full synodic period, so there is always a window to find.
//

import SwiftUI

// MARK: - Challenges

struct MissionChallenge: Identifiable {
    let id: String
    let chapter: Chapter
    let title: LocalizedStringKey
    let brief: LocalizedStringKey
    let origin: String
    let target: String
    let deadlineDays: Double
    let fuelBudget: Double        // km/s, total Δv
    /// Early challenges show where the target needs to be; later ones don't.
    let showsGuide: Bool
    /// The one idea this challenge teaches, shown after a hit. Daily
    /// missions don't have one.
    let lessonTitle: LocalizedStringKey?
    let lesson: LocalizedStringKey?

    enum Chapter: CaseIterable {
        case inner, giants

        var title: LocalizedStringKey {
            switch self {
            case .inner: return "Inner Planets"
            case .giants: return "Giant Planets"
            }
        }

        var icon: String {
            switch self {
            case .inner: return "sun.max.fill"
            case .giants: return "circle.hexagongrid.fill"
            }
        }
    }

    // Lesson facts were checked against the app's own orbit maths
    // (`TransferOrbit` / `LaunchWindow`): Mars needs a 44° lead, Venus starts
    // 54° behind, a sub-4-month Mars trip costs 2.8× the fuel, and Jupiter
    // moves 83° during the cheapest trip.
    static let all: [MissionChallenge] = [
        MissionChallenge(id: "first-flight", chapter: .inner, title: "First Flight",
                         brief: "Mars moves while you fly, so it needs a head start. Slide the launch day until Mars sits in the yellow circle.",
                         origin: "Earth", target: "Mars", deadlineDays: 270, fuelBudget: 6.0, showsGuide: true,
                         lessonTitle: "Launch windows",
                         lesson: "You can't aim at where Mars is, only where it will be. It has to be about 45° ahead of Earth at launch, and that only happens every 26 months."),
        MissionChallenge(id: "morning-star", chapter: .inner, title: "Morning Star",
                         brief: "Venus is closer to the Sun and faster than Earth. Line it up, then shave a few days off the trip.",
                         origin: "Earth", target: "Venus", deadlineDays: 140, fuelBudget: 6.0, showsGuide: true,
                         lessonTitle: "Inner planets are faster",
                         lesson: "The closer a planet is to the Sun, the faster it goes. Venus starts about 55° behind Earth and catches up while you fly."),
        MissionChallenge(id: "red-planet-express", chapter: .inner, title: "Red Planet Express",
                         brief: "Mission Control needs you at Mars in under 200 days. Go a little faster, but watch your fuel.",
                         origin: "Earth", target: "Mars", deadlineDays: 200, fuelBudget: 8.0, showsGuide: true,
                         lessonTitle: "Speed costs fuel",
                         lesson: "A faster route stretches your orbit so it crosses Mars's path early. Every day you save costs extra fuel."),
        MissionChallenge(id: "homecoming", chapter: .inner, title: "Homecoming",
                         brief: "Bring the crew home from Mars. No guide this time: launch, look where Earth ends up, and adjust.",
                         origin: "Mars", target: "Earth", deadlineDays: 235, fuelBudget: 7.0, showsGuide: false,
                         lessonTitle: "Falling towards the Sun",
                         lesson: "To head inwards you slow down, not speed up, and let the Sun pull you in. Astronauts would wait on Mars over a year for this window."),
        MissionChallenge(id: "speed-run", chapter: .inner, title: "Speed Run",
                         brief: "Earth to Mars in under four months. You'll need a lot of fuel, but not too much.",
                         origin: "Earth", target: "Mars", deadlineDays: 120, fuelBudget: 16.5, showsGuide: false,
                         lessonTitle: "Diminishing returns",
                         lesson: "Cutting the trip to under four months takes nearly three times the fuel of the cheapest route. That's why real Mars missions take 6 to 9 months."),
        MissionChallenge(id: "close-to-the-sun", chapter: .inner, title: "Close to the Sun",
                         brief: "Mercury races around the Sun every 88 days. Your timing has to be spot on.",
                         origin: "Earth", target: "Mercury", deadlineDays: 101, fuelBudget: 20.0, showsGuide: false,
                         lessonTitle: "Fast targets, tiny windows",
                         lesson: "Mercury moves so fast that a good launch lasts only a few days. Getting close to the Sun is also expensive: you have to shed a lot of speed."),
        MissionChallenge(id: "giant-leap", chapter: .giants, title: "Giant Leap",
                         brief: "Reach Jupiter within two years. The cheapest route takes almost three.",
                         origin: "Earth", target: "Jupiter", deadlineDays: 730, fuelBudget: 17.0, showsGuide: false,
                         lessonTitle: "Climbing away from the Sun",
                         lesson: "Jupiter is slow, but the trip is long: it moves almost a quarter of the way round the Sun while you fly. Most of your fuel goes on climbing away from the Sun."),
        MissionChallenge(id: "ringmaster", chapter: .giants, title: "Ringmaster",
                         brief: "Visit Saturn's rings within four years.",
                         origin: "Earth", target: "Saturn", deadlineDays: 1_461, fuelBudget: 18.5, showsGuide: false,
                         lessonTitle: "Gravity assists",
                         lesson: "Real missions borrow speed from planets. Cassini swung past Venus twice, then Earth and Jupiter, on its way to Saturn."),
        MissionChallenge(id: "ice-giant", chapter: .giants, title: "Ice Giant",
                         brief: "Uranus is so far away that light takes over two hours to get there. Arrive within ten years.",
                         origin: "Earth", target: "Uranus", deadlineDays: 3_653, fuelBudget: 18.2, showsGuide: false,
                         lessonTitle: "On its own",
                         lesson: "A radio message from Uranus takes over two and a half hours to reach Earth, so a spacecraft there has to look after itself."),
        MissionChallenge(id: "edge-of-the-planets", chapter: .giants, title: "Edge of the Planets",
                         brief: "The last planet. Reach Neptune within twenty years. Voyager 2 took twelve, by swinging past the giant planets.",
                         origin: "Earth", target: "Neptune", deadlineDays: 7_305, fuelBudget: 17.2, showsGuide: false,
                         lessonTitle: "The Grand Tour",
                         lesson: "In the late 1970s the giant planets lined up in a way that happens about once every 175 years. Voyager 2 used it to visit all four.")
    ]

    /// Unlocked once the previous challenge has at least one star.
    static func isUnlocked(_ index: Int, stars: [String: Int]) -> Bool {
        index == 0 || (stars[all[index - 1].id] ?? 0) > 0
    }
}

// MARK: - Scoring

extension MissionChallenge {
    /// The target counts as hit within this many degrees of the meeting
    /// point — about where the planet and the arrival ring overlap.
    static let hitDegrees = 5.0
    static let bullseyeDegrees = 1.0

    /// How one launch went, on its own. Whether it's a new best, earns a
    /// stamp or unlocks the next challenge depends on saved progress, so
    /// that's left to the caller.
    struct Attempt: Equatable {
        let hit: Bool
        let bullseye: Bool
        /// Straight-line gap between the planet and the meeting point, km.
        let missKm: Double
        /// Days to move the launch for a hit (positive = later), if missed.
        let shiftDays: Int?
        let fuelOK: Bool
        let timeOK: Bool

        var stars: Int { hit ? 1 + (fuelOK ? 1 : 0) + (timeOK ? 1 : 0) : 0 }
    }

    /// The last day on the launch-day slider: one full synodic period, so at
    /// least one launch window is always in range.
    var lastLaunchDay: Double {
        (LaunchWindow.synodicDays(origin, target) ?? 365).rounded(.up)
    }

    func transfer(speed: Double) -> TransferOrbit? {
        guard let o = PlanetMetrics.metrics(for: origin),
              let t = PlanetMetrics.metrics(for: target) else { return nil }
        return TransferOrbit(from: o, to: t, speed: speed)
    }

    /// Scores a launch `launchDay` days after the slider's first day, on
    /// `launchDate`.
    func attempt(transfer t: TransferOrbit, launchDate: Date, launchDay: Double) -> Attempt {
        let miss = LaunchWindow.miss(from: origin, to: target, transfer: t, launch: launchDate) ?? .pi
        let missDegrees = abs(miss) * 180 / .pi
        let hit = missDegrees <= Self.hitDegrees

        // How many days to move the launch so the gap closes, kept inside the
        // slider's range (one synodic period either way lands on another window).
        var shift: Int?
        if !hit, let rate = LaunchWindow.relativeRate(origin, target), rate != 0,
           let synodic = LaunchWindow.synodicDays(origin, target) {
            var day = launchDay - miss / rate
            while day > lastLaunchDay { day -= synodic }
            while day < 0 { day += synodic }
            shift = Int((day - launchDay).rounded())
        }

        return Attempt(hit: hit,
                       bullseye: missDegrees <= Self.bullseyeDegrees,
                       missKm: 2 * t.targetRadius * sin(abs(miss) / 2),
                       shiftDays: shift,
                       fuelOK: t.totalDeltaV <= fuelBudget,
                       timeOK: t.travelDays <= deadlineDays)
    }
}
