//
//  SpacePassportView.swift
//  Planet
//
//  The Space Passport: one stamp for every planet reached in Mission Control.
//  All eight are collectable — Earth is stamped by flying home from Mars.
//

import SwiftUI

// MARK: - Planets

/// The planets with stamps, and their ink. Visits are saved in
/// `ProgressStore`.
enum Passport {
    static let planets = ["Mercury", "Venus", "Earth", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune"]

    /// Ink colour for each planet's stamp.
    static func color(_ planet: String) -> Color {
        switch planet {
        case "Mercury": return Color(red: 0.75, green: 0.72, blue: 0.70)
        case "Venus": return Color(red: 0.95, green: 0.78, blue: 0.40)
        case "Earth": return Color(red: 0.35, green: 0.65, blue: 1.0)
        case "Mars": return Color(red: 0.95, green: 0.42, blue: 0.30)
        case "Jupiter": return Color(red: 0.90, green: 0.62, blue: 0.40)
        case "Saturn": return Color(red: 0.93, green: 0.82, blue: 0.55)
        case "Uranus": return Color(red: 0.50, green: 0.88, blue: 0.92)
        default: return Color(red: 0.40, green: 0.52, blue: 1.0)   // Neptune
        }
    }
}

// MARK: - Stamp

/// A postage-stamp style badge. Unvisited planets are shown as a faded
/// silhouette so the collection has visible gaps to fill.
struct PlanetStampView: View {
    let planet: String
    let visited: Bool
    var date: Date? = nil
    var size: CGFloat = 130

    private var ink: Color { Passport.color(planet) }

    var body: some View {
        VStack(spacing: size * 0.05) {
            Image(planet)
                .resizable()
                .scaledToFit()
                .frame(width: size * 0.5, height: size * 0.5)
                .saturation(visited ? 1 : 0)
                .opacity(visited ? 1 : 0.25)
                .overlay {
                    if !visited {
                        Image(systemName: "questionmark")
                            .font(.system(size: size * 0.18, weight: .bold))
                            .foregroundColor(Palette.secondaryText)
                    }
                }
            Text(planet.localizedBodyName)
                .font(AppFont.bold(size * 0.12))
                .foregroundColor(visited ? .white : .white.opacity(0.4))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Group {
                if let date, visited {
                    Text(date.formatted(.dateTime.day().month(.abbreviated).year().locale(AppLanguage.locale)))
                } else if visited {
                    Text("Visited")
                } else {
                    Text("Not visited yet")
                }
            }
            .font(AppFont.regular(size * 0.085))
            .foregroundColor(visited ? ink : .white.opacity(0.35))
            .lineLimit(1)
            .minimumScaleFactor(0.7)
        }
        .padding(size * 0.09)
        .frame(width: size, height: size * 1.12)
        .background(
            RoundedRectangle(cornerRadius: size * 0.06)
                .fill(visited ? ink.opacity(0.14) : Palette.card)
        )
        // Dashed edge for the perforations, solid inner frame for the print.
        .overlay(
            RoundedRectangle(cornerRadius: size * 0.06)
                .stroke(visited ? ink : .white.opacity(0.2),
                        style: StrokeStyle(lineWidth: size * 0.025, dash: [size * 0.03, size * 0.03]))
        )
        .overlay(
            RoundedRectangle(cornerRadius: size * 0.04)
                .stroke(visited ? ink.opacity(0.5) : .clear, lineWidth: 1)
                .padding(size * 0.05)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(visited
            ? Text("\(planet.localizedBodyName), visited")
            : Text("\(planet.localizedBodyName), not visited yet"))
    }
}

// MARK: - Passport screen

struct SpacePassportView: View {
    private var progress: ProgressStore { .shared }
    private var isPhone: Bool { deviceType() == "iPhone" }

    var body: some View {
        let visited = progress.visitedPlanetCount
        ZStack {
            AppGradientBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Image(systemName: "book.closed.fill")
                            .font(.system(size: isPhone ? 40 : 56))
                            .foregroundColor(Palette.accent)
                            .shadow(color: Palette.accent.opacity(0.5), radius: 12)
                        Text("\(MetricFormat.plain(Double(visited), decimals: 0)) / \(MetricFormat.plain(Double(Passport.planets.count), decimals: 0)) planets visited")
                            .font(AppFont.bold(isPhone ? 22 : 30))
                            .foregroundColor(.white)
                        Text(visited == Passport.planets.count
                             ? "Passport complete! You've visited every planet."
                             : "Reach a planet in Mission Control to earn its stamp.")
                            .font(AppFont.regular(isPhone ? 14 : 20))
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .accessibilityElement(children: .combine)

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 14),
                                             count: isPhone ? 2 : 4), spacing: 18) {
                        ForEach(Array(Passport.planets.enumerated()), id: \.element) { i, planet in
                            let isVisited = progress.hasVisited(planet)
                            PlanetStampView(planet: planet, visited: isVisited,
                                            date: progress.firstVisit(to: planet),
                                            size: isPhone ? 140 : 160)
                                // A slight tilt each way, like stamps pressed by hand.
                                .rotationEffect(.degrees(isVisited ? (i.isMultiple(of: 2) ? -3 : 2.5) : 0))
                        }
                    }
                    // Planets read in order from the Sun in every language.
                    .environment(\.layoutDirection, .leftToRight)
                }
                .padding()
                .frame(maxWidth: 700)
                .frame(maxWidth: .infinity)
            }
        }
        .appNavigationStyle("Space Passport")
    }
}

#Preview {
    NavigationStack { SpacePassportView() }
}
