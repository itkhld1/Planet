//
//  MissionBuilderView.swift
//  Planet
//
//  Plan a trip between two planets. The default is a Hohmann transfer — the
//  minimum-energy route real missions are based on — and a slider trades
//  extra fuel for a faster trip. Figures assume circular,
//  coplanar orbits, which is accurate enough to show the right scale
//  (Earth → Mars ≈ 8.5 months, the same ballpark as real Mars missions).
//

import SwiftUI

// MARK: - Physics

/// A transfer orbit from one planet's orbit to another's.
///
/// `speed` 0 is a Hohmann transfer — half an ellipse that just touches both
/// orbits, the cheapest route. Raising it stretches the ellipse past the
/// target's orbit (or inside it, going inwards), so the spacecraft crosses
/// the target orbit early: a shorter trip that costs more fuel.
///
/// Orbits are treated as circular and coplanar; escaping and being captured
/// by each planet's own gravity is ignored.
struct TransferOrbit {
    /// Sun's gravitational parameter, km³/s².
    private static let muSun = 1.327_124_400_18e11

    let originRadius: Double      // km
    let targetRadius: Double      // km
    let travelDays: Double
    let departureDeltaV: Double   // km/s, heliocentric
    let arrivalDeltaV: Double     // km/s, heliocentric
    let windowEveryDays: Double   // synodic period
    let transferDistanceKm: Double
    /// Angle around the Sun covered during the flight, radians (π for Hohmann).
    let sweptAngle: Double

    private let a: Double
    private let e: Double
    private let outbound: Bool
    private let startAnomaly: Double  // ν at departure: 0 (perihelion) or π (aphelion)
    private let startMean: Double
    private let endMean: Double

    var totalDeltaV: Double { departureDeltaV + arrivalDeltaV }

    init?(from origin: PlanetMetrics, to target: PlanetMetrics, speed: Double = 0) {
        let r1 = origin.distanceFromSunKm
        let r2 = target.distanceFromSunKm
        guard r1 > 0, r2 > 0, r1 != r2 else { return nil }
        let mu = Self.muSun
        let stretch = min(max(speed, 0), 1)
        let stretch2 = stretch * stretch

        outbound = r2 > r1
        let rp = outbound ? r1 : r2 * (1 - 0.5 * stretch2)
        let ra = outbound ? r2 * (1 + stretch2) : r1
        // Locals first: `self` can't be captured until every property is set.
        let a = (rp + ra) / 2
        let e = (ra - rp) / (ra + rp)
        self.a = a
        self.e = e
        let p = a * (1 - e * e)

        // True anomaly where the ellipse crosses the target's orbit.
        let crossing = e > 0 ? acos(min(1, max(-1, (p / r2 - 1) / e))) : .pi

        if outbound {
            startAnomaly = 0
            startMean = 0
            endMean = Self.meanAnomaly(crossing, e: e)
            sweptAngle = crossing
        } else {
            // Inbound: leave at aphelion, fall towards perihelion.
            startAnomaly = .pi
            startMean = .pi
            endMean = 2 * .pi - Self.meanAnomaly(crossing, e: e)
            sweptAngle = .pi - crossing
        }

        let n = (mu / (a * a * a)).squareRoot()     // rad/s
        travelDays = (endMean - startMean) / n / 86_400

        // Burn 1: from circular orbit speed onto the ellipse (both tangential).
        let v1 = (mu * (2 / r1 - 1 / a)).squareRoot()
        departureDeltaV = abs(v1 - (mu / r1).squareRoot())

        // Burn 2: match the target's circular velocity. Off-Hohmann the
        // spacecraft also has a sideways (radial) component to cancel.
        let h = (mu * p).squareRoot()
        let vTangential = h / r2
        let vRadial = (mu / p).squareRoot() * e * sin(crossing)
        arrivalDeltaV = hypot(vRadial, (mu / r2).squareRoot() - vTangential)

        windowEveryDays = 1 / abs(1 / origin.yearLengthDays - 1 / target.yearLengthDays)
        originRadius = r1
        targetRadius = r2

        // Path length, summed along the arc.
        var length = 0.0
        let steps = 400
        let rStart = a * (1 - e * cos(Self.eccentricAnomaly(mean: startMean, e: e)))
        var last = (x: rStart, y: 0.0)
        for i in 1...steps {
            let m = startMean + (endMean - startMean) * Double(i) / Double(steps)
            let ecc = Self.eccentricAnomaly(mean: m, e: e)
            let nu = Self.trueAnomaly(ecc, e: e)
            let r = a * (1 - e * cos(ecc))
            let point = (x: r * cos(nu - startAnomaly), y: r * sin(nu - startAnomaly))
            length += hypot(point.x - last.x, point.y - last.y)
            last = point
        }
        transferDistanceKm = length
    }

