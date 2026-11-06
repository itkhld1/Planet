//
//  AppInstruction.swift
//  Planet
//
//  Created by itkhld on 2024-12-01.
//

import SwiftUI

/// A page in the first-launch walkthrough.
private struct OnboardingPage: Identifiable {
    enum Scene { case welcome, explore, quiz, weigh, threeD }

    let id = UUID()
    let scene: Scene
    /// Colours the nebula behind the page.
    let tint: Color
    let title: String
    let body: String
}

struct AppInstruction: View {
    /// Written only when the walkthrough is finished or skipped — never on
    /// appear, which would tear this view down before it could be read.
    @AppStorage("AppInstruction") private var hasSeenInstruction = false

    @State private var currentPage = 0

    /// The page whose content has finished coming in. Cleared whenever the
    /// page changes, so the next one's scene, title and text can arrive in
    /// turn.
    @State private var settledPage: Int?

    /// Set when "Let's Explore!" is tapped: the content rushes forward and
    /// fades while confetti falls, then the walkthrough closes.
    @State private var launching = false
    @State private var confettiStart: Date?

    /// Counts taps on the scenes; each one sends the scene spinning.
    @State private var heroTaps = 0

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var isPhone: Bool { deviceType() == "iPhone" }

    private let pages = [
        OnboardingPage(
            scene: .welcome,
            tint: Palette.amber,
            title: "Welcome to Planet",
            body: "Your guide to exploring the solar system — built to make learning about the planets fun, with 3D models, animations and quizzes."
        ),
        OnboardingPage(
            scene: .explore,
            tint: Palette.color(forPlanet: "Earth"),
            title: "Explore the Solar System",
            body: "Pinch to zoom and drag to pan around the orbits. Tap any planet — or the Sun — to see its details, then open it in interactive 3D."
        ),
        OnboardingPage(
            scene: .quiz,
            tint: Color(red: 0.58, green: 0.36, blue: 0.95),
            title: "Test Your Knowledge",
            body: "Answer 10 random questions drawn from a pool of over 200. Every quiz is different, so keep playing to beat your high score."
        ),
        OnboardingPage(
            scene: .weigh,
            tint: Palette.color(forPlanet: "Mars"),
            title: "Weigh In, Anywhere",
            body: "Enter your weight or age on Earth and instantly see how they change on every other planet."
        ),
        OnboardingPage(
            scene: .threeD,
            tint: Palette.color(forPlanet: "Saturn"),
            title: "See Them in 3D",
            body: "The Simulation tab loads a detailed 3D model of any planet you pick. Drag to spin it and pinch to zoom in close."
        )
    ]

    private var isLastPage: Bool { currentPage == pages.count - 1 }

