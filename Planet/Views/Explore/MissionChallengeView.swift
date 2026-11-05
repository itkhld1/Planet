//
//  MissionChallengeView.swift
//  Planet
//
//  Playing one Mission Control challenge: pick a launch day and a route
//  speed, press Launch, and — after a 3-2-1 countdown and liftoff — watch
//  whether the spacecraft and the planet meet. Scoring is in
//  `MissionChallenge.attempt`.
//

import SwiftUI

struct MissionChallengeView: View {
    @State private var index: Int
    @State private var launchDay = 0.0
    @State private var speed = 0.0
    @State private var phase: Phase = .aiming
    /// Day 0 of the launch-day slider; fixed while the screen is open.
    @State private var firstDay = Calendar.current.startOfDay(for: Date())
    @State private var flightID = UUID()
    @State private var confettiStart: Date?
    @State private var showLiftoff = false

    private var progress: ProgressStore { .shared }
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// The campaign by default; a daily mission passes just itself.
    private let challenges: [MissionChallenge]
    /// Unlocking only applies to the campaign.
    private let isCampaign: Bool

    init(challenges: [MissionChallenge] = MissionChallenge.all, startIndex: Int = 0) {
        self.challenges = challenges
        self.isCampaign = challenges.map(\.id) == MissionChallenge.all.map(\.id)
        _index = State(initialValue: startIndex)
    }

    private enum Phase {
        case aiming
        case countdown(Int)
        case flying(start: Date)
        case result(ChallengeResult)
    }

    private var isPhone: Bool { deviceType() == "iPhone" }
    private var challenge: MissionChallenge { challenges[index] }
    private var bestStars: Int { progress.stars(for: challenge.id) }

    private var nextIsUnlocked: Bool {
        index + 1 < challenges.count
            && (!isCampaign || MissionChallenge.isUnlocked(index + 1, stars: progress.challengeStars))
    }

    private var transfer: TransferOrbit? { challenge.transfer(speed: speed) }

    private var launchDate: Date {
        firstDay.addingTimeInterval(launchDay.rounded() * 86_400 + 12 * 3_600)
    }

    private var lastDay: Double { challenge.lastLaunchDay }

    private var isAiming: Bool {
        if case .aiming = phase { return true }
        return false
    }

    private var result: ChallengeResult? {
        if case .result(let r) = phase { return r }
        return nil
    }

