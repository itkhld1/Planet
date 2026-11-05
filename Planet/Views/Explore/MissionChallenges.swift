//
//  MissionChallenges.swift
//  Planet
//
//  Mission Control: Mission Builder turned into a game. Each challenge sets a
//  route, a fuel budget and a deadline. The player picks a launch day and a
//  route speed, presses Launch, and — after a 3-2-1 countdown and liftoff —
//  watches whether the spacecraft and the planet meet.
//
//  ★    reach the planet (launch when it's lined up)
//  ★★   … and stay within the fuel budget
//  ★★★  … and beat the deadline
//
//  Every budget/deadline pair was checked against `TransferOrbit` so that a
//  band of route speeds earns all three stars, and the launch-day range
//  covers a full synodic period, so there is always a window to find.
//

import SwiftUI

// MARK: - Challenges

struct MissionChallenge: Identifiable {
    let id: String
    let chapter: Chapter
    let title: LocalizedStringKey
    let brief: LocalizedStringKey
    let origin: String
    let target: String
    let deadlineDays: Double
    let fuelBudget: Double        // km/s, total Δv
    /// Early challenges show where the target needs to be; later ones don't.
    let showsGuide: Bool
    /// The one idea this challenge teaches, shown after a hit. Daily
    /// missions don't have one.
    let lessonTitle: LocalizedStringKey?
    let lesson: LocalizedStringKey?

    enum Chapter: CaseIterable {
        case inner, giants

        var title: LocalizedStringKey {
            switch self {
            case .inner: return "Inner Planets"
            case .giants: return "Giant Planets"
            }
        }

        var icon: String {
            switch self {
            case .inner: return "sun.max.fill"
            case .giants: return "circle.hexagongrid.fill"
            }
        }
    }

