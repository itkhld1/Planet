//
//  DailyMission.swift
//  Planet
//
//  Today's Mission: a fresh challenge every calendar day, identical for
//  everyone on the same date (it's seeded from the Gregorian date, so a
//  Persian-calendar phone gets the same one). Some days it's a race against
//  a real spacecraft — "Beat Perseverance".
//
//  Also here: the real launch windows from Earth, so Mission Control can say
//  "the Mars window is open right now" and jump straight into planning it.
//

import SwiftUI

// MARK: - Plan

/// The numbers behind one day's mission. Kept free of SwiftUI so it can be
/// checked on its own: every plan is built around a route speed that earns
/// all three stars, so no day is impossible.
struct DailyMissionPlan {
    let dateKey: String          // "2026-11-05"
    let origin: String
    let target: String
    let deadlineDays: Double
    let fuelBudget: Double
    /// Set on "beat the real mission" days.
    let rival: RealMission?

    static let routes: [(String, String)] = [
        ("Earth", "Mars"), ("Earth", "Venus"), ("Mars", "Earth"), ("Earth", "Mercury"),
        ("Earth", "Jupiter"), ("Earth", "Saturn"), ("Venus", "Mars"), ("Venus", "Earth"),
        ("Mars", "Jupiter"), ("Earth", "Uranus"), ("Earth", "Neptune")
    ]

    /// Gregorian on purpose: the seed must match across calendars.
    static var calendar: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = .current
        return c
    }

    init(date: Date) {
        let c = Self.calendar.dateComponents([.year, .month, .day], from: date)
        let (y, m, d) = (c.year ?? 2000, c.month ?? 1, c.day ?? 1)
        dateKey = String(format: "%04d-%02d-%02d", y, m, d)
        var rng = SeededRandom(seed: UInt64(y * 10_000 + m * 100 + d))

        let route = Self.routes[Int(rng.next(0, Double(Self.routes.count) - 0.001))]
        origin = route.0
        target = route.1

        func transfer(_ speed: Double) -> TransferOrbit? {
            guard let o = PlanetMetrics.metrics(for: route.0),
                  let t = PlanetMetrics.metrics(for: route.1) else { return nil }
            return TransferOrbit(from: o, to: t, speed: speed)
        }
        /// Rounds up to `1 / per` (dividing last keeps 21.2 from becoming 21.200000000000003).
        func roundUp(_ v: Double, per: Double) -> Double { (v * per).rounded(.up) / per }

        // On routes with a spacecraft worth racing, about one day in three is
        // a race (roughly one day in ten overall). Only ones that were
        // faster than the cheapest route make a real race: Galileo or Cassini
        // took long loops past other planets, so the slowest route beats
        // them. And Voyager 2 reached Neptune with gravity assists we don't
        // model, so it can't be beaten at all.
        let rivals = RealMission.missions(from: route.0, to: route.1).filter {
            (transfer(0)?.travelDays ?? 0) > $0.days - 1
        }
        let wantsRival = rng.next(0, 1) < 0.35
        let pick = rng.next(0, 1)
        let extra = rng.next(0, 0.2)
        let fuelSlack = rng.next(0.03, 0.08)
        let timeSlack = rng.next(0.03, 0.08)
        let normalSpeed = rng.next(0.05, 0.8)

        if wantsRival, !rivals.isEmpty {
            let mission = rivals[Int(pick * Double(rivals.count) * 0.999)]
            let beatsIt = stride(from: 0.0, through: 1.0, by: 0.01).first {
                (transfer($0)?.travelDays ?? .infinity) <= mission.days - 1
            }
            if let slowest = beatsIt, let t = transfer(min(1, slowest + extra)) {
                rival = mission
                deadlineDays = mission.days - 1
                fuelBudget = roundUp(t.totalDeltaV * (1 + fuelSlack), per: 10)
                return
            }
        }

        rival = nil
        let t = transfer(normalSpeed)
        deadlineDays = roundUp((t?.travelDays ?? 365) * (1 + timeSlack), per: 1)
        fuelBudget = roundUp((t?.totalDeltaV ?? 10) * (1 + fuelSlack), per: 10)
    }

    var id: String { "daily-\(dateKey)" }

    var challenge: MissionChallenge {
        let to = target.localizedBodyName
        let title: LocalizedStringKey
        let brief: LocalizedStringKey
        if let rival {
            title = "Beat \(rival.name)"
            brief = "\(rival.name) took \(MissionFormat.duration(rival.days)) to reach \(to). Get there faster, using no more than \(MissionFormat.deltaV(fuelBudget))."
        } else {
            title = "Today's Mission"
            brief = "Reach \(to) within \(MissionFormat.duration(deadlineDays)) using no more than \(MissionFormat.deltaV(fuelBudget))."
        }
        return MissionChallenge(id: id, chapter: .inner, title: title, brief: brief,
                                origin: origin, target: target,
                                deadlineDays: deadlineDays, fuelBudget: fuelBudget,
                                showsGuide: false, lessonTitle: nil, lesson: nil)
    }

    /// Days with at least one star — a running total, never a streak that
    /// punishes a missed day.
    static func completedDays(stars: [String: Int]) -> Int {
        stars.filter { $0.key.hasPrefix("daily-") && $0.value > 0 }.count
    }

    /// Time left until tomorrow's mission.
    static func secondsUntilNext(from date: Date) -> Double {
        let cal = calendar
        let tomorrow = cal.date(byAdding: .day, value: 1, to: cal.startOfDay(for: date)) ?? date
        return tomorrow.timeIntervalSince(date)
    }
}

