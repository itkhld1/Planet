//
//  SunDetailView.swift
//  Planet
//
//  Created by itkhld on 2024-10-31.
//

import SwiftUI

struct SunDetailView: View {
    let star: Star
    @State private var showDetailInfo = false
    private let numberOfStars = 100

    private var heroSize: CGFloat { deviceType() == "iPhone" ? 170 : 260 }

    var body: some View {
        ZStack {
            // Static gradient — fills the sheet immediately and never wipes in
            // from a corner (and no repeating animation to accumulate).
            // Deep space with the Sun's warmth glowing from the top: warm
            // without the glare of the old orange-to-yellow wash.
            ZStack {
                SpaceGradient(tint: Palette.amber, tintStrength: 0.35)
                RadialGradient(colors: [Palette.amber.opacity(0.45), Palette.warning.opacity(0.12), .clear],
                               center: .top, startRadius: 0, endRadius: 420)
            }
            .ignoresSafeArea()

            StarFieldView(count: numberOfStars)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    hero
                    statsCard
                    descriptionCard
                    readMoreButton
                }
                .padding()
                .padding(.top, 12)
            }
        }
        .sheet(isPresented: $showDetailInfo) {
            PlanetsReadmoreView(planetName: star.name)
                .appLanguageEnvironment()
                .presentationDetents([.height(550), .large])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Hero

    private var hero: some View {
        VStack(spacing: 14) {
            FloatingBody(imageName: star.imageName, glow: Palette.amber, size: heroSize,
                         shadow: Palette.amber.opacity(0.6))
                .accessibilityLabel("\(star.name.localizedBodyName) globe")

            Text(star.name.localizedBodyName)
                .font(AppFont.bold(deviceType() == "iPhone" ? 34 : 48))
                .foregroundColor(.white)
                .shadow(radius: 3)
        }
    }

    // MARK: - Stats

    private var statsCard: some View {
        VStack(spacing: 0) {
            statRow(icon: "circle.dashed", label: "Diameter", value: star.diameter.localizedFromCatalog)
            Divider().overlay(Color.white.opacity(0.15))
            statRow(icon: "scope", label: "Distance from Center", value: star.distanceFromCenter.localizedFromCatalog)
            Divider().overlay(Color.white.opacity(0.15))
            statRow(icon: "thermometer.sun.fill", label: "Surface Temperature", value: star.surfaceTemperature.localizedFromCatalog)
        }
        .padding(.vertical, 6)
        .background(Palette.card)
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
        Text(star.localizedDescription)
            .font(AppFont.regular(deviceType() == "iPhone" ? 15 : 20))
            .lineSpacing(4)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Palette.card)
            .cornerRadius(18)
    }

    // MARK: - Button

    private var readMoreButton: some View {
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
        .padding(.top, 4)
    }
}
