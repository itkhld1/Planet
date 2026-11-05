//
//  PlanetDetailView.swift
//  Planet
//
//  Created by itkhld on 2024-09-30.
//

import SwiftUI
import SceneKit

struct PlanetDetailView: View {
    let planet: Planet
    @State private var showDetailInfo = false
    @State private var show3DModel = false
    @State private var showMoons = false
    @State private var rotatePlanet = false
    private let numberOfStars = 100

    private var moons: [Moon] { Moon.moons(of: planet.name) }

    private var heroSize: CGFloat { deviceType() == "iPhone" ? 170 : 260 }

    var body: some View {
        ZStack {
            // Static gradient — fills the sheet immediately and never wipes in
            // from a corner (and no repeating animation to accumulate).
            LinearGradient(
                gradient: Gradient(colors: [Color("D1"), Color("D2"), Color("D3"), Color("D4")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            StarFieldView(count: numberOfStars)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    hero
                    statsCard
                    descriptionCard
                    actionButtons
                }
                .padding()
                .padding(.top, 12)
            }
        }
        .sheet(isPresented: $show3DModel) {
            ViewControllerWrapper(planet: planet)
                .ignoresSafeArea()
                .presentationDragIndicator(.visible)
                .presentationDetents([.large])
        }
        .sheet(isPresented: $showDetailInfo) {
            PlanetsReadmoreView(planetName: planet.name)
                .appLanguageEnvironment()
                .presentationDetents([.height(550), .large])
                .presentationDragIndicator(.visible)
        }
        // Wrapped in its own stack because this view is presented as a sheet
        // from the map, where there's no navigation stack to push onto.
        .sheet(isPresented: $showMoons) {
            NavigationStack {
                MoonsView(planetFilter: planet.name)
            }
            .appLanguageEnvironment()
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Hero

    private var hero: some View {
        VStack(spacing: 14) {
            Image(planet.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: heroSize, height: heroSize)
                .rotationEffect(.degrees(rotatePlanet ? 360 : 0))
                .shadow(color: .black.opacity(0.4), radius: 12)
                .onAppear {
                    withAnimation(.linear(duration: 40).repeatForever(autoreverses: false)) {
                        rotatePlanet = true
                    }
                }
                .accessibilityLabel("\(planet.name.localizedBodyName) globe")

            Text(planet.name.localizedBodyName)
                .font(AppFont.bold(deviceType() == "iPhone" ? 34 : 48))
                .foregroundColor(.white)
                .shadow(radius: 3)
        }
    }

    // MARK: - Stats

    /// The figures stored on `Planet` are pre-formatted English strings
    /// ("12,742 km", "24 hours"), so they can't localize or use Persian
    /// digits. `PlanetMetrics` holds the same values as numbers, which
    /// `MetricFormat` renders in the current language.
    private var metrics: PlanetMetrics? { PlanetMetrics.metrics(for: planet.name) }

    private var statsCard: some View {
        VStack(spacing: 0) {
            statRow(icon: "circle.dashed", label: "Diameter",
                    value: metrics.map { MetricFormat.km($0.diameterKm) } ?? planet.diameter)
            Divider().overlay(Color.white.opacity(0.15))
            statRow(icon: "sun.max.fill", label: "Distance from Sun",
                    value: metrics.map { MetricFormat.km($0.distanceFromSunKm) } ?? planet.distanceFromSun)
            Divider().overlay(Color.white.opacity(0.15))
            statRow(icon: "clock.fill", label: "Day Length",
                    value: metrics.map { MetricFormat.hours($0.dayLengthHours) } ?? planet.dayLength)
        }
        .padding(.vertical, 6)
        .background(Color.black.opacity(0.28))
        .cornerRadius(18)
    }

    private func statRow(icon: String, label: LocalizedStringKey, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundColor(.white.opacity(0.9))
            Text(label)
                .foregroundColor(.white.opacity(0.75))
            Spacer(minLength: 12)
            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .multilineTextAlignment(.trailing)
        }
        .font(AppFont.regular(deviceType() == "iPhone" ? 15 : 22))
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
    }

    // MARK: - Description

    private var descriptionCard: some View {
        Text(planet.localizedDescription)
            .font(AppFont.regular(deviceType() == "iPhone" ? 15 : 20))
            .lineSpacing(4)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Color.black.opacity(0.28))
            .cornerRadius(18)
    }

    // MARK: - Buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                playHaptic()
                show3DModel.toggle()
            } label: {
                Label("Explore \(planet.name.localizedBodyName) in 3D", systemImage: "rotate.3d")
                    .font(AppFont.bold(deviceType() == "iPhone" ? 16 : 22))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.blue.opacity(0.85))
                    .foregroundColor(.white)
                    .cornerRadius(30)
            }

            Button {
                playHaptic()
                showDetailInfo.toggle()
            } label: {
                Label("Read More", systemImage: "text.justify.left")
                    .font(AppFont.bold(deviceType() == "iPhone" ? 16 : 22))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.white.opacity(0.15))
                    .foregroundColor(.white)
                    .cornerRadius(30)
            }

            // Mercury and Venus have none, so there'd be nothing to show.
            if !moons.isEmpty {
                Button {
                    playHaptic()
                    showMoons.toggle()
                } label: {
                    Label("Moons (\(moons.count))", systemImage: "moon.stars.fill")
                        .font(AppFont.bold(deviceType() == "iPhone" ? 16 : 22))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.white.opacity(0.15))
                        .foregroundColor(.white)
                        .cornerRadius(30)
                }
            }
        }
        .padding(.top, 4)
    }
}
