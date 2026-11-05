//
//  PlanetListView.swift
//  Planet
//

import SwiftUI

/// A browsable, searchable index of everything in the app — the orbiting dots
/// on the map are small and easy to miss, so this is the reliable way in.
struct PlanetListView: View {
    @State private var searchText = ""

    private var isPhone: Bool { deviceType() == "iPhone" }

    /// Matches on name, the short description, and the full Read More text, so
    /// searching "Olympus" or "Titan" finds the right planet.
    private var matchingPlanets: [Planet] {
        guard !trimmedSearch.isEmpty else { return planets }
        return planets.filter { planet in
            matches(planet.name)
                || matches(planet.name.localizedBodyName)
                || matches(planet.localizedDescription)
                || matches(PlanetDetails.getDescription(for: planet.name))
        }
    }

    private var sunMatches: Bool {
        guard !trimmedSearch.isEmpty else { return true }
        return matches(sun.name) || matches(sun.name.localizedBodyName)
            || matches(sun.localizedDescription)
            || matches(PlanetDetails.getDescription(for: sun.name))
    }

    private var trimmedSearch: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func matches(_ text: String) -> Bool {
        text.localizedCaseInsensitiveContains(trimmedSearch)
    }

    /// Moons matching the search, so typing "Titan" or "Europa" surfaces the
    /// moons entry rather than coming up empty.
    private var matchingMoons: [Moon] {
        guard !trimmedSearch.isEmpty else { return Moon.all }
        return Moon.all.filter {
            matches($0.name) || matches($0.name.localizedBodyName)
                || matches($0.planet) || matches($0.localizedTagline) || matches($0.localizedDescription)
        }
    }

    private var overviewMatches: Bool {
        guard !trimmedSearch.isEmpty else { return true }
        return matches("The Solar System")
            || matches(PlanetDetails.getDescription(for: "Solar System"))
    }

    private var hasResults: Bool {
        overviewMatches || sunMatches || !matchingPlanets.isEmpty || !matchingMoons.isEmpty
    }

    private var moonsRow: some View {
        HStack(spacing: 16) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: isPhone ? 24 : 32))
                .foregroundColor(.white)
                .frame(width: isPhone ? 46 : 64, height: isPhone ? 46 : 64)

            VStack(alignment: .leading, spacing: 3) {
                Text("Moons")
                    .font(AppFont.bold(isPhone ? 18 : 26))
                    .foregroundColor(.white)
                Text(trimmedSearch.isEmpty
                     ? "\(Moon.all.count) notable moons"
                     : "\(matchingMoons.count) matching")
                    .font(AppFont.regular(isPhone ? 13 : 19))
                    .foregroundColor(Palette.secondaryText)
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.system(size: isPhone ? 14 : 20, weight: .semibold))
                .foregroundColor(Palette.secondaryText)
        }
        .padding(isPhone ? 14 : 20)
        .background(Palette.card)
        .cornerRadius(20)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                SpaceGradient()
                .ignoresSafeArea()

                StarFieldView(count: 40)

                if hasResults {
                    list
                } else {
                    emptyState
                }
            }
            .navigationTitle("Explore")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        ComparePlanetsView()
                    } label: {
                        Image(systemName: "arrow.left.and.right.square")
                    }
                    .accessibilityLabel("Compare planets")
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search planets, moons, features")
    }

    private var list: some View {
        ScrollView {
            VStack(spacing: 12) {
                if overviewMatches {
                    NavigationLink {
                        PlanetsReadmoreView(planetName: "Solar System", imageName: "solar system")
                    } label: {
                        row(imageName: "solar system",
                            name: String(localized: "The Solar System", bundle: Bundle.appLanguage),
                            subtitle: String(localized: "How it formed, and what's in it", bundle: Bundle.appLanguage))
                    }
                }

                if sunMatches {
                    NavigationLink {
                        SunDetailView(star: sun)
                    } label: {
                        row(imageName: sun.imageName, name: sun.name.localizedBodyName, subtitle: String(localized: "Our star", bundle: Bundle.appLanguage))
                    }
                }

                ForEach(matchingPlanets) { planet in
                    NavigationLink {
                        PlanetDetailView(planet: planet)
                    } label: {
                        row(imageName: planet.imageName,
                            name: planet.name.localizedBodyName,
                            subtitle: distanceText(for: planet))
                    }
                }

                if matchingMoons.isEmpty == false {
                    NavigationLink {
                        MoonsView()
                    } label: {
                        moonsRow
                    }
                }
            }
            .padding()
        }
        .scrollDismissesKeyboard(.immediately)
    }

    /// `Planet.distanceFromSun` is a pre-formatted English string ("57.9
    /// million km"), so it can't be localized. The numeric table can.
    private func distanceText(for planet: Planet) -> String {
        guard let metrics = PlanetMetrics.metrics(for: planet.name) else {
            return planet.distanceFromSun
        }
        return MetricFormat.km(metrics.distanceFromSunKm)
    }

    private func row(imageName: String, name: String, subtitle: String) -> some View {
        HStack(spacing: 16) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: isPhone ? 46 : 64, height: isPhone ? 46 : 64)

            VStack(alignment: .leading, spacing: 3) {
                Text(name)
                    .font(AppFont.bold(isPhone ? 18 : 26))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(AppFont.regular(isPhone ? 13 : 19))
                    .foregroundColor(Palette.secondaryText)
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.system(size: isPhone ? 14 : 20, weight: .semibold))
                .foregroundColor(Palette.secondaryText)
        }
        .padding(isPhone ? 14 : 20)
        .background(Palette.card)
        .cornerRadius(20)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(Palette.secondaryText)
            Text("No matches for \"\(trimmedSearch)\"")
                .font(AppFont.regular(isPhone ? 16 : 22))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

#Preview {
    PlanetListView()
}