    /// Where the spacecraft is a fraction `f` of the way through the flight:
    /// angle swept since departure (radians) and distance from the Sun (km).
    /// Follows Kepler's equation, so it's quick near the Sun and slow far out.
    func position(at f: Double) -> (swept: Double, r: Double) {
        let m = startMean + (endMean - startMean) * min(max(f, 0), 1)
        let ecc = Self.eccentricAnomaly(mean: m, e: e)
        var nu = Self.trueAnomaly(ecc, e: e)
        if !outbound && nu < .pi { nu += 2 * .pi }   // inbound runs π → 2π
        return (nu - startAnomaly, a * (1 - e * cos(ecc)))
    }

    // MARK: Kepler

    private static func meanAnomaly(_ nu: Double, e: Double) -> Double {
        var ecc = 2 * atan2((1 - e).squareRoot() * sin(nu / 2), (1 + e).squareRoot() * cos(nu / 2))
        if ecc < 0 { ecc += 2 * .pi }
        return ecc - e * sin(ecc)
    }

    private static func eccentricAnomaly(mean m: Double, e: Double) -> Double {
        var ecc = e > 0.8 ? Double.pi : m
        for _ in 0..<30 {
            ecc -= (ecc - e * sin(ecc) - m) / (1 - e * cos(ecc))
        }
        return ecc
    }

    private static func trueAnomaly(_ ecc: Double, e: Double) -> Double {
        var nu = 2 * atan2((1 + e).squareRoot() * sin(ecc / 2), (1 - e).squareRoot() * cos(ecc / 2))
        if nu < 0 { nu += 2 * .pi }
        return nu
    }
}

// MARK: - Launch windows

/// When the planets line up for a Hohmann transfer.
///
/// Positions come from JPL's mean orbital elements (J2000 mean longitude plus
/// its rate per century), treating orbits as circles. That's the same
/// simplification as `TransferOrbit`, and it lands within a few weeks of
/// real windows (Earth → Mars: May 2018, Sep 2024, Nov 2026).
enum LaunchWindow {
    /// Mean longitude at J2000 (degrees) and its rate (degrees per century).
    private static let elements: [String: (l0: Double, rate: Double)] = [
        "Mercury": (252.250_323_50, 149_472.674_111_75),
        "Venus": (181.979_099_50, 58_517.815_387_29),
        "Earth": (100.464_571_66, 35_999.372_449_81),
        "Mars": (-4.553_432_05, 19_140.302_684_99),
        "Jupiter": (34.396_440_51, 3_034.746_127_75),
        "Saturn": (49.954_244_23, 1_222.493_622_01),
        "Uranus": (313.238_104_51, 428.482_027_85),
        "Neptune": (-55.120_029_69, 218.459_453_25)
    ]

    /// 2000-01-01 12:00 TT, the J2000 epoch (as UTC — close enough here).
    private static let j2000 = Date(timeIntervalSince1970: 946_728_000)

    private static func daysSinceJ2000(_ date: Date) -> Double {
        date.timeIntervalSince(j2000) / 86_400
    }

    /// Mean motion, radians per day.
    static func meanMotion(_ planet: String) -> Double? {
        elements[planet].map { ($0.rate / 36_525) * .pi / 180 }
    }

    /// Mean longitude on a date, radians.
    static func longitude(_ planet: String, on date: Date) -> Double? {
        elements[planet].map { ($0.l0 + $0.rate * daysSinceJ2000(date) / 36_525) * .pi / 180 }
    }

    private static func wrap(_ angle: Double) -> Double {
        let r = angle.truncatingRemainder(dividingBy: 2 * .pi)
        return r < 0 ? r + 2 * .pi : r
    }

    /// The first launch window on or after `date`.
    ///
    /// The target has to be ahead of the origin by the angle the spacecraft
    /// sweeps (180° for Hohmann) minus the angle the target covers during the
    /// trip, so that both reach the meeting point at the same time.
    static func next(from origin: String, to target: String, travelDays: Double,
                     sweptAngle: Double = .pi, after date: Date) -> Date? {
        guard let nO = meanMotion(origin), let nT = meanMotion(target),
              let lO = longitude(origin, on: date), let lT = longitude(target, on: date),
              nO != nT else { return nil }

        let required = sweptAngle - nT * travelDays
        let current = lT - lO
        let relative = nT - nO      // how fast the gap between them changes
        let days = relative > 0
            ? wrap(required - current) / relative
            : wrap(current - required) / -relative
        return date.addingTimeInterval(days * 86_400)
    }

