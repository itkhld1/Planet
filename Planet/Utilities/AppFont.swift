//
//  AppFont.swift
//  Planet
//

import SwiftUI

/// The app's typography, in one place.
///
/// Avenir Next covers Latin, Greek and Cyrillic — it has **no Arabic script**.
/// Asking for it while showing Persian makes the system substitute a face per
/// glyph, which mixes shapes and throws off line metrics. So for scripts Avenir
/// can't draw, we ask for the system font instead, which covers everything and
/// is well-shaped for Persian.
enum AppFont {
    /// Scripts Avenir Next cannot render. Add to this as languages are added.
    private static let nonLatinLanguages: Set<String> = ["fa", "ar", "he", "ur", "hi", "th", "zh", "ja", "ko", "ru", "el"]

    /// True when the current language needs a face Avenir Next doesn't have.
    ///
    /// Reads `AppLanguage`, not `Locale.current`: picking Persian in-app while
    /// the phone stays in English leaves `Locale.current` as English, which
    /// would hand Persian text to a font with no Arabic glyphs.
    static var needsSystemFont: Bool {
        nonLatinLanguages.contains(AppLanguage.code)
    }

    // These two are the only places `.custom("AvenirNext-…")` may appear. Every
    // other call site goes through here.
    static func regular(_ size: CGFloat) -> Font {
        needsSystemFont
            ? .system(size: size)
            : .custom("AvenirNext-Regular", size: size)
    }

    static func bold(_ size: CGFloat) -> Font {
        needsSystemFont
            ? .system(size: size, weight: .bold)
            : .custom("AvenirNext-Bold", size: size)
    }
}
