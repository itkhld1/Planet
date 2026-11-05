//
//  BundleLanguage.swift
//  Planet
//

import Foundation
import ObjectiveC

/// A `Bundle` that answers string lookups from a chosen `.lproj` instead of the
/// system's.
///
/// Needed because the app offers an in-app language picker. `Text("Settings")`
/// can be pointed at a language through the SwiftUI environment, but the many
/// `String(localized:)` calls — units, metric formatting, the display-name
/// lookups — resolve against `Bundle.main` and the *system* language, and would
/// keep answering in English. Redirecting the bundle covers every path at once.
private final class LocalizedBundle: Bundle, @unchecked Sendable {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        guard let override = objc_getAssociatedObject(self, &Bundle.overrideKey) as? Bundle else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
        return override.localizedString(forKey: key, value: value, table: tableName)
    }
}

/// Caches the `.lproj` bundle per language — `Bundle(path:)` on every string
/// lookup would be wasteful, and these are looked up constantly.
private enum LanguageBundleCache {
    private static let lock = NSLock()
    nonisolated(unsafe) private static var cache: [String: Bundle] = [:]

    static func bundle(for code: String) -> Bundle {
        lock.lock()
        defer { lock.unlock() }
        if let cached = cache[code] { return cached }
        let resolved = Bundle.main.path(forResource: code, ofType: "lproj")
            .flatMap(Bundle.init(path:)) ?? .main
        cache[code] = resolved
        return resolved
    }
}

extension Bundle {
    /// The bundle to read app strings from, honouring the in-app language.
    ///
    /// `String(localized:)` must be passed this explicitly. Unlike `Text`, it
    /// does not consult SwiftUI's `\.locale`, and unlike `NSLocalizedString` it
    /// resolves through the string-catalog machinery rather than the
    /// `localizedString(forKey:value:table:)` funnel that `setLanguage` hooks —
    /// so it would answer in the *system* language no matter what the picker
    /// says. Every `String(localized:)` in this app passes `bundle: Bundle.appLanguage`.
    static var appLanguage: Bundle {
        LanguageBundleCache.bundle(for: AppLanguage.code)
    }

    fileprivate static var overrideKey: UInt8 = 0

    /// Swapped in once, the first time a language is set. `Bundle.main` is a
    /// singleton, so this happens exactly once for the process lifetime.
    private static let installOverride: Void = {
        object_setClass(Bundle.main, LocalizedBundle.self)
    }()

    /// Points string lookups at `language`, or back at the system when nil.
    static func setLanguage(_ language: String?) {
        _ = installOverride

        let override = language
            .flatMap { Bundle.main.path(forResource: $0, ofType: "lproj") }
            .flatMap { Bundle(path: $0) }

        objc_setAssociatedObject(Bundle.main, &overrideKey, override, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