    /// Days between windows for this pair (the synodic period).
    static func synodicDays(_ origin: String, _ target: String) -> Double? {
        guard let nO = meanMotion(origin), let nT = meanMotion(target), nO != nT else { return nil }
        return 2 * .pi / abs(nT - nO)
    }

    /// The gap between gaps-closing speeds: how fast (radians per day) the
    /// target's lead over the origin changes. Negative when it shrinks.
    static func relativeRate(_ origin: String, _ target: String) -> Double? {
        guard let nO = meanMotion(origin), let nT = meanMotion(target) else { return nil }
        return nT - nO
    }

    /// Where the target is when the spacecraft reaches its orbit, measured
    /// from the meeting point: radians in (−π, π]. Zero is a perfect hit;
    /// positive means the target had already gone past.
    static func miss(from origin: String, to target: String, transfer: TransferOrbit, launch: Date) -> Double? {
        guard let lO = longitude(origin, on: launch), let lT = longitude(target, on: launch),
              let nT = meanMotion(target) else { return nil }
        let gap = wrap(lT + nT * transfer.travelDays - (lO + transfer.sweptAngle))
        return gap > .pi ? gap - 2 * .pi : gap
    }

    /// How far either side of the ideal day still counts as "in the window".
    /// Real windows last a few weeks; scaled down for pairs that line up often.
    static func tolerance(synodicDays: Double) -> Double {
        min(30, max(5, synodicDays * 0.03))
    }
}

// MARK: - Formatting

/// Number formats shared by Mission Builder, Mission Control and the share card.
enum MissionFormat {
    /// Days under ~2 months read as days, under ~2 years as months, then years.
    static func duration(_ days: Double) -> String {
        if days < 60 {
            return String(format: String(localized: "%@ days", bundle: Bundle.appLanguage), MetricFormat.plain(days, decimals: 0))
        }
        if days < 730 {
            return String(format: String(localized: "%@ months", bundle: Bundle.appLanguage), MetricFormat.plain(days / 30.44, decimals: 1))
        }
        return String(format: String(localized: "%@ years", bundle: Bundle.appLanguage), MetricFormat.plain(days / 365.25, decimals: 1))
    }

    static func deltaV(_ kmPerSecond: Double) -> String {
        String(format: String(localized: "%@ km/s", bundle: Bundle.appLanguage), MetricFormat.plain(kmPerSecond, decimals: 1))
    }
}

// MARK: - Real missions

/// Real spacecraft that made the same trip, for scale. Times are launch to
/// arrival (orbit insertion, landing or closest flyby).
struct RealMission: Identifiable {
    let name: String
    let year: Int
    let days: Double
    var id: String { name }

    private static let byRoute: [String: [RealMission]] = [
        "Earth→Mercury": [RealMission(name: "MESSENGER", year: 2004, days: 2_418),
                          RealMission(name: "BepiColombo", year: 2018, days: 2_600)],
        "Earth→Venus": [RealMission(name: "Venus Express", year: 2005, days: 153),
                        RealMission(name: "Magellan", year: 1989, days: 462)],
        "Earth→Mars": [RealMission(name: "Perseverance", year: 2020, days: 203),
                       RealMission(name: "Curiosity", year: 2011, days: 254),
                       RealMission(name: "InSight", year: 2018, days: 205)],
        "Earth→Jupiter": [RealMission(name: "Juno", year: 2011, days: 1_795),
                          RealMission(name: "Galileo", year: 1989, days: 2_242)],
        "Earth→Saturn": [RealMission(name: "Cassini", year: 1997, days: 2_451),
                         RealMission(name: "Voyager 1", year: 1977, days: 1_168)],
        "Earth→Uranus": [RealMission(name: "Voyager 2", year: 1977, days: 3_079)],
        "Earth→Neptune": [RealMission(name: "Voyager 2", year: 1977, days: 4_389)]
    ]

    static func missions(from origin: String, to target: String) -> [RealMission] {
        byRoute["\(origin)→\(target)"] ?? []
    }
}

// MARK: - View

