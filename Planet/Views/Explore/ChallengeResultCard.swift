//
//  ChallengeResultCard.swift
//  Planet
//
//  What Mission Control shows after a flight: the stars, what went wrong
//  and how to fix it, a new passport stamp, and the lesson learned.
//

import SwiftUI

/// One flight's outcome, with what it means for saved progress.
struct ChallengeResult {
    let attempt: MissionChallenge.Attempt
    let isNewBest: Bool
    /// First time this planet was reached: it earns a passport stamp.
    let newStamp: Bool
    /// The stamp that filled the passport.
    let passportComplete: Bool
    /// The challenge this result unlocked, if any.
    let unlockedIndex: Int?

    var hit: Bool { attempt.hit }
    var stars: Int { attempt.stars }
}

struct ChallengeResultCard: View {
    let result: ChallengeResult
    let target: String
    /// "Reach … to unlock the next challenge" — only on a campaign miss.
    let showsUnlockTip: Bool
    let unlockedTitle: LocalizedStringKey?

    private var progress: ProgressStore { .shared }
    private var isPhone: Bool { deviceType() == "iPhone" }

    var body: some View {
        let r = result
        let a = result.attempt
        let target = target.localizedBodyName
        VStack(spacing: 10) {
            PoppingStars(earned: r.stars, size: isPhone ? 30 : 40)

            Group {
                if !a.hit {
                    Text("Missed \(target)")
                } else if r.stars == 3 {
                    Text("Perfect mission!")
                } else if a.bullseye {
                    Text("Bullseye! \(progress.spacecraftDisplayName) reached \(target)")
                } else {
                    Text("\(progress.spacecraftDisplayName) reached \(target)!")
                }
            }
            .font(AppFont.bold(isPhone ? 20 : 28))
            .foregroundColor(a.hit ? Palette.success : Palette.warning)
            .multilineTextAlignment(.center)

            if r.isNewBest {
                Text("New best!")
                    .font(AppFont.bold(isPhone ? 12 : 17))
                    .foregroundColor(.black)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Palette.amber))
            }

            VStack(alignment: .leading, spacing: 6) {
                if !a.hit {
                    tip("ruler", Text("\(target) was \(MetricFormat.km(a.missKm)) from the meeting point when you got there."))
                    if let shift = a.shiftDays, shift != 0 {
                        tip("calendar", shift > 0
                            ? Text("Try launching about \(MetricFormat.plain(Double(shift), decimals: 0)) days later.")
                            : Text("Try launching about \(MetricFormat.plain(Double(-shift), decimals: 0)) days earlier."))
                    }
                }
                if !a.fuelOK {
                    tip("fuelpump.fill", Text("Too much fuel: slide the route towards Cheapest."))
                }
                if !a.timeOK {
                    tip("clock.fill", Text("Too slow: slide the route towards Fastest."))
                }
                if showsUnlockTip {
                    tip("lock.fill", Text("Reach \(target) to unlock the next challenge."))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if r.newStamp {
                StampReveal(planet: self.target, delay: 0.4 + 0.25 * Double(r.stars),
                            complete: r.passportComplete)
            }

            if let unlockedTitle {
                HStack(spacing: 8) {
                    Image(systemName: "lock.open.fill")
                    Text("Unlocked:")
                    Text(unlockedTitle)
                        .fontWeight(.bold)
                }
                .font(AppFont.regular(isPhone ? 14 : 20))
                .foregroundColor(Palette.accent)
                .padding(.top, 4)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .appCard()
        .accessibilityElement(children: .combine)
        .transition(.scale(scale: 0.9).combined(with: .opacity))
    }

    private func tip(_ icon: String, _ text: Text) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(Palette.amber)
                .frame(width: 20)
            text
                .font(AppFont.regular(isPhone ? 13 : 18))
                .foregroundColor(.white.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

/// The idea a challenge teaches, shown after every hit.
struct ChallengeLessonCard: View {
    let title: LocalizedStringKey
    let lesson: LocalizedStringKey

    private var isPhone: Bool { deviceType() == "iPhone" }

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(Palette.amber)
            VStack(alignment: .leading, spacing: 4) {
                (Text("You learned: ") + Text(title))
                    .font(AppFont.bold(isPhone ? 14 : 20))
                    .foregroundColor(.white)
                Text(lesson)
                    .font(AppFont.regular(isPhone ? 14 : 20))
                    .foregroundColor(.white.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .appCard(cornerRadius: 16)
        .accessibilityElement(children: .combine)
        .transition(.opacity)
    }
}

/// A new passport stamp, slammed down after the stars have popped.
private struct StampReveal: View {
    let planet: String
    let delay: Double
    let complete: Bool

    @State private var landed = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private var isPhone: Bool { deviceType() == "iPhone" }

    var body: some View {
        VStack(spacing: 8) {
            Text(complete ? "Passport complete! You've visited every planet." : "New passport stamp!")
                .font(AppFont.bold(isPhone ? 14 : 20))
                .foregroundColor(Passport.color(planet))
                .multilineTextAlignment(.center)
            PlanetStampView(planet: planet, visited: true, date: Date(), size: isPhone ? 100 : 130)
                .rotationEffect(.degrees(landed ? -4 : -14))
                .scaleEffect(landed ? 1 : 1.9)
                .opacity(landed ? 1 : 0)
        }
        .padding(.top, 6)
        .task {
            if reduceMotion {
                landed = true
                return
            }
            try? await Task.sleep(for: .seconds(delay))
            withAnimation(.spring(response: 0.28, dampingFraction: 0.55)) { landed = true }
            LaunchEffects.shared.stamp()
        }
    }
}

/// Result stars that pop in one by one, each with its own note.
private struct PoppingStars: View {
    let earned: Int
    let size: CGFloat

    @State private var shown = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: size * 0.25) {
            ForEach(0..<3, id: \.self) { i in
                let lit = i < shown
                Image(systemName: lit ? "star.fill" : "star")
                    .font(.system(size: size, weight: .semibold))
                    .foregroundColor(lit ? Palette.amber : .white.opacity(0.3))
                    .shadow(color: lit ? Palette.amber.opacity(0.6) : .clear, radius: 8)
                    .scaleEffect(lit ? 1 : 0.8)
            }
        }
        .environment(\.layoutDirection, .leftToRight)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(earned) of 3 stars"))
        .task {
            if reduceMotion {
                shown = earned
                return
            }
            for i in 0..<earned {
                try? await Task.sleep(for: .seconds(i == 0 ? 0.3 : 0.25))
                withAnimation(.spring(response: 0.3, dampingFraction: 0.45)) { shown = i + 1 }
                LaunchEffects.shared.star(i + 1)
            }
        }
    }
}
