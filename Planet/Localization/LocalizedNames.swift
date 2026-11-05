//
//  LocalizedNames.swift
//  Planet
//

import Foundation

extension String {
    /// Looks this string up in the string catalog at runtime.
    ///
    /// For text that arrives as a `String` variable rather than a literal —
    /// `Text(someString)` renders verbatim and never consults the catalog, so
    /// the lookup has to be explicit. Xcode's extractor can't see these, so the
    /// keys must exist in `Localizable.xcstrings` already.
    var localizedFromCatalog: String {
        String(localized: String.LocalizationValue(self), bundle: Bundle.appLanguage)
    }

    /// The translated name of a body, for display only.
    ///
    /// Planet and moon names do double duty in this app: they're what the user
    /// reads *and* the key that `PlanetDetails`, `PlanetMetrics.byName`,
    /// `Moon.moons(of:)` and the `.usdz` filenames are looked up by. Translating
    /// the stored value would break every one of those lookups, so the English
    /// name stays the identity and this is applied at the point of display.
    ///
    /// The keys live in `Localizable.xcstrings`. Anything without an entry —
    /// including English itself — comes back unchanged.
    var localizedBodyName: String { localizedFromCatalog }
}