    // Lesson facts were checked against the app's own orbit maths
    // (`TransferOrbit` / `LaunchWindow`): Mars needs a 44° lead, Venus starts
    // 54° behind, a sub-4-month Mars trip costs 2.8× the fuel, and Jupiter
    // moves 83° during the cheapest trip.
    static let all: [MissionChallenge] = [
        MissionChallenge(id: "first-flight", chapter: .inner, title: "First Flight",
                         brief: "Mars moves while you fly, so it needs a head start. Slide the launch day until Mars sits in the yellow circle.",
                         origin: "Earth", target: "Mars", deadlineDays: 270, fuelBudget: 6.0, showsGuide: true,
                         lessonTitle: "Launch windows",
                         lesson: "You can't aim at where Mars is, only where it will be. It has to be about 45° ahead of Earth at launch, and that only happens every 26 months."),
        MissionChallenge(id: "morning-star", chapter: .inner, title: "Morning Star",
                         brief: "Venus is closer to the Sun and faster than Earth. Line it up, then shave a few days off the trip.",
                         origin: "Earth", target: "Venus", deadlineDays: 140, fuelBudget: 6.0, showsGuide: true,
                         lessonTitle: "Inner planets are faster",
                         lesson: "The closer a planet is to the Sun, the faster it goes. Venus starts about 55° behind Earth and catches up while you fly."),
        MissionChallenge(id: "red-planet-express", chapter: .inner, title: "Red Planet Express",
                         brief: "Mission Control needs you at Mars in under 200 days. Go a little faster, but watch your fuel.",
                         origin: "Earth", target: "Mars", deadlineDays: 200, fuelBudget: 8.0, showsGuide: true,
                         lessonTitle: "Speed costs fuel",
                         lesson: "A faster route stretches your orbit so it crosses Mars's path early. Every day you save costs extra fuel."),
        MissionChallenge(id: "homecoming", chapter: .inner, title: "Homecoming",
                         brief: "Bring the crew home from Mars. No guide this time: launch, look where Earth ends up, and adjust.",
                         origin: "Mars", target: "Earth", deadlineDays: 235, fuelBudget: 7.0, showsGuide: false,
                         lessonTitle: "Falling towards the Sun",
                         lesson: "To head inwards you slow down, not speed up, and let the Sun pull you in. Astronauts would wait on Mars over a year for this window."),
        MissionChallenge(id: "speed-run", chapter: .inner, title: "Speed Run",
                         brief: "Earth to Mars in under four months. You'll need a lot of fuel, but not too much.",
                         origin: "Earth", target: "Mars", deadlineDays: 120, fuelBudget: 16.5, showsGuide: false,
                         lessonTitle: "Diminishing returns",
                         lesson: "Cutting the trip to under four months takes nearly three times the fuel of the cheapest route. That's why real Mars missions take 6 to 9 months."),
        MissionChallenge(id: "close-to-the-sun", chapter: .inner, title: "Close to the Sun",
                         brief: "Mercury races around the Sun every 88 days. Your timing has to be spot on.",
                         origin: "Earth", target: "Mercury", deadlineDays: 101, fuelBudget: 20.0, showsGuide: false,
                         lessonTitle: "Fast targets, tiny windows",
                         lesson: "Mercury moves so fast that a good launch lasts only a few days. Getting close to the Sun is also expensive: you have to shed a lot of speed."),
        MissionChallenge(id: "giant-leap", chapter: .giants, title: "Giant Leap",
                         brief: "Reach Jupiter within two years. The cheapest route takes almost three.",
                         origin: "Earth", target: "Jupiter", deadlineDays: 730, fuelBudget: 17.0, showsGuide: false,
                         lessonTitle: "Climbing away from the Sun",
                         lesson: "Jupiter is slow, but the trip is long: it moves almost a quarter of the way round the Sun while you fly. Most of your fuel goes on climbing away from the Sun."),
        MissionChallenge(id: "ringmaster", chapter: .giants, title: "Ringmaster",
                         brief: "Visit Saturn's rings within four years.",
                         origin: "Earth", target: "Saturn", deadlineDays: 1_461, fuelBudget: 18.5, showsGuide: false,
                         lessonTitle: "Gravity assists",
                         lesson: "Real missions borrow speed from planets. Cassini swung past Venus twice, then Earth and Jupiter, on its way to Saturn."),
        MissionChallenge(id: "ice-giant", chapter: .giants, title: "Ice Giant",
                         brief: "Uranus is so far away that light takes over two hours to get there. Arrive within ten years.",
                         origin: "Earth", target: "Uranus", deadlineDays: 3_653, fuelBudget: 18.2, showsGuide: false,
                         lessonTitle: "On its own",
                         lesson: "A radio message from Uranus takes over two and a half hours to reach Earth, so a spacecraft there has to look after itself."),
        MissionChallenge(id: "edge-of-the-planets", chapter: .giants, title: "Edge of the Planets",
                         brief: "The last planet. Reach Neptune within twenty years. Voyager 2 took twelve, by swinging past the giant planets.",
                         origin: "Earth", target: "Neptune", deadlineDays: 7_305, fuelBudget: 17.2, showsGuide: false,
                         lessonTitle: "The Grand Tour",
                         lesson: "In the late 1970s the giant planets lined up in a way that happens about once every 175 years. Voyager 2 used it to visit all four.")
    ]

    /// Unlocked once the previous challenge has at least one star.
    static func isUnlocked(_ index: Int, stars: [String: Int]) -> Bool {
        index == 0 || (stars[all[index - 1].id] ?? 0) > 0
    }
}

// MARK: - Progress

/// Best stars per challenge, saved as JSON in one UserDefaults string.
enum ChallengeProgress {
    static let storageKey = "missionChallengeStars"

    static func decode(_ json: String) -> [String: Int] {
        (try? JSONDecoder().decode([String: Int].self, from: Data(json.utf8))) ?? [:]
    }

