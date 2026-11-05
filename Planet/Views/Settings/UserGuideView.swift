//
//  UserGuideView.swift
//  Planet
//
//  Created by itkhld on 2024-11-03.
//

import SwiftUI

struct UserGuideView: View {

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        // Built as a String, so `Text(appVersion)` would render it verbatim —
        // the lookup has to happen here.
        return String(format: String(localized: "Version %@", bundle: Bundle.appLanguage), version)
    }

    var body: some View {

        VStack(spacing: 0) {
            // Hero
            VStack(spacing: 10) {
                Image(systemName: "globe.europe.africa.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.accentColor)

                Text("Planets Solar System")
                    .font(.title2).fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("Your interactive guide to exploring the solar system — built to make learning about the planets fun for **curious minds of all ages**, with 3D models, animations, quizzes and more.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.horizontal)
            .padding(.top, 24)
            .padding(.bottom, 16)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    Text("How to use the app")
                        .font(.subheadline).fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 4)

                    GuideRow(
                        symbol: "gyroscope",
                        text: "**Solar System Tab**: Check out our solar system with each planet in its orbit. You can zoom in or out and pan anywhere you like. ***Explore Each Planet:*** Tap any planet to open a pop-up with a picture and a short description. ***Read More:*** Learn even more by tapping ***Read More***. ***3D Exploration:*** Tap ***Explore Planet 3D*** to see the planet in 3D — use the zoom buttons to take a closer look, and tap ***Show Planet*** to display its interactive 3D model."
                    )

                    GuideRow(
                        symbol: "brain.head.profile.fill",
                        text: "**Quiz Tab:** Answer 10 random questions about the solar system. Each quiz is different, so you can keep learning with fresh questions — and beat your high score!"
                    )

                    GuideRow(
                        symbol: "plusminus.circle.fill",
                        text: "**Calculator Tab:** Enter your weight or age on Earth and instantly see how much you'd weigh and how old you'd be on every other planet."
                    )

                    GuideRow(
                        symbol: "atom",
                        text: "**Simulation Tab:** Explore a 3D simulation of the planets. Tap any planet to load its detailed 3D model."
                    )

                    GuideRow(
                        symbol: "rotate.3d.fill",
                        text: "**Solar System 3D (top-left):** Dive into a full 3D model of the entire solar system. Move around to see the planets, their positions, and how they orbit the Sun."
                    )
                }
                .padding(20)
            }

            Text(appVersion)
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.bottom, 12)
        }
    }

}

struct GuideRow: View {
    var symbol: String
    var text: String

    /// `text` arrives as a `String`, so it's looked up explicitly — the markdown
    /// has to survive the round trip, which is why it isn't a LocalizedStringKey.
    private var attributedText: AttributedString {
        let localized = text.localizedFromCatalog
        return (try? AttributedString(markdown: localized)) ?? AttributedString(localized)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: symbol)
                .resizable()
                .scaledToFit()
                .foregroundColor(Color.accentColor)
                .frame(width: 20, height: 20)
                .padding(10)
                .background(Color.accentColor.opacity(0.12))
                .cornerRadius(10)

            Text(attributedText)
                .font(.footnote)
                .lineSpacing(1.5)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color.secondary.opacity(0.08))
        .cornerRadius(16)
    }
}

#Preview {
    UserGuideView()
}