// MARK: - Real launch windows

/// The next cheapest-route window from Earth to a planet, using the same
/// maths and "open" margin as Mission Builder, so the two always agree.
struct RealLaunchWindow: Identifiable {
    let target: String
    let bestDay: Date
    let isOpen: Bool
    var id: String { target }

    static let targets = ["Venus", "Mars", "Jupiter", "Saturn"]

    static func upcoming(from now: Date) -> [RealLaunchWindow] {
        targets.compactMap { target in
            guard let earth = PlanetMetrics.metrics(for: "Earth"),
                  let planet = PlanetMetrics.metrics(for: target),
                  let t = TransferOrbit(from: earth, to: planet),
                  let synodic = LaunchWindow.synodicDays("Earth", target) else { return nil }
            let margin = LaunchWindow.tolerance(synodicDays: synodic) * 86_400
            guard let best = LaunchWindow.next(from: "Earth", to: target, travelDays: t.travelDays,
                                               sweptAngle: t.sweptAngle,
                                               after: now.addingTimeInterval(-margin)) else { return nil }
            return RealLaunchWindow(target: target, bestDay: best,
                                    isOpen: abs(best.timeIntervalSince(now)) <= margin)
        }
        .sorted { $0.bestDay < $1.bestDay }
    }
}

// MARK: - Cards

/// The big "Today's Mission" card at the top of Mission Control.
struct DailyMissionCard: View {
    private var progress: ProgressStore { .shared }
    private var isPhone: Bool { deviceType() == "iPhone" }

    var body: some View {
        // Ticks each minute so the countdown — and the mission itself, at
        // midnight — stay current while the screen is open.
        TimelineView(.periodic(from: .now, by: 60)) { context in
            let plan = DailyMissionPlan(date: context.date)
            let stars = progress.challengeStars
            NavigationLink {
                MissionChallengeView(challenges: [plan.challenge])
            } label: {
                content(plan: plan, earned: stars[plan.id] ?? 0,
                        completed: DailyMissionPlan.completedDays(stars: stars), now: context.date)
            }
            .buttonStyle(.plain)
        }
    }

    private func content(plan: DailyMissionPlan, earned: Int, completed: Int, now: Date) -> some View {
        let left = DailyMissionPlan.secondsUntilNext(from: now)
        let hours = Int(left / 3_600)
        let minutes = Int(left.truncatingRemainder(dividingBy: 3_600) / 60)

        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: plan.rival == nil ? "calendar" : "flag.2.crossed.fill")
                    .font(.system(size: isPhone ? 18 : 24, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: isPhone ? 42 : 56, height: isPhone ? 42 : 56)
                    .background(RoundedRectangle(cornerRadius: 12)
                        .fill(LinearGradient(colors: plan.rival == nil ? [.purple, .pink] : [.red, .orange],
                                             startPoint: .topLeading, endPoint: .bottomTrailing)))

                VStack(alignment: .leading, spacing: 3) {
                    Text(plan.challenge.title)
                        .font(AppFont.bold(isPhone ? 17 : 23))
                        .foregroundColor(.white)
                    Text(verbatim: "\(plan.origin.localizedBodyName) → \(plan.target.localizedBodyName)")
                        .font(AppFont.regular(isPhone ? 13 : 18))
                        .foregroundColor(Palette.secondaryText)
                }

                Spacer(minLength: 4)

                StarRow(earned: earned, size: isPhone ? 13 : 17)
                Image(systemName: "chevron.forward")
                    .font(.system(size: isPhone ? 12 : 16, weight: .semibold))
                    .foregroundColor(Palette.secondaryText)
            }

