//
//  SpaceStyle.swift
//  Planet
//
//  The app's colours and shared surfaces, so every screen matches.
//

import SwiftUI

// MARK: - Palette

/// Every colour with a job. Views use these rather than system colours, so
/// a colour always means the same thing:
/// - `accent` (cyan): anything you can interact with
/// - `amber`: the Sun, stars earned and highlights
/// - `success` / `warning`: results only (in a window or not, hit or miss)
enum Palette {
    static let accent = Color(red: 0.31, green: 0.85, blue: 0.92)    // #4FD8EB
    static let amber = Color(red: 1.00, green: 0.71, blue: 0.28)     // #FFB547
    static let success = Color(red: 0.36, green: 0.85, blue: 0.55)   // #5CD98C
    static let warning = Color(red: 1.00, green: 0.58, blue: 0.30)   // #FF944D

    /// Background, from the deepest navy to a faint violet.
    static let deepSpace = Color(red: 0.043, green: 0.063, blue: 0.149)  // #0B1026
    static let midnight = Color(red: 0.082, green: 0.102, blue: 0.239)   // #151A3D
    static let nebula = Color(red: 0.165, green: 0.086, blue: 0.314)     // #2A1650

    /// Panels on top of the background: a light, see-through tint reads as
    /// glass over the stars, where black looked muddy.
    static let card = Color(red: 0.72, green: 0.80, blue: 1.0).opacity(0.08)
    static let cardStroke = Color.white.opacity(0.09)

    /// Secondary text. Kept at 70% or more for 4.5:1 contrast on the
    /// background.
    static let secondaryText = Color.white.opacity(0.72)

    /// Each planet's own colour, for its detail screen, its orbit when
    /// selected, and anywhere else it needs an identity.
    static func color(forPlanet name: String) -> Color {
        switch name {
        case "Mercury": return Color(red: 0.60, green: 0.56, blue: 0.53)  // slate
        case "Venus": return Color(red: 0.89, green: 0.73, blue: 0.42)    // pale gold
        case "Earth": return Color(red: 0.24, green: 0.55, blue: 0.85)    // ocean
        case "Mars": return Color(red: 0.82, green: 0.33, blue: 0.23)     // rust
        case "Jupiter": return Color(red: 0.82, green: 0.60, blue: 0.42)  // tan
        case "Saturn": return Color(red: 0.90, green: 0.78, blue: 0.48)   // butterscotch
        case "Uranus": return Color(red: 0.44, green: 0.83, blue: 0.84)   // teal
        case "Neptune": return Color(red: 0.24, green: 0.37, blue: 0.85)  // deep blue
        case "Sun": return amber
        default: return accent
        }
    }
}

extension Planet {
    var color: Color { Palette.color(forPlanet: name) }
}

// MARK: - Backgrounds

/// The app's background, without stars: deep navy with soft clouds of
/// colour (a nebula in one corner, a blue glow in the other, faint teal and
/// magenta wisps) that slowly drift and breathe, so the screen feels alive
/// without pulling attention from what's on it.
///
/// Every cloud moves on its own slow cycle (11–37 s, none in step), so the
/// pattern never visibly repeats. Holds still with Reduce Motion, and when
/// `animated` is false (images rendered with `ImageRenderer`, which doesn't
/// reliably draw timeline content).
struct SpaceGradient: View {
    /// Tints the nebula, e.g. with a planet's colour on its detail screen.
    var tint: Color = Palette.nebula
    var tintStrength: Double = 1
    var animated = true

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        if animated && !reduceMotion {
            // The motion is slow, so 24 fps is plenty and saves battery.
            TimelineView(.animation(minimumInterval: 1.0 / 24)) { context in
                clouds(at: context.date.timeIntervalSinceReferenceDate)
            }
        } else {
            clouds(at: 0)
        }
    }

    private func clouds(at t: Double) -> some View {
        /// -1...1 over `period` seconds.
        func wave(_ period: Double, _ phase: Double = 0) -> Double {
            sin(t * 2 * .pi / period + phase)
        }

        return ZStack {
            LinearGradient(colors: [Palette.deepSpace, Palette.midnight],
                           startPoint: .top, endPoint: .bottom)

            // Nebula, drifting around the bottom corner.
            RadialGradient(colors: [tint.opacity((0.8 + 0.2 * wave(11)) * tintStrength), .clear],
                           center: UnitPoint(x: 0.8 + 0.2 * wave(29), y: 0.82 + 0.14 * wave(37, 1)),
                           startRadius: 0, endRadius: 520 + 90 * wave(19))

            // Blue glow, around the top corner.
            RadialGradient(colors: [Color(red: 0.06, green: 0.16, blue: 0.33).opacity(0.65 + 0.2 * wave(13, 2)), .clear],
                           center: UnitPoint(x: 0.15 + 0.18 * wave(31, 3), y: 0.12 + 0.14 * wave(23)),
                           startRadius: 0, endRadius: 420 + 80 * wave(17, 1))

            // Aurora: a faint teal wisp wandering through the middle.
            RadialGradient(colors: [Color(red: 0.10, green: 0.45, blue: 0.50).opacity(0.34 + 0.14 * wave(12, 4)), .clear],
                           center: UnitPoint(x: 0.5 + 0.4 * wave(33, 5), y: 0.45 + 0.3 * wave(26, 6)),
                           startRadius: 0, endRadius: 320 + 80 * wave(15, 2))

            // A fainter magenta wisp, on a different path.
            RadialGradient(colors: [Color(red: 0.45, green: 0.12, blue: 0.45).opacity(0.3 + 0.12 * wave(14, 1)), .clear],
                           center: UnitPoint(x: 0.35 + 0.35 * wave(27, 2), y: 0.68 + 0.24 * wave(21, 4)),
                           startRadius: 0, endRadius: 300 + 60 * wave(16, 3))
        }
    }
}

