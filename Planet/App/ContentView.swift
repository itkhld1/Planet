//
//  ContentView.swift
//  Planets
//
//  Created by itkhld on 2.04.2025.
//

import SwiftUI

struct ContentView: View {
    // Selected tab to pass into Tabs (Tabs expects Binding<Int>)
    @State private var selected: Int = 0

    // Prefer @AppStorage to keep SwiftUI in sync with UserDefaults
    @AppStorage("AppInstruction") private var hasSeenInstruction: Bool = false

    /// Observed so that changing the language rebuilds the whole tree.
    @AppStorage(AppLanguage.storageKey) private var language = AppLanguage.system.rawValue

    var body: some View {
        ZStack {
            Tabs(selectedTab: $selected)

            if !hasSeenInstruction {
                AppInstruction()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        // Two mechanisms, because neither reaches the other's strings:
        // `\.locale` drives SwiftUI's own `Text` literals and number
        // formatting; `AppLanguage.apply()` redirects `Bundle.main` so every
        // `String(localized:)` call answers in the same language.
        .environment(\.locale, AppLanguage.locale)
        .environment(\.layoutDirection, AppLanguage.layoutDirection)
        // Forces a teardown so views holding already-formatted strings in
        // @State rebuild instead of keeping stale text in the old language.
        .id(language)
        .onAppear { AppLanguage.apply() }
        .onChange(of: language) { AppLanguage.apply() }
    }
}

#Preview {
    ContentView()
}
