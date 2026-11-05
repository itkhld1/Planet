//
//  AppInstruction.swift
//  Planet
//
//  Created by itkhld on 2024-12-01.
//

import SwiftUI

/// A page in the first-launch walkthrough.
private struct OnboardingPage: Identifiable {
    let id = UUID()
    let symbol: String
    let title: String
    let body: String
}

struct AppInstruction: View {
    /// Written only when the walkthrough is finished or skipped — never on
    /// appear, which would tear this view down before it could be read.
    @AppStorage("AppInstruction") private var hasSeenInstruction = false

    @State private var currentPage = 0

    private var isPhone: Bool { deviceType() == "iPhone" }

    private let pages = [
        OnboardingPage(
            symbol: "sparkles",
            title: "Welcome to Planet",
            body: "Your guide to exploring the solar system — built to make learning about the planets fun, with 3D models, animations and quizzes."
        ),
        OnboardingPage(
            symbol: "gyroscope",
            title: "Explore the Solar System",
            body: "Pinch to zoom and drag to pan around the orbits. Tap any planet — or the Sun — to see its details, then open it in interactive 3D."
        ),
        OnboardingPage(
            symbol: "brain.head.profile.fill",
            title: "Test Your Knowledge",
            body: "Answer 10 random questions drawn from a pool of over 130. Every quiz is different, so keep playing to beat your high score."
        ),
        OnboardingPage(
            symbol: "plusminus.circle.fill",
            title: "Weigh In, Anywhere",
            body: "Enter your weight or age on Earth and instantly see how they change on every other planet."
        ),
        OnboardingPage(
            symbol: "atom",
            title: "See Them in 3D",
            body: "The Simulation tab loads a detailed 3D model of any planet you pick. Drag to spin it and pinch to zoom in close."
        )
    ]

    private var isLastPage: Bool { currentPage == pages.count - 1 }

    var body: some View {
        ZStack {
            // Static gradient, matching the rest of the app.
            LinearGradient(
                gradient: Gradient(colors: [.black, Color("GradientColor"), .purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            StarFieldView(count: 80)

            VStack(spacing: 0) {
                skipButton

                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                        pageView(page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))

                advanceButton
                    .padding(.horizontal, isPhone ? 30 : 120)
                    .padding(.bottom, isPhone ? 30 : 50)
            }
        }
    }

    // MARK: - Pages

    private func pageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: isPhone ? 24 : 36) {
            Spacer()

            Image(systemName: page.symbol)
                .font(.system(size: isPhone ? 64 : 96))
                .foregroundColor(.white)
                .shadow(color: .blue.opacity(0.8), radius: 20)

            Text(page.title.localizedFromCatalog)
                .font(AppFont.bold(isPhone ? 28 : 42))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text(page.body.localizedFromCatalog)
                .font(AppFont.regular(isPhone ? 15 : 24))
                .foregroundColor(.white.opacity(0.75))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, isPhone ? 32 : 100)

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }

    // MARK: - Controls

    private var skipButton: some View {
        HStack {
            Spacer()
            if !isLastPage {
                Button("Skip") { finish() }
                    .font(AppFont.regular(isPhone ? 15 : 22))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.trailing, 24)
                    .padding(.top, 12)
                    .transition(.opacity)
            }
        }
        .frame(height: 44)
    }

    private var advanceButton: some View {
        Button {
            playHaptic()
            if isLastPage {
                finish()
            } else {
                withAnimation { currentPage += 1 }
            }
        } label: {
            Text(isLastPage ? "Let's Explore!" : "Next")
                .font(AppFont.bold(isPhone ? 17 : 24))
                .frame(maxWidth: .infinity)
                .padding(.vertical, isPhone ? 15 : 20)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(30)
                .shadow(color: .blue.opacity(0.5), radius: 20)
        }
    }

    private func finish() {
        withAnimation { hasSeenInstruction = true }
    }
}

#Preview {
    AppInstruction()
}
