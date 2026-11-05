//
//  AppLanguage.swift
//  Planet
//

import SwiftUI

/// The language the app displays, and the single source of truth for it.
///
/// Three things have to agree, which is why they all read from here:
///  - the string catalog, via `Bundle.setLanguage`
///  - SwiftUI's `Text` literals, via the `\.locale` environment
///  - the Swift-side content (articles, quiz, moons), via `isPersian`
///
/// Anything without a translation falls back to English rather than showing a
/// key or an empty screen.
enum AppLanguage: String, CaseIterable, Identifiable {
    /// Follow whatever the device/iOS Settings say.
    case system
    case english = "en"
    case persian = "fa"

    var id: String { rawValue }

    static let storageKey = "appLanguage"

    /// Written in its own language, which is the convention for language lists.
    var displayName: String {
        switch self {
        case .system:  return String(localized: "System", bundle: Bundle.appLanguage)
        case .english: return "English"
        case .persian: return "فارسی"
        }
    }

    // MARK: - Current state

    /// The user's explicit choice, or nil when following the system.
    static var selected: AppLanguage {
        let raw = UserDefaults.standard.string(forKey: storageKey) ?? AppLanguage.system.rawValue
        return AppLanguage(rawValue: raw) ?? .system
    }

    /// The language actually in effect, resolved through the system when needed.
    static var code: String {
        if selected != .system { return selected.rawValue }
        return Bundle.main.preferredLocalizations.first
            ?? Locale.current.language.languageCode?.identifier
            ?? "en"
    }

    static var isPersian: Bool { code.hasPrefix("fa") }

    static var locale: Locale { Locale(identifier: code) }

    /// Persian is written right-to-left. SwiftUI won't infer this from `\.locale`
    /// alone, so it's set explicitly alongside it.
    static var layoutDirection: LayoutDirection {
        Locale.Language(identifier: code).characterDirection == .rightToLeft ? .rightToLeft : .leftToRight
    }

    // MARK: - Applying

    /// Redirects the bundle to the current choice. Call at launch and whenever
    /// the choice changes.
    static func apply() {
        Bundle.setLanguage(selected == .system ? nil : selected.rawValue)

        // SwiftUI's `\.layoutDirection` flips SwiftUI's own layout, but the
        // UIKit-backed pieces — navigation bars, search bars, the scroll
        // indicators, the AR view controller — read `semanticContentAttribute`
        // instead and would stay left-to-right. Normally iOS derives this from
        // the app's language; overriding the language in-app means setting it
        // by hand.
        UIView.appearance().semanticContentAttribute =
            layoutDirection == .rightToLeft ? .forceRightToLeft : .forceLeftToRight
    }
}

extension View {
    /// Applies the app's language to a view.
    ///
    /// Needed on every sheet root, not just the app root: a sheet is hosted in
    /// its own presentation container rather than inside the presenting view's
    /// hierarchy, so it does not reliably inherit `\.locale` and
    /// `\.layoutDirection`. Without this, Persian text inside a sheet — which
    /// is nearly every screen here — lays out left-to-right and aligns left.
    func appLanguageEnvironment() -> some View {
        self
            .environment(\.locale, AppLanguage.locale)
            .environment(\.layoutDirection, AppLanguage.layoutDirection)
    }
}
