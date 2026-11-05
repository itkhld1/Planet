//
//  AppSettings.swift
//  Planet
//

import SwiftUI

/// The unit the weight calculator reads and writes.
enum WeightUnit: String, CaseIterable, Identifiable {
    case kilograms
    case pounds

    var id: String { rawValue }

    /// These reach the UI as `String` values, not literals, so they're looked
    /// up here — `Text(unit.displayName)` would otherwise render verbatim.
    var shortName: String {
        switch self {
        case .kilograms: return String(localized: "kg", bundle: Bundle.appLanguage)
        case .pounds: return String(localized: "lbs", bundle: Bundle.appLanguage)
        }
    }

    var displayName: String {
        switch self {
        case .kilograms: return String(localized: "Kilograms", bundle: Bundle.appLanguage)
        case .pounds: return String(localized: "Pounds", bundle: Bundle.appLanguage)
        }
    }
}

/// Keys shared between the settings screen and the features they configure.
enum SettingsKey {
    static let weightUnit = "weightUnit"
    static let hapticsEnabled = "hapticsEnabled"
    static let soundEffectsEnabled = "soundEffectsEnabled"
    static let hasSeenInstruction = "AppInstruction"
    static let highScore = "HighScore"
    static let showPlanetLabels = "showPlanetLabels"
    static let hasSeenMapHint = "hasSeenMapHint"
    static let mapDaysPerSecond = "mapDaysPerSecond"
}

enum AppStoreLink {
    /// Apple's numeric App ID ("Planet - Solar System").
    /// Found in App Store Connect under App Information → General → Apple ID.
    static let appID = "6790789495"

    /// Public store page, used by the Share button.
    static var shareURL: URL? {
        URL(string: "https://apps.apple.com/app/id\(appID)")
    }

    /// Deep link that opens the App Store straight to the review composer.
    ///
    /// A button must use this rather than StoreKit's `requestReview`: Apple's
    /// guidelines say not to request a review in response to a user action, and
    /// the system prompt is rate-limited to three showings a year, so a tap
    /// would often do nothing at all.
    static var reviewURL: URL? {
        guard !appID.isEmpty else { return nil }
        return URL(string: "https://apps.apple.com/app/id\(appID)?action=write-review")
    }
}

/// Fires impact feedback unless the user has turned haptics off.
func playHaptic(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
    guard UserDefaults.standard.object(forKey: SettingsKey.hapticsEnabled) as? Bool ?? true else { return }
    UIImpactFeedbackGenerator(style: style).impactOccurred()
}

/// Fires notification feedback unless the user has turned haptics off.
func playNotificationHaptic(_ type: UINotificationFeedbackGenerator.FeedbackType) {
    guard UserDefaults.standard.object(forKey: SettingsKey.hapticsEnabled) as? Bool ?? true else { return }
    UINotificationFeedbackGenerator().notificationOccurred(type)
}

/// Decides when the system review prompt may appear.
///
/// Apple shows the prompt at most three times a year regardless, but asking
/// at a bad moment wastes one of those. This only asks after a good quiz
/// round (once the app has been opened on a few different days) or after
/// someone has explored a few planets on the map, and never twice for the
/// same version.
enum ReviewPrompt {
    private static let launchDaysKey = "reviewLaunchDays"
    private static let lastVersionKey = "reviewLastPromptedVersion"
    private static let interactionsKey = "reviewInteractions"

    /// Planet or Sun details opened from the map before asking.
    static let interactionsBeforeAsking = 5

    private static var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }

    /// Claims this version's one ask: true the first time only.
    private static func claimAsk() -> Bool {
        let defaults = UserDefaults.standard
        guard defaults.string(forKey: lastVersionKey) != version else { return false }
        defaults.set(version, forKey: lastVersionKey)
        return true
    }

    /// Call when someone opens a planet's or the Sun's details on the map.
    static func recordInteraction() {
        let defaults = UserDefaults.standard
        defaults.set(defaults.integer(forKey: interactionsKey) + 1, forKey: interactionsKey)
    }

    /// Call when they're back on the map after reading, never mid-task.
    static func shouldAskAfterInteractions() -> Bool {
        guard UserDefaults.standard.integer(forKey: interactionsKey) >= interactionsBeforeAsking else { return false }
        return claimAsk()
    }

    /// Call once per launch.
    static func recordLaunch() {
        let defaults = UserDefaults.standard
        let today = Calendar.current.startOfDay(for: Date()).timeIntervalSince1970
        var days = defaults.array(forKey: launchDaysKey) as? [Double] ?? []
        if !days.contains(today) {
            days.append(today)
            defaults.set(Array(days.suffix(30)), forKey: launchDaysKey)
        }
    }

    static func shouldAsk(afterScore score: Int, outOf total: Int) -> Bool {
        let launchDays = (UserDefaults.standard.array(forKey: launchDaysKey) as? [Double] ?? []).count
        guard total > 0,
              Double(score) / Double(total) >= 0.7,
              launchDays >= 2 else { return false }
        return claimAsk()
    }
}
