//
//  Tabs.swift
//  Planet
//
//  Created by itkhld on 2024-10-29.
//
//  4 tabs – Solar System (the main screen), AR, Explore, Settings.
//

import SwiftUI

struct Tabs: View {
    @Binding var selectedTab: Int

    var body: some View {
        TabView(selection: $selectedTab) {
            Group {
                HomeView()
                    .tabItem {
                        Label("Solar System", systemImage: "gyroscope")
                    }
                    .tag(0)

                // No safe-area override here: the camera feed already fills
                // the screen, and the controls must stay clear of the status
                // bar and the tab bar.
                ARPlanetView()
                    .tabItem {
                        Label("AR", systemImage: "camera.viewfinder")
                    }
                    .tag(1)

                ExploreTabView()
                    .tabItem {
                        Label("Explore", systemImage: "square.grid.2x2")
                    }
                    .tag(2)

                NavigationStack {
                    SettingsView()
                }
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
                    .tag(3)
            }
            .toolbarBackground(.hidden, for: .tabBar)
        }
        .tint(.cyan)
        .onChange(of: selectedTab) {
            playHaptic()
        }
    }
}

// MARK: - Explore Tab

/// Every feature in one place, grouped into cards. Styled like the Settings
/// and Solar System tabs: the same gradient, an inline title over a clear
/// navigation bar, and dark rounded cards with a labelled header.
struct ExploreTabView: View {
    private var isPhone: Bool { deviceType() == "iPhone" }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [.black, Color("GradientColor"), .purple]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                StarFieldView(count: 40)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        ForEach(AppFeature.Section.allCases) { section in
                            card(for: section)
                        }
                    }
                    .padding()
                    .frame(maxWidth: 700)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle("Explore")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    // MARK: Building blocks

    private func card(for section: AppFeature.Section) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(section.title, systemImage: section.icon)
                .font(AppFont.bold(isPhone ? 17 : 24))
                .foregroundColor(.white)

            VStack(spacing: 10) {
                ForEach(section.features) { feature in
                    FeatureButton(feature: feature) {
                        row(for: feature)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.black.opacity(0.28))
        .cornerRadius(18)
    }

    private func row(for feature: AppFeature) -> some View {
        HStack(spacing: 12) {
            Image(systemName: feature.icon)
                .font(.system(size: isPhone ? 16 : 22, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: isPhone ? 34 : 46, height: isPhone ? 34 : 46)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(LinearGradient(colors: feature.gradient,
                                             startPoint: .topLeading,
                                             endPoint: .bottomTrailing))
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(feature.title)
                    .font(AppFont.regular(isPhone ? 15 : 21))
                    .foregroundColor(.white)
                Text(feature.subtitle)
                    .font(AppFont.regular(isPhone ? 12 : 17))
                    .foregroundColor(.white.opacity(0.5))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }

            Spacer(minLength: 4)

            Image(systemName: "chevron.forward")
                .font(.system(size: isPhone ? 12 : 16, weight: .semibold))
                .foregroundColor(.white.opacity(0.4))
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(Color.white.opacity(0.12))
        .cornerRadius(14)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    @Previewable @State var previewSelectedTab: Int = 0
    Tabs(selectedTab: $previewSelectedTab)
}
