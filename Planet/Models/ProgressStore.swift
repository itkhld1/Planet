//
//  ProgressStore.swift
//  Planet
//
//  Everything the player has earned or made: challenge stars, passport
//  stamps, the spacecraft and crew, and the quiz high score. One place to
//  read and write it, instead of each screen decoding its own JSON string.
//
//  Views read `ProgressStore.shared` directly. It's `@Observable`, so any
//  view whose body touches a property redraws when that property changes —
//  no environment injection needed, and previews just work.
//

import Foundation
import Observation

@MainActor
@Observable
final class ProgressStore {
    static let shared = ProgressStore()

    /// The same keys and JSON shapes the screens used before this store
    /// existed, so saved progress carries over untouched.
    enum Key {
        static let challengeStars = "missionChallengeStars"
        static let passportVisits = "missionPassport"
        static let crew = "spacecraftCrew"
        static let spacecraftName = "spacecraftName"
        static let spacecraftColor = "spacecraftColor"
        static let spacecraftIcon = "spacecraftIcon"
        static let quizHighScore = "HighScore"

        static let all = [challengeStars, passportVisits, crew, spacecraftName,
                          spacecraftColor, spacecraftIcon, quizHighScore]
    }

    @ObservationIgnored private let defaults: UserDefaults

    /// Best stars per challenge id (campaign ids and "daily-yyyy-mm-dd").
    private(set) var challengeStars: [String: Int]
    /// First visit per planet, seconds since 1970.
    private(set) var passportVisits: [String: Double]
    private(set) var quizHighScore: Int

    var crew: [CrewMember] {
        didSet { Self.write(crew, Key.crew, to: defaults) }
    }
    var spacecraftName: String {
        didSet { defaults.set(spacecraftName, forKey: Key.spacecraftName) }
    }
    var spacecraftColor: Int {
        didSet { defaults.set(spacecraftColor, forKey: Key.spacecraftColor) }
    }
    var spacecraftIcon: Int {
        didSet { defaults.set(spacecraftIcon, forKey: Key.spacecraftIcon) }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        challengeStars = Self.read(Key.challengeStars, from: defaults) ?? [:]
        passportVisits = Self.read(Key.passportVisits, from: defaults) ?? [:]
        crew = Self.read(Key.crew, from: defaults) ?? []
        spacecraftName = defaults.string(forKey: Key.spacecraftName) ?? ""
        spacecraftColor = defaults.integer(forKey: Key.spacecraftColor)
        spacecraftIcon = defaults.integer(forKey: Key.spacecraftIcon)
        quizHighScore = defaults.integer(forKey: Key.quizHighScore)
    }

    /// Re-reads everything, for when another device has changed it.
    func reload() {
        challengeStars = Self.read(Key.challengeStars, from: defaults) ?? [:]
        passportVisits = Self.read(Key.passportVisits, from: defaults) ?? [:]
        quizHighScore = defaults.integer(forKey: Key.quizHighScore)
        let crew: [CrewMember] = Self.read(Key.crew, from: defaults) ?? []
        if crew != self.crew { self.crew = crew }
        let name = defaults.string(forKey: Key.spacecraftName) ?? ""
        if name != spacecraftName { spacecraftName = name }
        let color = defaults.integer(forKey: Key.spacecraftColor)
        if color != spacecraftColor { spacecraftColor = color }
        let icon = defaults.integer(forKey: Key.spacecraftIcon)
        if icon != spacecraftIcon { spacecraftIcon = icon }
    }

    // MARK: Challenges

    func stars(for challengeID: String) -> Int {
        challengeStars[challengeID] ?? 0
    }

    var campaignStars: Int {
        MissionChallenge.all.reduce(0) { $0 + stars(for: $1.id) }
    }

    /// Keeps the best result. Returns true if this beat it.
    @discardableResult
    func recordStars(_ stars: Int, for challengeID: String) -> Bool {
        guard stars > self.stars(for: challengeID) else { return false }
        challengeStars[challengeID] = stars
        Self.write(challengeStars, Key.challengeStars, to: defaults)
        return true
    }

    // MARK: Passport

    /// A planet also counts as visited if any challenge to it has a star, so
    /// players who earned stars before the passport existed keep their stamps
    /// (just without a date).
    func hasVisited(_ planet: String) -> Bool {
        passportVisits[planet] != nil
            || MissionChallenge.all.contains { $0.target == planet && stars(for: $0.id) > 0 }
    }

    var visitedPlanetCount: Int {
        Passport.planets.filter(hasVisited).count
    }

    func firstVisit(to planet: String) -> Date? {
        passportVisits[planet].map(Date.init(timeIntervalSince1970:))
    }

    /// Stamps the passport the first time a planet is reached.
    func recordVisit(to planet: String, on date: Date = Date()) {
        guard passportVisits[planet] == nil else { return }
        passportVisits[planet] = date.timeIntervalSince1970
        Self.write(passportVisits, Key.passportVisits, to: defaults)
    }

    // MARK: Spacecraft

    /// The name to show: what the player typed, or a default.
    var spacecraftDisplayName: String { Spacecraft.displayName(spacecraftName) }

    // MARK: Quiz

    /// Keeps the best score. Returns true if this beat it.
    @discardableResult
    func recordQuizScore(_ score: Int) -> Bool {
        guard score > quizHighScore else { return false }
        quizHighScore = score
        defaults.set(score, forKey: Key.quizHighScore)
        return true
    }

    func resetQuizHighScore() {
        quizHighScore = 0
        defaults.set(0, forKey: Key.quizHighScore)
    }

    // MARK: Storage

    /// Values are stored as JSON strings, as they were under `@AppStorage`.
    private static func read<T: Decodable>(_ key: String, from defaults: UserDefaults) -> T? {
        guard let json = defaults.string(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: Data(json.utf8))
    }

    private static func write<T: Encodable>(_ value: T, _ key: String, to defaults: UserDefaults) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        defaults.set(String(data: data, encoding: .utf8), forKey: key)
    }
}
