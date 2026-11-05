//
//  SpaceStyle.swift
//  Planet
//
//  Shared look for the newer screens, so they match the rest of the app.
//

import SwiftUI

/// The deep-space gradient with a starfield used behind full screens.
struct SpaceBackground: View {
    var stars: Int = 60

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.02, green: 0.02, blue: 0.12),
                    Color(red: 0.04, green: 0.06, blue: 0.20),
                    Color(red: 0.08, green: 0.04, blue: 0.25)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            StarFieldView(count: stars)
        }
        .ignoresSafeArea()
    }
}

extension View {
    /// Frosted card used for panels on top of `SpaceBackground`.
    func glassCard(cornerRadius: CGFloat = 16) -> some View {
        background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

/// The background used by Solar System, Settings, Compare and the Explore
/// screens: black → GradientColor → purple, with a light starfield.
struct AppGradientBackground: View {
    var stars: Int = 40

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.black, Color("GradientColor"), .purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            StarFieldView(count: stars)
        }
    }
}

extension View {
    /// The dark rounded panel used by Compare and Settings.
    func appCard(cornerRadius: CGFloat = 18) -> some View {
        background(Color.black.opacity(0.28))
            .cornerRadius(cornerRadius)
    }

    /// Inline title over a see-through bar, as on Compare and Settings.
    func appNavigationStyle(_ title: LocalizedStringKey) -> some View {
        navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
