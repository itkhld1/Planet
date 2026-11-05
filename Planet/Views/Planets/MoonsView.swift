//
//  MoonsView.swift
//  Planet
//

import SwiftUI

/// Browsable list of moons. Shows every moon by default, or just one planet's
/// when opened from that planet's detail screen.
struct MoonsView: View {
    /// When set, only this planet's moons are listed.
    var planetFilter: String?

    @State private var searchText = ""

    private var isPhone: Bool { deviceType() == "iPhone" }

    /// Built as a `String` for `navigationTitle`, so both the phrase and the
    /// planet name need looking up explicitly.
    private var title: String {
        guard let planetFilter else { return String(localized: "Moons", bundle: Bundle.appLanguage) }
        return String(format: String(localized: "Moons of %@", bundle: Bundle.appLanguage),
                      planetFilter.localizedBodyName)
    }

    private var trimmedSearch: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var moons: [Moon] {
        let base = planetFilter.map { Moon.moons(of: $0) } ?? Moon.all
        guard !trimmedSearch.isEmpty else { return base }
        // Matches both the English name (still the identity) and the displayed
        // text, so search works in whichever language is on screen.
        return base.filter {
            $0.name.localizedCaseInsensitiveContains(trimmedSearch)
                || $0.name.localizedBodyName.localizedCaseInsensitiveContains(trimmedSearch)
                || $0.planet.localizedCaseInsensitiveContains(trimmedSearch)
                || $0.planet.localizedBodyName.localizedCaseInsensitiveContains(trimmedSearch)
                || $0.localizedTagline.localizedCaseInsensitiveContains(trimmedSearch)
                || $0.localizedDescription.localizedCaseInsensitiveContains(trimmedSearch)
        }
    }

    /// Groups moons under their planet, following the order of `planets`.
    private var grouped: [(planet: String, moons: [Moon])] {
        let names = planets.map(\.name)
        return names.compactMap { name in
            let matching = moons.filter { $0.planet == name }
            return matching.isEmpty ? nil : (name, matching)
        }
    }

    var body: some View {
        ZStack {
            SpaceGradient()
            .ignoresSafeArea()

            StarFieldView(count: 40)

            if grouped.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        ForEach(grouped, id: \.planet) { group in
                            section(group.planet, moons: group.moons)
                        }
                    }
                    .padding()
                    .frame(maxWidth: 700)
                }
                .scrollDismissesKeyboard(.immediately)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .searchable(text: $searchText, prompt: "Search moons")
    }

    @ViewBuilder
    private func section(_ planet: String, moons: [Moon]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // With a filter applied the header would just repeat the title.
            if planetFilter == nil {
                Text(planet.localizedBodyName)
                    .font(AppFont.bold(isPhone ? 20 : 28))
                    .foregroundColor(.white.opacity(0.85))
                    .padding(.leading, 4)
            }

            ForEach(moons) { moon in
                NavigationLink {
                    MoonDetailView(moon: moon)
                } label: {
                    row(moon)
                }
            }
        }
    }

    private func row(_ moon: Moon) -> some View {
        HStack(spacing: 16) {
            MoonBadge(moon: moon, size: isPhone ? 42 : 58)

            VStack(alignment: .leading, spacing: 3) {
                Text(moon.name.localizedBodyName)
                    .font(AppFont.bold(isPhone ? 17 : 24))
                    .foregroundColor(.white)
                Text(moon.localizedTagline)
                    .font(AppFont.regular(isPhone ? 13 : 18))
                    .foregroundColor(Palette.secondaryText)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.system(size: isPhone ? 13 : 18, weight: .semibold))
                .foregroundColor(Palette.secondaryText)
        }
        .padding(isPhone ? 14 : 18)
        .background(Palette.card)
        .cornerRadius(18)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "moon.stars")
                .font(.system(size: 40))
                .foregroundColor(Palette.secondaryText)
            Text(trimmedSearch.isEmpty
                 ? "No moons to show."
                 : "No moons match \"\(trimmedSearch)\"")
                .font(AppFont.regular(isPhone ? 16 : 22))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

/// Stands in for the moon images the asset catalog doesn't have: a tinted
/// sphere with a soft highlight so each moon still reads as a world.
struct MoonBadge: View {
    let moon: Moon
    var size: CGFloat

    var body: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [moon.tint, moon.tint.opacity(0.45)],
                    center: UnitPoint(x: 0.35, y: 0.32),
                    startRadius: 1,
                    endRadius: size * 0.75
                )
            )
            .frame(width: size, height: size)
            .overlay(
                Circle().stroke(Color.white.opacity(0.18), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.35), radius: 5)
            .accessibilityHidden(true)
    }
}

struct MoonDetailView: View {
    let moon: Moon

    private var isPhone: Bool { deviceType() == "iPhone" }

    var body: some View {
        ZStack {
            SpaceGradient()
            .ignoresSafeArea()

            StarFieldView(count: 60)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    MoonBadge(moon: moon, size: isPhone ? 140 : 210)
                        .padding(.top, 10)

                    VStack(spacing: 6) {
                        Text(moon.name.localizedBodyName)
                            .font(AppFont.bold(isPhone ? 30 : 44))
                            .foregroundColor(.white)
                        Text("Orbits \(moon.planet.localizedBodyName)")
                            .font(AppFont.regular(isPhone ? 14 : 20))
                            .foregroundColor(Palette.secondaryText)
                    }

                    statsCard

                    Text(moon.localizedDescription)
                        .font(AppFont.regular(isPhone ? 15 : 20))
                        .lineSpacing(4)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                        .background(Palette.card)
                        .cornerRadius(18)

                    factsCard
                }
                .padding()
                .frame(maxWidth: 700)
            }
        }
        .navigationTitle(moon.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private var statsCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "circle.dashed")
                .foregroundColor(.white.opacity(0.9))
            Text("Diameter")
                .foregroundColor(.white.opacity(0.75))
            Spacer(minLength: 12)
            Text(moon.localizedDiameter)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .font(AppFont.regular(isPhone ? 15 : 22))
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Palette.card)
        .cornerRadius(18)
        .accessibilityElement(children: .combine)
    }

    private var factsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Highlights")
                .font(AppFont.bold(isPhone ? 18 : 25))
                .foregroundColor(.white)

            ForEach(moon.localizedFacts, id: \.self) { fact in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "sparkle")
                        .font(.system(size: isPhone ? 12 : 16))
                        .foregroundColor(Palette.amber)
                        .padding(.top, 3)
                    Text(fact)
                        .font(AppFont.regular(isPhone ? 14 : 19))
                        .foregroundColor(.white.opacity(0.85))
                        .lineSpacing(3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .accessibilityElement(children: .combine)
            }
        }
        .padding(16)
        .background(Palette.card)
        .cornerRadius(18)
    }
}

#Preview {
    NavigationStack {
        MoonsView()
    }
}