/// Laid out like Compare Planets: the two planets side by side, a pair of
/// menus to pick them, one card of results and a plain-language takeaway.
struct MissionBuilderView: View {
    private static let planetNames = ["Mercury", "Venus", "Earth", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune"]

    // The route is remembered between visits; the launch date starts at
    // today each time, since a saved date would soon be in the past.
    @AppStorage("missionOrigin") private var storedOrigin = "Earth"
    @AppStorage("missionTarget") private var storedTarget = "Mars"
    /// 0 = cheapest (Hohmann), 1 = fastest this app allows.
    @AppStorage("missionSpeed") private var speed = 0.0
    @State private var launchDate = Date()

    /// Opens on a given route and date (from Mission Control's real launch
    /// windows) instead of the remembered one.
    struct Preset {
        let origin: String
        let target: String
        let launchDate: Date
    }
    var preset: Preset? = nil
    @State private var presetApplied = false

    /// Saved values are checked, so a bad or stale entry can't leave the
    /// screen with no route.
    private var origin: String {
        get { Self.planetNames.contains(storedOrigin) ? storedOrigin : "Earth" }
        nonmutating set { storedOrigin = newValue }
    }
    private var target: String {
        get {
            let t = Self.planetNames.contains(storedTarget) ? storedTarget : "Mars"
            return t == origin ? (origin == "Mars" ? "Earth" : "Mars") : t
        }
        nonmutating set { storedTarget = newValue }
    }
    /// Written by the Age Calculator; read here for "your age on arrival".
    @AppStorage("ageOnEarth") private var ageOnEarth = ""
    @AppStorage(Crew.storageKey) private var crewJSON = ""
    @AppStorage(Spacecraft.nameKey) private var craftName = ""
    @AppStorage(Spacecraft.colorKey) private var craftColor = 0
    @AppStorage(Spacecraft.iconKey) private var craftIcon = 0

    private var isPhone: Bool { deviceType() == "iPhone" }

    private var transfer: TransferOrbit? {
        guard let o = PlanetMetrics.metrics(for: origin),
              let t = PlanetMetrics.metrics(for: target) else { return nil }
        return TransferOrbit(from: o, to: t, speed: speed)
    }

    var body: some View {
        ZStack {
            AppGradientBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    route
                    pickers
                    launchDateCard
                    speedCard
                    if let transfer {
                        windowCard(transfer)
                        resultsCard(transfer)
                        roundTripCard(transfer)
                        travellerCard(transfer)
                        realMissionsCard(transfer)
                        summary
                        challengeLink
                    }
                }
                .padding()
                .frame(maxWidth: 700)
                .frame(maxWidth: .infinity)
            }
        }
        .appNavigationStyle("Mission Builder")
        .onAppear {
            guard let preset, !presetApplied else { return }
            presetApplied = true
            origin = preset.origin
            target = preset.target
            speed = 0
            launchDate = preset.launchDate
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if let transfer {
                    ShareLink(item: MissionSnapshot(summary: summary(transfer)),
                              preview: SharePreview(Text("My mission to \(target.localizedBodyName)"),
                                                    image: Image(target))) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.white)
                    }
                    .accessibilityLabel(Text("Share mission"))
                }
            }
        }
    }

    // MARK: Share

    private func isAligned(_ t: TransferOrbit) -> Bool {
        if case .open = windowStatus(t) { return true }
        return false
    }

    private func summary(_ t: TransferOrbit) -> MissionSummary {
        MissionSummary(origin: origin, target: target, launchDate: launchDate, transfer: t,
                       isAligned: isAligned(t),
                       travelTime: durationText(t.travelDays),
                       deltaV: String(format: String(localized: "%@ km/s", bundle: Bundle.appLanguage),
                                      MetricFormat.plain(t.totalDeltaV, decimals: 1)),
                       wholeMission: roundTrip(t).map { durationText($0.totalDays) })
    }

    // MARK: Route

    /// The animated orbit diagram, or nothing until two different planets
    /// are picked.
    @ViewBuilder
    private var route: some View {
        if let transfer {
            TransferOrbitDiagram(origin: origin, target: target, launchDate: launchDate,
                                 transfer: transfer, isAligned: isAligned(transfer))
        }
    }

    // MARK: Pickers

    private var pickers: some View {
        HStack(spacing: 12) {
            planetMenu(selection: Binding(get: { origin }, set: { origin = $0 }), exclude: target)
            Button {
                playHaptic(.light)
                let previous = origin
                origin = target
                target = previous
            } label: {
                Image(systemName: "arrow.left.arrow.right")
                    .foregroundColor(.white.opacity(0.7))
            }
            .accessibilityLabel("Swap planets")
            planetMenu(selection: Binding(get: { target }, set: { target = $0 }), exclude: origin)
        }
    }

    /// Excludes the other side's pick — a trip to where you already are is noise.
    private func planetMenu(selection: Binding<String>, exclude: String) -> some View {
        Menu {
            ForEach(Self.planetNames.filter { $0 != exclude }, id: \.self) { name in
                Button(name.localizedBodyName) {
                    playHaptic(.light)
                    selection.wrappedValue = name
                }
            }
        } label: {
            HStack {
                Text(selection.wrappedValue.localizedBodyName)
                    .font(AppFont.bold(isPhone ? 15 : 21))
                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: isPhone ? 11 : 15))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.3))
            .cornerRadius(14)
        }
    }

    private var launchDateCard: some View {
        DatePicker(selection: $launchDate, displayedComponents: .date) {
            Text("Launch date")
                .font(AppFont.regular(isPhone ? 14 : 20))
                .foregroundColor(.white)
        }
        .colorScheme(.dark)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .appCard()
    }

    // MARK: Speed

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
            .onChange(of: speed == 0 || speed == 1) { _, atEnd in
                if atEnd { playHaptic(.light) }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .appCard()
        // The slider runs cheap → fast left to right in every language,
        // matching the fuel / hare icons at each end.
        .environment(\.layoutDirection, .leftToRight)
    }

    // MARK: Round trip

    private struct RoundTrip {
        let waitDays: Double
        let returnDays: Double
        let totalDays: Double
        let homeDate: Date
    }

    /// Fly out, wait at the destination for the planets to line up again,
    /// then fly home on the same kind of route.
    private func roundTrip(_ t: TransferOrbit) -> RoundTrip? {
        guard let o = PlanetMetrics.metrics(for: origin),
              let tg = PlanetMetrics.metrics(for: target),
              let back = TransferOrbit(from: tg, to: o, speed: speed) else { return nil }
        let arrival = launchDate.addingTimeInterval(t.travelDays * 86_400)
        guard let leave = LaunchWindow.next(from: target, to: origin, travelDays: back.travelDays,
                                            sweptAngle: back.sweptAngle, after: arrival) else { return nil }
        let wait = leave.timeIntervalSince(arrival) / 86_400
        let home = leave.addingTimeInterval(back.travelDays * 86_400)
        return RoundTrip(waitDays: wait, returnDays: back.travelDays,
                         totalDays: home.timeIntervalSince(launchDate) / 86_400, homeDate: home)
    }

    @ViewBuilder
    private func roundTripCard(_ t: TransferOrbit) -> some View {
        if let trip = roundTrip(t) {
            VStack(spacing: 0) {
                Text("Round trip")
                    .font(AppFont.regular(isPhone ? 12 : 17))
                    .foregroundColor(.white.opacity(0.55))
                    .frame(maxWidth: .infinity)
                    .padding(.top, 12)
                    .padding(.bottom, 4)
                divider
                resultRow(icon: "hourglass", title: "Wait on \(target.localizedBodyName)", value: durationText(trip.waitDays))
                divider
                resultRow(icon: "arrow.uturn.backward", title: "Flight home", value: durationText(trip.returnDays))
                divider
                resultRow(icon: "house.fill", title: "Back on \(origin.localizedBodyName)",
                          value: trip.homeDate.formatted(.dateTime.day().month(.wide).year().locale(AppLanguage.locale)))
                divider
                resultRow(icon: "sum", title: "Whole mission", value: durationText(trip.totalDays))
            }
            .appCard()
        }
    }

    // MARK: Launch window

    private enum WindowStatus {
        case open
        case closed(next: Date)
    }

    /// Whether the chosen date is close to an alignment, and if not, when the
    /// next one is. Also looks back one period, so a date just after the ideal
    /// day still counts as open.
    private func windowStatus(_ t: TransferOrbit) -> WindowStatus? {
        guard let synodic = LaunchWindow.synodicDays(origin, target) else { return nil }
        let tolerance = LaunchWindow.tolerance(synodicDays: synodic) * 86_400
        let searchFrom = launchDate.addingTimeInterval(-tolerance)
        guard let ideal = LaunchWindow.next(from: origin, to: target, travelDays: t.travelDays,
                                                 sweptAngle: t.sweptAngle, after: searchFrom) else {
            return nil
        }
        return abs(ideal.timeIntervalSince(launchDate)) <= tolerance ? .open : .closed(next: ideal)
    }

    @ViewBuilder
    private func windowCard(_ t: TransferOrbit) -> some View {
        if let status = windowStatus(t) {
            switch status {
            case .open:
                windowBanner(icon: "checkmark.circle.fill", color: .green,
                             title: "Launch window open",
                             detail: Text("The planets line up — a great day to launch."))
            case .closed(let next):
                let days = Int((next.timeIntervalSince(launchDate) / 86_400).rounded(.up))
                VStack(spacing: 12) {
                    windowBanner(icon: "exclamationmark.triangle.fill", color: .orange,
                                 title: "Planets aren't lined up",
                                 detail: Text("Next launch window: \(next.formatted(.dateTime.day().month(.wide).year().locale(AppLanguage.locale))) (in \(MetricFormat.plain(Double(days), decimals: 0)) days)"))

                    Button {
                        playHaptic(.light)
                        withAnimation(.easeInOut(duration: 0.3)) { launchDate = next }
                    } label: {
                        Label("Jump to launch window", systemImage: "calendar.badge.clock")
                            .font(AppFont.bold(isPhone ? 15 : 21))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(14)
                    }
                }
            }
        }
    }

    private func windowBanner(icon: String, color: Color, title: LocalizedStringKey, detail: Text) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: isPhone ? 18 : 24))
                .foregroundColor(color)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppFont.bold(isPhone ? 15 : 21))
                    .foregroundColor(.white)
                detail
                    .font(AppFont.regular(isPhone ? 13 : 18))
                    .foregroundColor(.white.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .appCard(cornerRadius: 16)
        .accessibilityElement(children: .combine)
    }

    // MARK: Results

    private func resultsCard(_ t: TransferOrbit) -> some View {
        let arrival = Calendar.current.date(byAdding: .day, value: Int(t.travelDays.rounded()), to: launchDate) ?? launchDate

        return VStack(spacing: 0) {
            resultRow(icon: "clock.fill", title: "Travel time", value: durationText(t.travelDays))
            divider
            resultRow(icon: "calendar", title: "Arrival", value: arrival.formatted(.dateTime.day().month(.wide).year().locale(AppLanguage.locale)))
            divider
            resultRow(icon: "point.topleft.down.to.point.bottomright.curvepath.fill", title: "Distance flown", value: MetricFormat.km(t.transferDistanceKm))
            divider
            resultRow(icon: "flame.fill", title: "Engine burns (Δv)",
                      value: String(format: String(localized: "%@ km/s", bundle: Bundle.appLanguage), MetricFormat.plain(t.totalDeltaV, decimals: 1)))
            divider
            resultRow(icon: "arrow.triangle.2.circlepath", title: "Launch window every", value: durationText(LaunchWindow.synodicDays(origin, target) ?? t.windowEveryDays))
            if let delay = signalDelaySeconds(t) {
                divider
                resultRow(icon: "antenna.radiowaves.left.and.right",
                          title: "Message to \(origin.localizedBodyName)",
                          value: signalText(delay))
            }
        }
        .appCard()
    }

    // MARK: Traveller

    private var earthAge: Double? {
        guard let age = MetricFormat.parse(ageOnEarth), age > 0 else { return nil }
        return age
    }

    /// Makes the trip personal: the spacecraft, everyone's age on arrival
    /// and back home, and whether there's enough food on board.
    private func travellerCard(_ t: TransferOrbit) -> some View {
        let crew = Crew.decode(crewJSON)
        let people = 1 + crew.count
        let trip = roundTrip(t)
        let food = Supplies.kg(crew: people, days: t.travelDays)
        let fill = food / Supplies.holdKg
        let barColor: Color = fill <= 0.8 ? .green : fill <= 1 ? .yellow : .orange

        return VStack(spacing: 0) {
            NavigationLink {
                SpacecraftView()
            } label: {
                HStack(spacing: 12) {
                    SpacecraftBadge(colorIndex: craftColor, iconIndex: craftIcon, size: isPhone ? 34 : 46)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(Spacecraft.displayName(craftName))
                            .font(AppFont.bold(isPhone ? 15 : 21))
                            .foregroundColor(.white)
                        Text("Crew of \(people)")
                            .font(AppFont.regular(isPhone ? 12 : 17))
                            .foregroundColor(.white.opacity(0.55))
                    }
                    Spacer(minLength: 8)
                    Text("Edit")
                        .font(AppFont.bold(isPhone ? 14 : 20))
                        .foregroundColor(.cyan)
                    Image(systemName: "chevron.forward")
                        .font(.system(size: isPhone ? 12 : 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.4))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            divider
            crewRow(name: Text("You"), age: earthAge, t: t, trip: trip)
            ForEach(Array(crew.enumerated()), id: \.element.id) { i, member in
                divider
                crewRow(name: member.name.trimmingCharacters(in: .whitespaces).isEmpty
                            ? Text("Crewmate \(i + 1)") : Text(verbatim: member.name),
                        age: member.age, t: t, trip: trip)
            }
            divider

            // Supplies: a long trip has to carry a lot of food.
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    Image(systemName: "fork.knife")
                        .font(.system(size: isPhone ? 15 : 21))
                        .foregroundColor(.white.opacity(0.7))
                        .frame(width: isPhone ? 22 : 30)
                    Text("Food for the flight")
                        .font(AppFont.regular(isPhone ? 14 : 20))
                        .foregroundColor(.white.opacity(0.8))
                    Spacer(minLength: 8)
                    Text(verbatim: "\(Supplies.weight(food)) / \(Supplies.weight(Supplies.holdKg))")
                        .font(AppFont.bold(isPhone ? 14 : 20))
                        .foregroundColor(barColor)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.black.opacity(0.3))
                        Capsule().fill(barColor)
                            .frame(width: max(6, geo.size.width * min(fill, 1)))
                    }
                }
                .frame(height: 8)
                .environment(\.layoutDirection, .leftToRight)
                .animation(.easeInOut(duration: 0.25), value: fill)

                Group {
                    if fill > 1 {
                        Text("Too much for the hold! Pick a faster route or a smaller crew.")
                            .foregroundColor(.orange)
                    } else {
                        Text("\(people) people × \(MissionFormat.duration(t.travelDays)) × 1.7 kg a day")
                            .foregroundColor(.white.opacity(0.55))
                    }
                }
                .font(AppFont.regular(isPhone ? 12 : 17))
                .fixedSize(horizontal: false, vertical: true)

                if let trip {
                    Text("Whole round trip: \(Supplies.weight(Supplies.kg(crew: people, days: trip.totalDays))) of food")
                        .font(AppFont.regular(isPhone ? 12 : 17))
                        .foregroundColor(.white.opacity(0.55))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .accessibilityElement(children: .combine)
        }
        .appCard()
    }

    /// One person: their age on arrival, and when they're back home.
    @ViewBuilder
    private func crewRow(name: Text, age: Double?, t: TransferOrbit, trip: RoundTrip?) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "person.fill")
                .font(.system(size: isPhone ? 15 : 21))
                .foregroundColor(.white.opacity(0.7))
                .frame(width: isPhone ? 22 : 30)
            name
                .font(AppFont.regular(isPhone ? 14 : 20))
                .foregroundColor(.white)
                .lineLimit(1)
            Spacer(minLength: 8)
            if let age {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(MetricFormat.plain(age + t.travelDays / 365.25, decimals: 1)) on arrival")
                        .font(AppFont.bold(isPhone ? 14 : 20))
                        .foregroundColor(.white)
                    if let trip {
                        Text("\(MetricFormat.plain(age + trip.totalDays / 365.25, decimals: 1)) back home")
                            .font(AppFont.regular(isPhone ? 12 : 17))
                            .foregroundColor(.white.opacity(0.55))
                    }
                }
            } else {
                NavigationLink {
                    PlanetAgeCalculatorView()
                } label: {
                    Text("Add your age")
                        .font(AppFont.bold(isPhone ? 14 : 20))
                        .foregroundColor(.cyan)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .accessibilityElement(children: .combine)
    }

    // MARK: Real missions

    @ViewBuilder
    private func realMissionsCard(_ t: TransferOrbit) -> some View {
        let missions = RealMission.missions(from: origin, to: target)
        if !missions.isEmpty {
            VStack(spacing: 0) {
                Text("Real missions")
                    .font(AppFont.regular(isPhone ? 12 : 17))
                    .foregroundColor(.white.opacity(0.55))
                    .frame(maxWidth: .infinity)
                    .padding(.top, 12)
                    .padding(.bottom, 4)

                ForEach(missions) { mission in
                    divider
                    missionRow(mission, yourDays: t.travelDays)
                }

                divider
                Text("Real missions often fly faster routes, or swing past other planets to pick up speed.")
                    .font(AppFont.regular(isPhone ? 12 : 17))
                    .foregroundColor(.white.opacity(0.55))
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }
            .appCard()
        }
    }

    /// The faster of the two (your route or theirs) is brightened, as on Compare.
    private func missionRow(_ mission: RealMission, yourDays: Double) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "airplane.departure")
                .font(.system(size: isPhone ? 15 : 21))
                .foregroundColor(.white.opacity(0.7))
                .frame(width: isPhone ? 22 : 30)
            VStack(alignment: .leading, spacing: 2) {
                // Spacecraft names are proper nouns; shown as-is.
                Text(verbatim: mission.name)
                    .font(AppFont.regular(isPhone ? 14 : 20))
                    .foregroundColor(.white)
                Text(mission.year.formatted(.number.grouping(.never).locale(AppLanguage.locale)))
                    .font(AppFont.regular(isPhone ? 12 : 17))
                    .foregroundColor(.white.opacity(0.55))
            }
            Spacer(minLength: 8)
            Text(durationText(mission.days))
                .font(AppFont.bold(isPhone ? 15 : 21))
                .foregroundColor(.white.opacity(mission.days < yourDays ? 1 : 0.6))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
    }

    // MARK: Signal delay

    /// How long a radio message takes from the target back to the origin
    /// planet, on the day you arrive. Uses both planets' real positions then.
    private func signalDelaySeconds(_ t: TransferOrbit) -> Double? {
        guard let o = PlanetMetrics.metrics(for: origin),
              let tg = PlanetMetrics.metrics(for: target) else { return nil }
        let arrival = launchDate.addingTimeInterval(t.travelDays * 86_400)
        guard let lO = LaunchWindow.longitude(origin, on: arrival),
              let lT = LaunchWindow.longitude(target, on: arrival) else { return nil }
        let r1 = o.distanceFromSunKm, r2 = tg.distanceFromSunKm
        let distance = (r1 * r1 + r2 * r2 - 2 * r1 * r2 * cos(lT - lO)).squareRoot()
        return distance / 299_792.458
    }

    private func signalText(_ seconds: Double) -> String {
        if seconds < 90 {
            return String(format: String(localized: "%@ seconds", bundle: Bundle.appLanguage), MetricFormat.plain(seconds, decimals: 0))
        }
        if seconds < 90 * 60 {
            return String(format: String(localized: "%@ minutes", bundle: Bundle.appLanguage), MetricFormat.plain(seconds / 60, decimals: 0))
        }
        return String(format: String(localized: "%@ hours", bundle: Bundle.appLanguage), MetricFormat.plain(seconds / 3_600, decimals: 1))
    }

    private var divider: some View {
        Divider().overlay(Color.white.opacity(0.15))
    }

    private func resultRow(icon: String, title: LocalizedStringKey, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: isPhone ? 15 : 21))
                .foregroundColor(.white.opacity(0.7))
                .frame(width: isPhone ? 22 : 30)
            Text(title)
                .font(AppFont.regular(isPhone ? 14 : 20))
                .foregroundColor(.white.opacity(0.8))
            Spacer(minLength: 8)
            Text(value)
                .font(AppFont.bold(isPhone ? 15 : 21))
                .foregroundColor(.white)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
    }

    // MARK: Challenge link

    /// Sends players who've got the hang of it to Mission Control.
    private var challengeLink: some View {
        NavigationLink {
            MissionChallengesView()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "flag.checkered")
                    .font(.system(size: isPhone ? 16 : 22, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: isPhone ? 34 : 46, height: isPhone ? 34 : 46)
                    .background(RoundedRectangle(cornerRadius: 10)
                        .fill(LinearGradient(colors: [.orange, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Ready for a challenge?")
                        .font(AppFont.bold(isPhone ? 15 : 21))
                        .foregroundColor(.white)
                    Text("Plan real missions and earn stars")
                        .font(AppFont.regular(isPhone ? 12 : 17))
                        .foregroundColor(.white.opacity(0.6))
                }
                Spacer(minLength: 8)
                Image(systemName: "chevron.forward")
                    .font(.system(size: isPhone ? 12 : 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(14)
            .appCard(cornerRadius: 16)
        }
        .buttonStyle(.plain)
    }

    // MARK: Summary

    private var summary: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(.yellow)
            VStack(alignment: .leading, spacing: 8) {
                Text("Spacecraft don't fly straight at a planet. They take a Hohmann transfer: half an ellipse that touches both orbits, which uses the least fuel. The planets must be lined up just right, so launch windows only open every so often.")
                    .font(AppFont.regular(isPhone ? 14 : 20))
                    .foregroundColor(.white)
                Text("Figures assume circular orbits and ignore escaping each planet's gravity.")
                    .font(AppFont.regular(isPhone ? 11 : 15))
                    .foregroundColor(.white.opacity(0.55))
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .appCard(cornerRadius: 16)
        .accessibilityElement(children: .combine)
    }

    private func durationText(_ days: Double) -> String {
        MissionFormat.duration(days)
    }
}

#Preview {
    NavigationStack { MissionBuilderView() }
}