            Divider().overlay(Color.white.opacity(0.15))

            HStack {
                Label {
                    Text("New mission in \(MetricFormat.plain(Double(hours), decimals: 0)) h \(MetricFormat.plain(Double(minutes), decimals: 0)) min")
                } icon: {
                    Image(systemName: "clock")
                }
                Spacer()
                Label {
                    Text("\(MetricFormat.plain(Double(completed), decimals: 0)) days completed")
                } icon: {
                    Image(systemName: "checkmark.seal.fill")
                }
            }
            .font(AppFont.regular(isPhone ? 12 : 17))
            .foregroundColor(Palette.secondaryText)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Palette.card)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(LinearGradient(colors: plan.rival == nil ? [.purple, .pink] : [.red, .orange],
                                       startPoint: .leading, endPoint: .trailing).opacity(0.6),
                        lineWidth: 1.5)
        )
        .accessibilityElement(children: .combine)
    }
}

/// Real windows from Earth, soonest first. Tapping one opens Mission Builder
/// with that route and date already set.
struct RealWindowsCard: View {
    private var isPhone: Bool { deviceType() == "iPhone" }

    var body: some View {
        let windows = RealLaunchWindow.upcoming(from: Date())
        VStack(alignment: .leading, spacing: 14) {
            Label("Real launch windows", systemImage: "calendar.badge.clock")
                .font(AppFont.bold(isPhone ? 17 : 24))
                .foregroundColor(.white)

            VStack(spacing: 10) {
                ForEach(windows) { window in
                    NavigationLink {
                        MissionBuilderView(preset: .init(origin: "Earth", target: window.target,
                                                         launchDate: window.bestDay))
                    } label: {
                        row(window)
                    }
                    .buttonStyle(.plain)
                }
            }

            Text("When Earth and each planet really line up for the cheapest trip. Tap one to plan it.")
                .font(AppFont.regular(isPhone ? 12 : 17))
                .foregroundColor(Palette.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .appCard()
    }

    private func row(_ w: RealLaunchWindow) -> some View {
        let days = max(0, w.bestDay.timeIntervalSince(Date()) / 86_400)
        return HStack(spacing: 12) {
            Image(w.target)
                .resizable()
                .scaledToFit()
                .frame(width: isPhone ? 32 : 44, height: isPhone ? 32 : 44)
            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: "\("Earth".localizedBodyName) → \(w.target.localizedBodyName)")
                    .font(AppFont.regular(isPhone ? 15 : 21))
                    .foregroundColor(.white)
                Text(w.bestDay.formatted(.dateTime.day().month(.wide).year().locale(AppLanguage.locale)))
                    .font(AppFont.regular(isPhone ? 12 : 17))
                    .foregroundColor(Palette.secondaryText)
            }
            Spacer(minLength: 8)
            Group {
                if w.isOpen {
                    Label("Open now", systemImage: "circle.fill")
                        .foregroundColor(Palette.success)
                } else {
                    Text("In \(MissionFormat.duration(days))")
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .font(AppFont.bold(isPhone ? 13 : 18))
            .labelStyle(OpenDotLabelStyle())
            Image(systemName: "chevron.forward")
                .font(.system(size: isPhone ? 12 : 16, weight: .semibold))
                .foregroundColor(Palette.secondaryText)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(Color.white.opacity(0.12))
        .cornerRadius(14)
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}

/// A small dot before "Open now" instead of a full-size icon.
private struct OpenDotLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 5) {
            configuration.icon.font(.system(size: 7))
            configuration.title
        }
    }
}