    var body: some View {
        ZStack {
            AppGradientBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    briefCard
                    if let transfer {
                        diagram(transfer)
                        if let result {
                            ChallengeResultCard(
                                result: result, target: challenge.target,
                                showsUnlockTip: !result.hit && !nextIsUnlocked && index + 1 < challenges.count,
                                unlockedTitle: result.unlockedIndex.map { challenges[$0].title })
                            if result.hit, let title = challenge.lessonTitle, let lesson = challenge.lesson {
                                ChallengeLessonCard(title: title, lesson: lesson)
                            }
                        }
                        launchDayCard
                        RouteSpeedCard(speed: $speed)
                            .disabled(!isAiming)
                            .opacity(isAiming ? 1 : 0.6)
                        goalsCard(transfer)
                        actions
                    }
                }
                .padding()
                .frame(maxWidth: 700)
                .frame(maxWidth: .infinity)
            }
        }
        .overlay {
            if let confettiStart {
                ConfettiView(start: confettiStart)
                    .ignoresSafeArea()
            }
        }
        .appNavigationStyle(challenge.title)
        // Leaving mid-countdown or mid-flight cancels the launch.
        .onDisappear { flightID = UUID() }
    }

    // MARK: Brief

    private var briefCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "flag.checkered")
                .font(.system(size: isPhone ? 18 : 24))
                .foregroundColor(.orange)
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(verbatim: "\(challenge.origin.localizedBodyName) → \(challenge.target.localizedBodyName)")
                        .font(AppFont.bold(isPhone ? 15 : 21))
                        .foregroundColor(.white)
                    Spacer()
                    StarRow(earned: bestStars, size: isPhone ? 13 : 17)
                }
                Text(challenge.brief)
                    .font(AppFont.regular(isPhone ? 14 : 20))
                    .foregroundColor(.white.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .appCard(cornerRadius: 16)
        .accessibilityElement(children: .combine)
    }

    // MARK: Diagram

    private func diagram(_ t: TransferOrbit) -> some View {
        let mode: TransferOrbitDiagram.Mode = {
            switch phase {
            case .aiming, .countdown: return .aim(showGuide: challenge.showsGuide)
            case .flying(let start): return .flight(start: start)
            case .result: return .still(1)
            }
        }()
        return TransferOrbitDiagram(origin: challenge.origin, target: challenge.target,
                                    launchDate: launchDate, transfer: t,
                                    isAligned: result.map(\.hit), mode: mode,
                                    showsMiss: result?.hit == false)
            .overlay { countdownOverlay }
    }

    /// The big 3 · 2 · 1, then "Liftoff!".
    @ViewBuilder
    private var countdownOverlay: some View {
        Group {
            if case .countdown(let n) = phase {
                Text(MetricFormat.plain(Double(n), decimals: 0))
                    .font(AppFont.bold(isPhone ? 96 : 140))
                    .id(n)
            } else if showLiftoff {
                Text("Liftoff!")
                    .font(AppFont.bold(isPhone ? 44 : 64))
            }
        }
        .foregroundColor(.white)
        .shadow(color: .orange.opacity(0.8), radius: 20)
        .transition(reduceMotion ? .opacity : .scale(scale: 1.8).combined(with: .opacity))
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    // MARK: Controls

    private var launchDayCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Launch day")
                    .font(AppFont.regular(isPhone ? 14 : 20))
                    .foregroundColor(.white)
                Spacer()
                Text(launchDate.formatted(.dateTime.day().month(.abbreviated).year().locale(AppLanguage.locale)))
                    .font(AppFont.bold(isPhone ? 14 : 20))
                    .foregroundColor(.white)
            }

            HStack(spacing: 10) {
                dayStepButton(-1, icon: "minus")
                Slider(value: $launchDay, in: 0...lastDay, step: 1) {
                    Text("Launch day")
                }
                .tint(Palette.accent)
                dayStepButton(1, icon: "plus")
            }

            (launchDay == 0 ? Text("Today") : Text("In \(MetricFormat.plain(launchDay, decimals: 0)) days"))
                .font(AppFont.regular(isPhone ? 12 : 17))
                .foregroundColor(Palette.secondaryText)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .appCard()
        // Earlier → later runs left to right in every language.
        .environment(\.layoutDirection, .leftToRight)
        .disabled(!isAiming)
        .opacity(isAiming ? 1 : 0.6)
    }

    private func dayStepButton(_ step: Double, icon: String) -> some View {
        Button {
            playHaptic(.light)
            launchDay = min(max(launchDay + step, 0), lastDay)
        } label: {
            Image(systemName: icon)
                .font(.system(size: isPhone ? 13 : 18, weight: .bold))
                .foregroundColor(.white)
                .frame(width: isPhone ? 32 : 44, height: isPhone ? 32 : 44)
                .background(Circle().fill(Color.white.opacity(0.12)))
        }
        .buttonRepeatBehavior(.enabled)
        .accessibilityLabel(step < 0 ? Text("One day earlier") : Text("One day later"))
    }

    // MARK: Goals

    /// Fuel and time are known before launch, so they update live; whether
    /// the planet is there stays a secret until the flight.
    private func goalsCard(_ t: TransferOrbit) -> some View {
        let fuelOK = t.totalDeltaV <= challenge.fuelBudget
        let timeOK = t.travelDays <= challenge.deadlineDays
        return VStack(spacing: 0) {
            goalRow(icon: "scope",
                    title: Text("Reach \(challenge.target.localizedBodyName)"),
                    limit: nil,
                    value: result.map { $0.hit ? Text("Hit") : Text("Missed") } ?? Text(verbatim: "?"),
                    ok: result?.hit)
            CardDivider()
            goalRow(icon: "fuelpump.fill", title: Text("Fuel"),
                    limit: Text("Max \(MissionFormat.deltaV(challenge.fuelBudget))"),
                    value: Text(MissionFormat.deltaV(t.totalDeltaV)), ok: fuelOK)
            CardDivider()
            goalRow(icon: "clock.fill", title: Text("Travel time"),
                    limit: Text("Max \(MissionFormat.duration(challenge.deadlineDays))"),
                    value: Text(MissionFormat.duration(t.travelDays)), ok: timeOK)
        }
        .appCard()
    }

    private func goalRow(icon: String, title: Text, limit: Text?, value: Text, ok: Bool?) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: isPhone ? 15 : 21))
                .foregroundColor(.white.opacity(0.7))
                .frame(width: isPhone ? 22 : 30)
            VStack(alignment: .leading, spacing: 2) {
                title
                    .font(AppFont.regular(isPhone ? 14 : 20))
                    .foregroundColor(.white)
                if let limit {
                    limit
                        .font(AppFont.regular(isPhone ? 12 : 17))
                        .foregroundColor(Palette.secondaryText)
                }
            }
            Spacer(minLength: 8)
            value
                .font(AppFont.bold(isPhone ? 15 : 21))
                .foregroundColor(ok.map { $0 ? Palette.success : Palette.warning } ?? .white)
            if let ok {
                Image(systemName: ok ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(ok ? Palette.success : Palette.warning)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
    }

    // MARK: Actions

    @ViewBuilder
    private var actions: some View {
        switch phase {
        case .aiming:
            Button(action: launch) {
                Label("Launch!", systemImage: "flame.fill")
                    .font(AppFont.bold(isPhone ? 18 : 24))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(16)
                    .shadow(color: .orange.opacity(0.4), radius: 10)
            }
        case .countdown:
            Button {
                playHaptic(.light)
                flightID = UUID()        // cancels the pending launch
                withAnimation(.easeInOut(duration: 0.2)) { phase = .aiming }
            } label: {
                Label("Abort", systemImage: "xmark.octagon.fill")
                    .font(AppFont.bold(isPhone ? 18 : 24))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.red.opacity(0.35))
                    .cornerRadius(16)
            }
        case .flying:
            Label("In flight…", systemImage: "airplane")
                .font(AppFont.bold(isPhone ? 18 : 24))
                .foregroundColor(.white.opacity(0.7))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Palette.card)
                .cornerRadius(16)
        case .result(let r):
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    actionButton("Try again", icon: "arrow.counterclockwise") {
                        phase = .aiming
                    }
                    if nextIsUnlocked {
                        actionButton("Next challenge", icon: "arrow.forward") {
                            index += 1
                            launchDay = 0
                            speed = 0
                            phase = .aiming
                        }
                    } else if index + 1 == challenges.count {
                        actionButton("All challenges", icon: "list.bullet") { dismiss() }
                    }
                }
                // Only hits are shareable: a picture of the spacecraft arriving.
                if r.hit, let t = transfer {
                    ShareLink(item: ChallengeSnapshot(summary: ChallengeShareSummary(
                                  title: challenge.title, origin: challenge.origin, target: challenge.target,
                                  launchDate: launchDate, transfer: t, stars: r.stars)),
                              preview: SharePreview(Text(challenge.title), image: Image(challenge.target))) {
                        Label("Share your mission", systemImage: "square.and.arrow.up")
                            .font(AppFont.bold(isPhone ? 15 : 21))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(LinearGradient(colors: [Palette.accent.opacity(0.6), .purple.opacity(0.6)],
                                                       startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(14)
                    }
                }
            }
        }
    }

    private func actionButton(_ title: LocalizedStringKey, icon: String, action: @escaping () -> Void) -> some View {
        Button {
            playHaptic(.light)
            withAnimation(.easeInOut(duration: 0.25)) { action() }
        } label: {
            Label(title, systemImage: icon)
                .font(AppFont.bold(isPhone ? 15 : 21))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Palette.card)
                .cornerRadius(14)
        }
    }

    // MARK: Launch & scoring

    /// Countdown → liftoff → flight → result. Every step checks the launch
    /// is still the current one, so Abort, Next or leaving the screen stop it.
    private func launch() {
        guard let t = transfer else { return }
        let id = UUID()
        flightID = id
        let outcome = score(t)
        let effects = LaunchEffects.shared

        Task { @MainActor in
            for n in [3, 2, 1] {
                guard flightID == id else { return }
                withAnimation(.spring(duration: 0.35)) { phase = .countdown(n) }
                effects.countdown(n)
                AccessibilityNotification.Announcement(MetricFormat.plain(Double(n), decimals: 0)).post()
                try? await Task.sleep(for: .seconds(0.8))
            }
            guard flightID == id else { return }

            effects.liftoff()
            withAnimation(.spring(duration: 0.35)) {
                showLiftoff = true
                phase = .flying(start: Date())
            }
            try? await Task.sleep(for: .seconds(0.9))
            withAnimation(.easeOut(duration: 0.4)) { showLiftoff = false }

            let rest = reduceMotion ? 0.2 : TransferOrbitDiagram.launchFlightSeconds - 0.6
            try? await Task.sleep(for: .seconds(rest))
            guard flightID == id else { return }

            save(outcome)
            if outcome.hit {
                effects.success()
                if !reduceMotion { confettiStart = Date() }
            } else {
                effects.miss()
            }
            withAnimation(.spring(duration: 0.4)) { phase = .result(outcome) }
            let target = challenge.target.localizedBodyName
            AccessibilityNotification.Announcement(outcome.hit
                ? String(format: String(localized: "%@ reached %@!", bundle: Bundle.appLanguage),
                         progress.spacecraftDisplayName, target)
                : String(format: String(localized: "Missed %@", bundle: Bundle.appLanguage), target)).post()

            try? await Task.sleep(for: .seconds(ConfettiView.duration))
            confettiStart = nil
        }
    }

    /// The flight's outcome, plus what it means for saved progress.
    private func score(_ t: TransferOrbit) -> ChallengeResult {
        let attempt = challenge.attempt(transfer: t, launchDate: launchDate, launchDay: launchDay)
        let newStamp = attempt.hit && !progress.hasVisited(challenge.target)
        let complete = newStamp && progress.visitedPlanetCount == Passport.planets.count - 1
        // A first star on this challenge opens the next one.
        let unlocks = isCampaign && attempt.hit && bestStars == 0 && index + 1 < challenges.count

        return ChallengeResult(attempt: attempt,
                               isNewBest: attempt.stars > bestStars,
                               newStamp: newStamp, passportComplete: complete,
                               unlockedIndex: unlocks ? index + 1 : nil)
    }

    private func save(_ result: ChallengeResult) {
        progress.recordStars(result.stars, for: challenge.id)
        if result.hit {
            progress.recordVisit(to: challenge.target)
        }
    }
}