/// The background behind full screens: `SpaceGradient` with a starfield.
struct AppGradientBackground: View {
    var stars: Int = 40
    /// False for images rendered with `ImageRenderer`.
    var animated = true

    var body: some View {
        ZStack {
            SpaceGradient(animated: animated)
                .ignoresSafeArea()

            StarFieldView(count: stars, animated: animated)
        }
    }
}

/// Kept for the screens that already use it; now the same as
/// `AppGradientBackground`.
struct SpaceBackground: View {
    var stars: Int = 60

    var body: some View {
        AppGradientBackground(stars: stars)
            .ignoresSafeArea()
    }
}

// MARK: - Cards

/// The thin rule between rows inside an `appCard`.
struct CardDivider: View {
    var body: some View {
        Divider().overlay(Color.white.opacity(0.15))
    }
}

extension View {
    /// Frosted card for panels that float over moving content (the map).
    func glassCard(cornerRadius: CGFloat = 16) -> some View {
        background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Palette.cardStroke, lineWidth: 1)
        )
    }

    /// The rounded panel used on full screens.
    func appCard(cornerRadius: CGFloat = 18) -> some View {
        background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Palette.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Palette.cardStroke, lineWidth: 1)
        )
    }

    /// Inline title over a see-through bar, as on Compare and Settings.
    func appNavigationStyle(_ title: LocalizedStringKey) -> some View {
        navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

// MARK: - Floating hero

/// A planet or the Sun at the top of its detail screen: slowly spinning,
/// gently floating up and down, with a soft halo in its colour that
/// breathes. Clock-driven rather than `repeatForever`, which also animated
/// the sheet's first layout. Holds still with Reduce Motion.
struct FloatingBody: View {
    let imageName: String
    let glow: Color
    let size: CGFloat
    var shadow: Color = .black.opacity(0.4)

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Group {
            if reduceMotion {
                content(at: 0)
            } else {
                TimelineView(.animation(minimumInterval: 1.0 / 30)) { context in
                    content(at: context.date.timeIntervalSinceReferenceDate)
                }
            }
        }
        // The halo spills over; the layout keeps the body's own size.
        .frame(width: size, height: size)
    }

    private func content(at t: Double) -> some View {
        let float = sin(t * 2 * .pi / 5) * 6
        let breath = 1 + 0.07 * sin(t * 2 * .pi / 4)
        let spin = t.truncatingRemainder(dividingBy: 40) / 40 * 360

        return ZStack {
            Circle()
                .fill(RadialGradient(colors: [glow.opacity(0.5), glow.opacity(0)],
                                     center: .center, startRadius: size * 0.3, endRadius: size * 0.8))
                .frame(width: size * 1.6, height: size * 1.6)
                .scaleEffect(breath)

            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .rotationEffect(.degrees(spin))
                .shadow(color: shadow, radius: 14)
        }
        .offset(y: float)
    }
}
