//
//  MainHomeView.swift
//  Planet
//
//  The Home tab. Built from the same pieces as the other tabs —
//  `SpaceBackground`, `glassCard`, a large navigation title and cyan accents —
//  so it reads as part of the same app:
//  - Featured worlds carousel (a different planet leads each day)
//  - Star Gazer card that jumps to the AR tab
//  - A short list of features, with a link to the full Explore tab
//

import SwiftUI

// MARK: - Recommendation Card Model

struct RecommendationCard: Identifiable {
    let id = UUID()
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let imageName: String       // asset catalogue name, also the planet's name
}

// MARK: - Main Home View

struct MainHomeView: View {

    /// The tab bar's selection, so Home can switch to AR or Explore instead of
    /// opening a second copy of those screens in a sheet.
    @Binding var selectedTab: Int

    @State private var showSearch = false
    @State private var selectedPlanet: Planet?

    private let arTab = 2
    private let exploreTab = 3

    /// Current date in the app's language (Persian gets the Persian calendar).
    private var formattedDate: String {
        Date().formatted(.dateTime.weekday(.wide).day().month(.wide).locale(AppLanguage.locale))
    }

    /// Featured worlds. A different one leads each day so Home doesn't look
    /// identical every time it's opened.
    private var recommendations: [RecommendationCard] {
        let all = [
            RecommendationCard(title: "Mars", subtitle: "Home of Olympus Mons, the tallest volcano we know", imageName: "Mars"),
            RecommendationCard(title: "Jupiter", subtitle: "Its Great Red Spot is a storm wider than Earth", imageName: "Jupiter"),
            RecommendationCard(title: "Venus", subtitle: "A day there lasts longer than its year", imageName: "Venus"),
            RecommendationCard(title: "Saturn", subtitle: "Light enough to float in a giant bathtub", imageName: "Saturn"),
            RecommendationCard(title: "Neptune", subtitle: "The windiest planet, over 2,000 km/h", imageName: "Neptune"),
            RecommendationCard(title: "Uranus", subtitle: "Spins on its side, rolling around the Sun", imageName: "Uranus"),
            RecommendationCard(title: "Mercury", subtitle: "From 430 °C by day to −180 °C at night", imageName: "Mercury"),
            RecommendationCard(title: "Earth", subtitle: "The only world known to have life", imageName: "Earth")
        ]
        let day = Calendar.current.ordinality(of: .day, in: .era, for: Date()) ?? 0
        let start = day % all.count
        return Array(all[start...] + all[..<start])
    }

    /// The handful of features surfaced on Home; the rest live in Explore.
    private let quickFeatures: [AppFeature] = [.spaceWeather, .missionBuilder, .encyclopedia, .quiz]

    var body: some View {
        NavigationStack {
            ZStack {
                SpaceBackground(stars: 60)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        Text(formattedDate)
                            .font(AppFont.regular(14))
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.horizontal, 20)
                            .padding(.top, -8)

                        recommendationsSection
                        starGazerCard
                        quickActionsSection
                    }
                    .padding(.vertical, 16)
                    .frame(maxWidth: 700)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        playHaptic(.light)
                        showSearch = true
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .accessibilityLabel("Search planets")
                }
            }
            .sheet(isPresented: $showSearch) {
                PlanetListView()
                    .appLanguageEnvironment()
                    .presentationDragIndicator(.visible)
            }
            .sheet(item: $selectedPlanet) { planet in
                PlanetDetailView(planet: planet)
                    .appLanguageEnvironment()
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.large])
            }
        }
    }

    // MARK: - Section header

    private func sectionHeader(_ title: LocalizedStringKey, action: (() -> Void)? = nil) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(AppFont.bold(18))
                .foregroundColor(.white)

            Spacer()

            if let action {
                Button {
                    playHaptic(.light)
                    action()
                } label: {
                    Text("See all")
                        .font(AppFont.regular(14))
                        .foregroundColor(.cyan)
                }
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Featured worlds

    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Featured worlds")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(recommendations) { card in
                        recommendationCardView(card)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private func recommendationCardView(_ card: RecommendationCard) -> some View {
        Button {
            if let planet = planets.first(where: { $0.name == card.imageName }) {
                playHaptic(.light)
                selectedPlanet = planet
            }
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                Image(card.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 72, height: 72)
                    .shadow(color: .cyan.opacity(0.25), radius: 12)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)

                HStack {
                    Text(card.title)
                        .font(AppFont.bold(16))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Spacer(minLength: 4)
                    Image(systemName: "chevron.forward")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.4))
                }

                Text(card.subtitle)
                    .font(AppFont.regular(12))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(3, reservesSpace: true)
                    .multilineTextAlignment(.leading)
            }
            .padding(14)
            .frame(width: 170)
            .glassCard(cornerRadius: 14)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }

    // MARK: - Star Gazer

    /// Switches to the AR tab rather than opening a second AR session in a sheet.
    private var starGazerCard: some View {
        Button {
            selectedTab = arTab
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.cyan.opacity(0.8), .purple.opacity(0.8)],
                                             startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 52, height: 52)
                        .shadow(color: .cyan.opacity(0.4), radius: 10)
                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Star Gazer")
                        .font(AppFont.bold(16))
                        .foregroundColor(.white)
                    Text("Place the planets around you in AR")
                        .font(AppFont.regular(12))
                        .foregroundColor(.white.opacity(0.6))
                }

                Spacer()

                Image(systemName: "chevron.forward")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(14)
            .glassCard(cornerRadius: 14)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
        .accessibilityLabel("Launch Star Gazer AR experience")
    }

    // MARK: - Quick actions

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Explore") { selectedTab = exploreTab }

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(quickFeatures) { feature in
                    FeatureButton(feature: feature) {
                        quickActionCard(feature)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private func quickActionCard(_ feature: AppFeature) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: feature.icon)
                .font(.title3)
                .foregroundColor(.cyan)
                .frame(height: 24)

            Text(feature.title)
                .font(AppFont.bold(14))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text(feature.subtitle)
                .font(AppFont.regular(11))
                .foregroundColor(.white.opacity(0.6))
                .lineLimit(2, reservesSpace: true)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .glassCard(cornerRadius: 14)
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var tab = 0
    MainHomeView(selectedTab: $tab)
}
