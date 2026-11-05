//
//  MissionChallengesView.swift
//  Planet
//
//  Mission Control's home: stars so far, the daily mission, the passport,
//  the spacecraft, and the campaign's challenges by chapter.
//

import SwiftUI

/// Three stars, `earned` of them filled.
struct StarRow: View {
    let earned: Int
    var size: CGFloat = 14

    var body: some View {
        HStack(spacing: size * 0.25) {
            ForEach(0..<3, id: \.self) { i in
                Image(systemName: i < earned ? "star.fill" : "star")
                    .font(.system(size: size, weight: .semibold))
                    .foregroundColor(i < earned ? Palette.amber : .white.opacity(0.3))
            }
        }
        .environment(\.layoutDirection, .leftToRight)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(earned) of 3 stars"))
    }
}

// MARK: - List

struct MissionChallengesView: View {
    private var progress: ProgressStore { .shared }

    private var isPhone: Bool { deviceType() == "iPhone" }
    private var stars: [String: Int] { progress.challengeStars }
    private var totalStars: Int { progress.campaignStars }

    var body: some View {
        ZStack {
            AppGradientBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    header
                    DailyMissionCard()
                    passportLink
                    spacecraftLink
                    ForEach(MissionChallenge.Chapter.allCases, id: \.self) { chapter in
                        chapterCard(chapter)
                    }
                    RealWindowsCard()
                }
                .padding()
                .frame(maxWidth: 700)
                .frame(maxWidth: .infinity)
            }
        }
        .appNavigationStyle("Mission Control")
    }

    private var header: some View {
        VStack(spacing: 10) {
            Image(systemName: "trophy.fill")
                .font(.system(size: isPhone ? 40 : 56))
                .foregroundColor(Palette.amber)
                .shadow(color: Palette.amber.opacity(0.5), radius: 12)
            Text("\(MetricFormat.plain(Double(totalStars), decimals: 0)) / \(MetricFormat.plain(Double(MissionChallenge.all.count * 3), decimals: 0)) stars")
                .font(AppFont.bold(isPhone ? 22 : 30))
                .foregroundColor(.white)
            Text("Hit the planet for ★, stay within the fuel budget and beat the deadline for ★★★.")
                .font(AppFont.regular(isPhone ? 14 : 20))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
    }

    private var passportLink: some View {
        let visited = progress.visitedPlanetCount
        return NavigationLink {
            SpacePassportView()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "book.closed.fill")
                    .font(.system(size: isPhone ? 16 : 22, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: isPhone ? 34 : 46, height: isPhone ? 34 : 46)
                    .background(RoundedRectangle(cornerRadius: 10)
                        .fill(LinearGradient(colors: [Palette.accent, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Space Passport")
                        .font(AppFont.bold(isPhone ? 15 : 21))
                        .foregroundColor(.white)
                    Text("\(MetricFormat.plain(Double(visited), decimals: 0)) / \(MetricFormat.plain(Double(Passport.planets.count), decimals: 0)) planets visited")
                        .font(AppFont.regular(isPhone ? 12 : 17))
                        .foregroundColor(Palette.secondaryText)
                }
                Spacer(minLength: 8)
                // A peek at the collection: one dot per planet.
                HStack(spacing: 3) {
                    ForEach(Passport.planets, id: \.self) { planet in
                        Circle()
                            .fill(progress.hasVisited(planet)
                                  ? Passport.color(planet) : Color.white.opacity(0.15))
                            .frame(width: 6, height: 6)
                    }
                }
                .environment(\.layoutDirection, .leftToRight)
                Image(systemName: "chevron.forward")
                    .font(.system(size: isPhone ? 12 : 16, weight: .semibold))
                    .foregroundColor(Palette.secondaryText)
            }
            .padding(14)
            .appCard(cornerRadius: 16)
        }
        .buttonStyle(.plain)
    }

    private var spacecraftLink: some View {
        NavigationLink {
            SpacecraftView()
        } label: {
            SpacecraftSummaryRow()
                .padding(14)
                .appCard(cornerRadius: 16)
        }
        .buttonStyle(.plain)
    }

    private func chapterCard(_ chapter: MissionChallenge.Chapter) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(chapter.title, systemImage: chapter.icon)
                .font(AppFont.bold(isPhone ? 17 : 24))
                .foregroundColor(.white)

            VStack(spacing: 10) {
                ForEach(Array(MissionChallenge.all.enumerated()).filter { $0.element.chapter == chapter },
                        id: \.element.id) { index, challenge in
                    if MissionChallenge.isUnlocked(index, stars: stars) {
                        NavigationLink {
                            MissionChallengeView(startIndex: index)
                        } label: {
                            row(index: index, challenge: challenge, locked: false)
                        }
                        .buttonStyle(.plain)
                    } else {
                        row(index: index, challenge: challenge, locked: true)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .appCard()
    }

    private func row(index: Int, challenge: MissionChallenge, locked: Bool) -> some View {
        HStack(spacing: 12) {
            Group {
                if locked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: isPhone ? 13 : 18, weight: .semibold))
                } else {
                    Text(MetricFormat.plain(Double(index + 1), decimals: 0))
                        .font(AppFont.bold(isPhone ? 15 : 21))
                }
            }
            .foregroundColor(.white)
            .frame(width: isPhone ? 34 : 46, height: isPhone ? 34 : 46)
            .background(RoundedRectangle(cornerRadius: 10)
                .fill(locked
                      ? AnyShapeStyle(Color.white.opacity(0.12))
                      : AnyShapeStyle(LinearGradient(colors: [.orange, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))))

            VStack(alignment: .leading, spacing: 2) {
                Text(challenge.title)
                    .font(AppFont.regular(isPhone ? 15 : 21))
                    .foregroundColor(.white.opacity(locked ? 0.45 : 1))
                if locked {
                    Text("Earn a star on the one before to unlock")
                        .font(AppFont.regular(isPhone ? 12 : 17))
                        .foregroundColor(Palette.secondaryText)
                } else {
                    Text(verbatim: "\(challenge.origin.localizedBodyName) → \(challenge.target.localizedBodyName)")
                        .font(AppFont.regular(isPhone ? 12 : 17))
                        .foregroundColor(Palette.secondaryText)
                }
            }

            Spacer(minLength: 4)

            if !locked {
                StarRow(earned: stars[challenge.id] ?? 0, size: isPhone ? 12 : 16)
                Image(systemName: "chevron.forward")
                    .font(.system(size: isPhone ? 12 : 16, weight: .semibold))
                    .foregroundColor(Palette.secondaryText)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(Color.white.opacity(locked ? 0.06 : 0.12))
        .cornerRadius(14)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack { MissionChallengesView() }
}