    var body: some View {
        ZStack {
            background

            VStack(spacing: 0) {
                skipButton

                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                        pageView(page, active: index == currentPage, settled: reduceMotion || settledPage == index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .onAppear { settle(currentPage) }
                .onChange(of: currentPage) { _, page in
                    settledPage = nil
                    settle(page)
                }

                pageIndicator
                    .padding(.bottom, isPhone ? 22 : 32)

                advanceButton
                    .padding(.horizontal, isPhone ? 30 : 120)
                    .padding(.bottom, isPhone ? 30 : 50)
            }
            .scaleEffect(launching ? 1.18 : 1)
            .opacity(launching ? 0 : 1)
            .allowsHitTesting(!launching)

            if let confettiStart {
                ConfettiView(start: confettiStart)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }
        }
    }

    // MARK: - Background

    @Environment(\.layoutDirection) private var layoutDirection

    /// The app's drifting nebula, washed in the current page's colour, under
    /// two layers of stars that slide at different speeds as the pages
    /// turn, so swiping feels like moving through space.
    private var background: some View {
        ZStack {
            SpaceGradient()

            // One glow per page, cross-fading: opacity always animates
            // smoothly, where a changing gradient colour may not.
            ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                ZStack {
                    RadialGradient(colors: [page.tint.opacity(0.42), .clear],
                                   center: UnitPoint(x: 0.5, y: 0.95), startRadius: 0, endRadius: 520)
                    RadialGradient(colors: [page.tint.opacity(0.18), .clear],
                                   center: UnitPoint(x: 0.5, y: 0.3), startRadius: 0, endRadius: 300)
                }
                .opacity(index == currentPage ? 1 : 0)
            }

            starLayer(count: 70, travel: 22)
            starLayer(count: 28, travel: 55)
        }
        .ignoresSafeArea()
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.9), value: currentPage)
    }

    /// Stars wider than the screen, shifted `travel` points per page.
    private func starLayer(count: Int, travel: CGFloat) -> some View {
        let direction: CGFloat = layoutDirection == .rightToLeft ? 1 : -1
        let span = travel * CGFloat(pages.count - 1)
        return GeometryReader { proxy in
            StarFieldView(count: count)
                .frame(width: proxy.size.width + span, height: proxy.size.height)
                .offset(x: reduceMotion ? 0 : direction * travel * CGFloat(currentPage)
                        - (direction > 0 ? span : 0))
        }
        // Placed left to right in every language, so the offsets above
        // mean the same thing; only the direction of travel flips.
        .environment(\.layoutDirection, .leftToRight)
    }

    // MARK: - Pages

    private var heroSize: CGFloat { isPhone ? 250 : 400 }

    private func pageView(_ page: OnboardingPage, active: Bool, settled: Bool) -> some View {
        VStack(spacing: isPhone ? 24 : 36) {
            Spacer()

            hero(for: page.scene, active: active)
                .frame(width: heroSize, height: heroSize)
                .accessibilityHidden(true)
                // Never fully hidden, so a page dragged half into view
                // isn't empty.
                .scaleEffect(settled ? 1 : 0.86)
                .opacity(settled ? 1 : 0.35)
                .animation(entrance(step: 0, settled: settled), value: settled)
                .modifier(HeroTapResponse(scene: page.scene, taps: heroTaps))
                .contentShape(Circle())
                .onTapGesture {
                    playHaptic(.light)
                    guard !reduceMotion else { return }
                    withAnimation(.spring(response: 0.9, dampingFraction: 0.72)) { heroTaps += 1 }
                }

            Text(page.title.localizedFromCatalog)
                .font(AppFont.bold(isPhone ? 28 : 42))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .opacity(settled ? 1 : 0)
                .offset(y: settled ? 0 : 18)
                .animation(entrance(step: 1, settled: settled), value: settled)

            Text(page.body.localizedFromCatalog)
                .font(AppFont.regular(isPhone ? 15 : 24))
                .foregroundColor(.white.opacity(0.75))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, isPhone ? 32 : 100)
                .opacity(settled ? 1 : 0)
                .offset(y: settled ? 0 : 18)
                .animation(entrance(step: 2, settled: settled), value: settled)

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }

    /// Comes in with a spring, each part a beat after the one above it;
    /// leaves with a quick fade while the page slides away.
    private func entrance(step: Int, settled: Bool) -> Animation? {
        if reduceMotion { return nil }
        if !settled { return .easeOut(duration: 0.2) }
        return .spring(response: 0.55, dampingFraction: 0.78).delay(0.1 * Double(step))
    }

    /// Marks `page` as settled on the next run loop, so the change to nil
    /// before it is drawn first and the entrance animates.
    private func settle(_ page: Int) {
        DispatchQueue.main.async { settledPage = page }
    }

    /// The animated scene at the top of a page. Only the page on screen
    /// runs its clock.
    @ViewBuilder
    private func hero(for scene: OnboardingPage.Scene, active: Bool) -> some View {
        switch scene {
        case .welcome: WelcomeScene(size: heroSize, active: active)
        case .explore: ExploreScene(size: heroSize, active: active)
        case .quiz: QuizScene(size: heroSize, active: active)
        case .weigh: WeighScene(size: heroSize, active: active)
        case .threeD: ThreeDScene(size: heroSize, active: active)
        }
    }

    // MARK: - Controls

    /// A dot per page in that page's colour; the current one stretches into
    /// a glowing capsule. Tapping a dot goes to its page.
    private var pageIndicator: some View {
        HStack(spacing: isPhone ? 8 : 12) {
            ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                let isCurrent = index == currentPage
                Capsule()
                    .fill(isCurrent ? page.tint : Color.white.opacity(0.28))
                    .frame(width: isCurrent ? (isPhone ? 26 : 36) : (isPhone ? 8 : 11),
                           height: isPhone ? 8 : 11)
                    .shadow(color: isCurrent ? page.tint.opacity(0.8) : .clear, radius: 6)
                    .padding(.vertical, 10) // a bigger target than the dot
                    .contentShape(Rectangle())
                    .onTapGesture {
                        guard !isCurrent else { return }
                        playHaptic(.light)
                        withAnimation { currentPage = index }
                    }
            }
        }
        .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.7), value: currentPage)
        // VoiceOver users move through the pages with the Next button.
        .accessibilityHidden(true)
    }

    private var skipButton: some View {
        HStack {
            Spacer()
            if !isLastPage {
                Button("Skip") { finish() }
                    .font(AppFont.regular(isPhone ? 15 : 22))
                    .foregroundColor(Palette.secondaryText)
                    .padding(.trailing, 24)
                    .padding(.top, 12)
                    .transition(.opacity)
            }
        }
        .frame(height: 44)
    }

    private var advanceButton: some View {
        Button {
            if isLastPage {
                launch()
            } else {
                playHaptic()
                withAnimation { currentPage += 1 }
            }
        } label: {
            let label = Text(isLastPage ? "Let's Explore!" : "Next")
                .font(AppFont.bold(isPhone ? 17 : 24))
                .frame(maxWidth: .infinity)
                .padding(.vertical, isPhone ? 15 : 20)
                .background(Palette.accent)
                .foregroundColor(Palette.deepSpace)
                .cornerRadius(30)

            if isLastPage && !reduceMotion && !launching {
                // Breathes on the last page, inviting the tap.
                label.phaseAnimator([false, true]) { content, glowing in
                    content
                        .scaleEffect(glowing ? 1.035 : 1)
                        .shadow(color: Palette.accent.opacity(glowing ? 0.75 : 0.35), radius: glowing ? 28 : 16)
                } animation: { _ in
                    .easeInOut(duration: 0.9)
                }
            } else {
                label.shadow(color: Palette.accent.opacity(0.45), radius: 20)
            }
        }
    }

    /// The send-off from the last page. With Reduce Motion it just closes.
    private func launch() {
        guard !launching else { return }
        playNotificationHaptic(.success)
        guard !reduceMotion else { return finish() }

        confettiStart = Date()
        withAnimation(.easeIn(duration: 0.9)) { launching = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) { finish() }
    }

    private func finish() {
        withAnimation { hasSeenInstruction = true }
    }
}

#Preview {
    AppInstruction()
}

/// How a scene answers a tap: a quick bounce, and a full turn for the scenes
/// where turning makes sense — the solar systems spin flat, Saturn spins in
/// 3D, the quiz card and the scale only bounce.
private struct HeroTapResponse: ViewModifier {
    let scene: OnboardingPage.Scene
    let taps: Int

    private var turn: Double { Double(taps) * 360 }

    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(scene == .welcome || scene == .explore ? turn : 0))
            .rotation3DEffect(.degrees(scene == .threeD ? turn : 0), axis: (x: 0, y: 1, z: 0), perspective: 0.5)
            .keyframeAnimator(initialValue: 1.0, trigger: taps) { content, scale in
                content.scaleEffect(scale)
            } keyframes: { _ in
                KeyframeTrack {
                    SpringKeyframe(1.12, duration: 0.14)
                    SpringKeyframe(1.0, duration: 0.5, spring: .bouncy)
                }
            }
    }
}