    static func encode(_ stars: [String: Int]) -> String {
        (try? JSONEncoder().encode(stars)).flatMap { String(data: $0, encoding: .utf8) } ?? ""
    }
}

/// Three stars, `earned` of them filled.
struct StarRow: View {
    let earned: Int
    var size: CGFloat = 14

    var body: some View {
        HStack(spacing: size * 0.25) {
            ForEach(0..<3, id: \.self) { i in
                Image(systemName: i < earned ? "star.fill" : "star")
                    .font(.system(size: size, weight: .semibold))
                    .foregroundColor(i < earned ? .yellow : .white.opacity(0.3))
            }
        }
        .environment(\.layoutDirection, .leftToRight)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(earned) of 3 stars"))
    }
}

// MARK: - List

struct MissionChallengesView: View {
    @AppStorage(ChallengeProgress.storageKey) private var starsJSON = ""
    @AppStorage(Passport.storageKey) private var visitsJSON = ""
    @AppStorage(Spacecraft.nameKey) private var craftName = ""
    @AppStorage(Spacecraft.colorKey) private var craftColor = 0
    @AppStorage(Spacecraft.iconKey) private var craftIcon = 0
    @AppStorage(Crew.storageKey) private var crewJSON = ""

    private var isPhone: Bool { deviceType() == "iPhone" }
    private var stars: [String: Int] { ChallengeProgress.decode(starsJSON) }
    private var totalStars: Int { MissionChallenge.all.reduce(0) { $0 + (stars[$1.id] ?? 0) } }

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
                .foregroundColor(.yellow)
                .shadow(color: .yellow.opacity(0.5), radius: 12)
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
        let visited = Passport.visitedCount(visits: Passport.decode(visitsJSON), stars: stars)
        return NavigationLink {
            SpacePassportView()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "book.closed.fill")
                    .font(.system(size: isPhone ? 16 : 22, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: isPhone ? 34 : 46, height: isPhone ? 34 : 46)
                    .background(RoundedRectangle(cornerRadius: 10)
                        .fill(LinearGradient(colors: [.cyan, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Space Passport")
                        .font(AppFont.bold(isPhone ? 15 : 21))
                        .foregroundColor(.white)
                    Text("\(MetricFormat.plain(Double(visited), decimals: 0)) / \(MetricFormat.plain(Double(Passport.planets.count), decimals: 0)) planets visited")
                        .font(AppFont.regular(isPhone ? 12 : 17))
                        .foregroundColor(.white.opacity(0.6))
                }
                Spacer(minLength: 8)
                // A peek at the collection: one dot per planet.
                HStack(spacing: 3) {
                    ForEach(Passport.planets, id: \.self) { planet in
                        Circle()
                            .fill(Passport.visited(planet, visits: Passport.decode(visitsJSON), stars: stars)
                                  ? Passport.color(planet) : Color.white.opacity(0.15))
                            .frame(width: 6, height: 6)
                    }
                }
                .environment(\.layoutDirection, .leftToRight)
                Image(systemName: "chevron.forward")
                    .font(.system(size: isPhone ? 12 : 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.4))
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
            HStack(spacing: 12) {
                SpacecraftBadge(colorIndex: craftColor, iconIndex: craftIcon, size: isPhone ? 34 : 46)
                VStack(alignment: .leading, spacing: 2) {
                    Text(Spacecraft.displayName(craftName))
                        .font(AppFont.bold(isPhone ? 15 : 21))
                        .foregroundColor(.white)
                    Text("Crew of \(1 + Crew.decode(crewJSON).count)")
                        .font(AppFont.regular(isPhone ? 12 : 17))
                        .foregroundColor(.white.opacity(0.6))
                }
                Spacer(minLength: 8)
                Text("Edit")
                    .font(AppFont.bold(isPhone ? 14 : 20))
                    .foregroundColor(.cyan)
                Image(systemName: "chevron.forward")
                    .font(.system(size: isPhone ? 12 : 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.4))
            }
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
                        .foregroundColor(.white.opacity(0.4))
                } else {
                    Text(verbatim: "\(challenge.origin.localizedBodyName) → \(challenge.target.localizedBodyName)")
                        .font(AppFont.regular(isPhone ? 12 : 17))
                        .foregroundColor(.white.opacity(0.5))
                }
            }

            Spacer(minLength: 4)

            if !locked {
                StarRow(earned: stars[challenge.id] ?? 0, size: isPhone ? 12 : 16)
                Image(systemName: "chevron.forward")
                    .font(.system(size: isPhone ? 12 : 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.4))
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

// MARK: - Play

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

    @AppStorage(ChallengeProgress.storageKey) private var starsJSON = ""
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

    /// The target counts as hit within this many degrees of the meeting
    /// point — about where the planet and the arrival ring overlap.
    private static let hitDegrees = 5.0
    private static let bullseyeDegrees = 1.0

    private struct ChallengeResult {
        let hit: Bool
        let bullseye: Bool
        let missKm: Double
        /// Days to move the launch for a hit (positive = later), if missed.
        let shiftDays: Int?
        let fuelOK: Bool
        let timeOK: Bool
        let isNewBest: Bool
        /// First time this planet was reached: it earns a passport stamp.
        let newStamp: Bool
        /// The stamp that filled the passport.
        let passportComplete: Bool
        /// The challenge this result unlocked, if any.
        let unlockedIndex: Int?

        var stars: Int { hit ? 1 + (fuelOK ? 1 : 0) + (timeOK ? 1 : 0) : 0 }
    }

    private var isPhone: Bool { deviceType() == "iPhone" }
    private var challenge: MissionChallenge { challenges[index] }
    private var bestStars: Int { ChallengeProgress.decode(starsJSON)[challenge.id] ?? 0 }
    @AppStorage(Passport.storageKey) private var visitsJSON = ""
    @AppStorage(Spacecraft.nameKey) private var craftName = ""

    private var nextIsUnlocked: Bool {
        index + 1 < challenges.count
            && (!isCampaign || MissionChallenge.isUnlocked(index + 1, stars: ChallengeProgress.decode(starsJSON)))
    }

    private var transfer: TransferOrbit? {
        guard let o = PlanetMetrics.metrics(for: challenge.origin),
              let t = PlanetMetrics.metrics(for: challenge.target) else { return nil }
        return TransferOrbit(from: o, to: t, speed: speed)
    }

    private var launchDate: Date {
        firstDay.addingTimeInterval(launchDay.rounded() * 86_400 + 12 * 3_600)
    }

    /// One full synodic period, so at least one launch window is in range.
    private var lastDay: Double {
        (LaunchWindow.synodicDays(challenge.origin, challenge.target) ?? 365).rounded(.up)
    }

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
                            resultCard(result)
                            if result.hit, let title = challenge.lessonTitle, let lesson = challenge.lesson {
                                lessonCard(title: title, lesson: lesson)
                            }
                        }
                        launchDayCard
                        speedCard
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
                .tint(.cyan)
                dayStepButton(1, icon: "plus")
            }

            (launchDay == 0 ? Text("Today") : Text("In \(MetricFormat.plain(launchDay, decimals: 0)) days"))
                .font(AppFont.regular(isPhone ? 12 : 17))
                .foregroundColor(.white.opacity(0.55))
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

    private var speedCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Route")
                    .font(AppFont.regular(isPhone ? 14 : 20))
                    .foregroundColor(.white)
                Spacer()
                Text(speed == 0 ? "Cheapest (Hohmann)" : speed == 1 ? "Fastest" : "Faster, more fuel")
                    .font(AppFont.bold(isPhone ? 13 : 18))
                    .foregroundColor(speed == 0 ? .green : .orange)
            }
            Slider(value: $speed, in: 0...1) {
                Text("Route")
            } minimumValueLabel: {
                Image(systemName: "fuelpump.fill")
                    .foregroundColor(.white.opacity(0.6))
                    .accessibilityLabel(Text("Cheapest"))
            } maximumValueLabel: {
                Image(systemName: "hare.fill")
                    .foregroundColor(.white.opacity(0.6))
                    .accessibilityLabel(Text("Fastest"))
            }
            .tint(.cyan)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .appCard()
        .environment(\.layoutDirection, .leftToRight)
        .disabled(!isAiming)
        .opacity(isAiming ? 1 : 0.6)
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
            divider
            goalRow(icon: "fuelpump.fill", title: Text("Fuel"),
                    limit: Text("Max \(MissionFormat.deltaV(challenge.fuelBudget))"),
                    value: Text(MissionFormat.deltaV(t.totalDeltaV)), ok: fuelOK)
            divider
            goalRow(icon: "clock.fill", title: Text("Travel time"),
                    limit: Text("Max \(MissionFormat.duration(challenge.deadlineDays))"),
                    value: Text(MissionFormat.duration(t.travelDays)), ok: timeOK)
        }
        .appCard()
    }

    private var divider: some View {
        Divider().overlay(Color.white.opacity(0.15))
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
                        .foregroundColor(.white.opacity(0.55))
                }
            }
            Spacer(minLength: 8)
            value
                .font(AppFont.bold(isPhone ? 15 : 21))
                .foregroundColor(ok.map { $0 ? .green : .orange } ?? .white)
            if let ok {
                Image(systemName: ok ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(ok ? .green : .orange)
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
                .background(Color.black.opacity(0.3))
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
                            .background(LinearGradient(colors: [.cyan.opacity(0.6), .purple.opacity(0.6)],
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
                .background(Color.black.opacity(0.3))
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
                         Spacecraft.displayName(craftName), target)
                : String(format: String(localized: "Missed %@", bundle: Bundle.appLanguage), target)).post()

            try? await Task.sleep(for: .seconds(ConfettiView.duration))
            confettiStart = nil
        }
    }

    private func score(_ t: TransferOrbit) -> ChallengeResult {
        let miss = LaunchWindow.miss(from: challenge.origin, to: challenge.target,
                                     transfer: t, launch: launchDate) ?? .pi
        let missDegrees = abs(miss) * 180 / .pi
        let hit = missDegrees <= Self.hitDegrees

        // Straight-line gap between the planet and the meeting point.
        let missKm = 2 * t.targetRadius * sin(abs(miss) / 2)

        // How many days to move the launch so the gap closes, kept inside the
        // slider's range (one synodic period either way lands on another window).
        var shift: Int?
        if !hit, let rate = LaunchWindow.relativeRate(challenge.origin, challenge.target), rate != 0,
           let synodic = LaunchWindow.synodicDays(challenge.origin, challenge.target) {
            var day = launchDay - miss / rate
            while day > lastDay { day -= synodic }
            while day < 0 { day += synodic }
            shift = Int((day - launchDay).rounded())
        }

        let fuelOK = t.totalDeltaV <= challenge.fuelBudget
        let timeOK = t.travelDays <= challenge.deadlineDays
        let stars = hit ? 1 + (fuelOK ? 1 : 0) + (timeOK ? 1 : 0) : 0

        let allStars = ChallengeProgress.decode(starsJSON)
        let visits = Passport.decode(visitsJSON)
        let newStamp = hit && !Passport.visited(challenge.target, visits: visits, stars: allStars)
        let complete = newStamp && Passport.visitedCount(visits: visits, stars: allStars) == Passport.planets.count - 1
        // A first star on this challenge opens the next one.
        let unlocks = isCampaign && hit && bestStars == 0 && index + 1 < challenges.count

        return ChallengeResult(hit: hit, bullseye: missDegrees <= Self.bullseyeDegrees,
                               missKm: missKm, shiftDays: shift,
                               fuelOK: fuelOK, timeOK: timeOK,
                               isNewBest: stars > bestStars,
                               newStamp: newStamp, passportComplete: complete,
                               unlockedIndex: unlocks ? index + 1 : nil)
    }

    private func save(_ result: ChallengeResult) {
        if result.isNewBest {
            var all = ChallengeProgress.decode(starsJSON)
            all[challenge.id] = result.stars
            starsJSON = ChallengeProgress.encode(all)
        }
        if result.hit {
            var visits = Passport.decode(visitsJSON)
            if visits[challenge.target] == nil {
                visits[challenge.target] = Date().timeIntervalSince1970
                visitsJSON = Passport.encode(visits)
            }
        }
    }

    // MARK: Result

    private func resultCard(_ r: ChallengeResult) -> some View {
        let target = challenge.target.localizedBodyName
        return VStack(spacing: 10) {
            PoppingStars(earned: r.stars, size: isPhone ? 30 : 40)

            Group {
                if !r.hit {
                    Text("Missed \(target)")
                } else if r.stars == 3 {
                    Text("Perfect mission!")
                } else if r.bullseye {
                    Text("Bullseye! \(Spacecraft.displayName(craftName)) reached \(target)")
                } else {
                    Text("\(Spacecraft.displayName(craftName)) reached \(target)!")
                }
            }
            .font(AppFont.bold(isPhone ? 20 : 28))
            .foregroundColor(r.hit ? .green : .orange)
            .multilineTextAlignment(.center)

            if r.isNewBest {
                Text("New best!")
                    .font(AppFont.bold(isPhone ? 12 : 17))
                    .foregroundColor(.black)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.yellow))
            }

            VStack(alignment: .leading, spacing: 6) {
                if !r.hit {
                    tip("ruler", Text("\(target) was \(MetricFormat.km(r.missKm)) from the meeting point when you got there."))
                    if let shift = r.shiftDays, shift != 0 {
                        tip("calendar", shift > 0
                            ? Text("Try launching about \(MetricFormat.plain(Double(shift), decimals: 0)) days later.")
                            : Text("Try launching about \(MetricFormat.plain(Double(-shift), decimals: 0)) days earlier."))
                    }
                }
                if !r.fuelOK {
                    tip("fuelpump.fill", Text("Too much fuel: slide the route towards Cheapest."))
                }
                if !r.timeOK {
                    tip("clock.fill", Text("Too slow: slide the route towards Fastest."))
                }
                if !r.hit && !nextIsUnlocked && index + 1 < challenges.count {
                    tip("lock.fill", Text("Reach \(target) to unlock the next challenge."))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if r.newStamp {
                StampReveal(planet: challenge.target, delay: 0.4 + 0.25 * Double(r.stars),
                            complete: r.passportComplete)
            }

            if let unlocked = r.unlockedIndex {
                HStack(spacing: 8) {
                    Image(systemName: "lock.open.fill")
                    Text("Unlocked:")
                    Text(challenges[unlocked].title)
                        .fontWeight(.bold)
                }
                .font(AppFont.regular(isPhone ? 14 : 20))
                .foregroundColor(.cyan)
                .padding(.top, 4)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .appCard()
        .accessibilityElement(children: .combine)
        .transition(.scale(scale: 0.9).combined(with: .opacity))
    }

    /// The idea this challenge teaches, shown after every hit.
    private func lessonCard(title: LocalizedStringKey, lesson: LocalizedStringKey) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(.yellow)
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

    private func tip(_ icon: String, _ text: Text) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(.yellow)
                .frame(width: 20)
            text
                .font(AppFont.regular(isPhone ? 13 : 18))
                .foregroundColor(.white.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)
        }
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
                    .foregroundColor(lit ? .yellow : .white.opacity(0.3))
                    .shadow(color: lit ? .yellow.opacity(0.6) : .clear, radius: 8)
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

#Preview {
    NavigationStack { MissionChallengesView() }
}
