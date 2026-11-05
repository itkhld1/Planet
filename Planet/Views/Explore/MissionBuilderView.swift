//
//  MissionBuilderView.swift
//  Planet
//
//  Plan a trip between two planets. The default is a Hohmann transfer — the
//  minimum-energy route real missions are based on — and a slider trades
//  extra fuel for a faster trip. The maths lives in `MissionPlan`,
//  `TransferOrbit` and `LaunchWindow`.
//

import SwiftUI

/// Laid out like Compare Planets: the two planets side by side, a pair of
/// menus to pick them, one card of results and a plain-language takeaway.
struct MissionBuilderView: View {
    private static let planetNames = ["Mercury", "Venus", "Earth", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune"]

    // The route is remembered between visits; the launch date starts at
    // today each time, since a saved date would soon be in the past.
    @AppStorage(SettingsKey.missionOrigin) private var storedOrigin = "Earth"
    @AppStorage(SettingsKey.missionTarget) private var storedTarget = "Mars"
    /// 0 = cheapest (Hohmann), 1 = fastest this app allows.
    @AppStorage(SettingsKey.missionSpeed) private var speed = 0.0
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

    private var isPhone: Bool { deviceType() == "iPhone" }

    private var plan: MissionPlan? {
        MissionPlan(origin: origin, target: target, launchDate: launchDate, speed: speed)
    }

    var body: some View {
        ZStack {
            AppGradientBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    if let plan {
                        TransferOrbitDiagram(origin: origin, target: target, launchDate: launchDate,
                                             transfer: plan.transfer, isAligned: plan.isAligned)
                    }
                    pickers
                    launchDateCard
                    RouteSpeedCard(speed: $speed, hapticAtEnds: true)
                    if let plan {
                        windowCard(plan)
                        resultsCard(plan)
                        roundTripCard(plan)
                        MissionTravellerCard(plan: plan)
                        realMissionsCard(plan)
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
                if let plan {
                    ShareLink(item: MissionSnapshot(summary: shareSummary(plan)),
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

    private func shareSummary(_ plan: MissionPlan) -> MissionSummary {
        MissionSummary(origin: origin, target: target, launchDate: launchDate, transfer: plan.transfer,
                       isAligned: plan.isAligned,
                       travelTime: MissionFormat.duration(plan.transfer.travelDays),
                       deltaV: MissionFormat.deltaV(plan.transfer.totalDeltaV),
                       wholeMission: plan.roundTrip.map { MissionFormat.duration($0.totalDays) })
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
            .background(Palette.card)
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

    // MARK: Launch window

    @ViewBuilder
    private func windowCard(_ plan: MissionPlan) -> some View {
        switch plan.windowStatus {
        case .open:
            windowBanner(icon: "checkmark.circle.fill", color: Palette.success,
                         title: "Launch window open",
                         detail: Text("The planets line up — a great day to launch."))
        case .closed(let next):
            let days = Int((next.timeIntervalSince(launchDate) / 86_400).rounded(.up))
            VStack(spacing: 12) {
                windowBanner(icon: "exclamationmark.triangle.fill", color: Palette.warning,
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
                        .background(Palette.card)
                        .cornerRadius(14)
                }
            }
        case nil:
            EmptyView()
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

    private func resultsCard(_ plan: MissionPlan) -> some View {
        let t = plan.transfer
        return VStack(spacing: 0) {
            resultRow(icon: "clock.fill", title: "Travel time", value: MissionFormat.duration(t.travelDays))
            CardDivider()
            resultRow(icon: "calendar", title: "Arrival",
                      value: plan.arrivalDay.formatted(.dateTime.day().month(.wide).year().locale(AppLanguage.locale)))
            CardDivider()
            resultRow(icon: "point.topleft.down.to.point.bottomright.curvepath.fill", title: "Distance flown",
                      value: MetricFormat.km(t.transferDistanceKm))
            CardDivider()
            resultRow(icon: "flame.fill", title: "Engine burns (Δv)", value: MissionFormat.deltaV(t.totalDeltaV))
            CardDivider()
            resultRow(icon: "arrow.triangle.2.circlepath", title: "Launch window every",
                      value: MissionFormat.duration(plan.windowEveryDays))
            if let delay = plan.signalDelaySeconds {
                CardDivider()
                resultRow(icon: "antenna.radiowaves.left.and.right",
                          title: "Message to \(origin.localizedBodyName)",
                          value: MissionFormat.signalDelay(delay))
            }
        }
        .appCard()
    }

    @ViewBuilder
    private func roundTripCard(_ plan: MissionPlan) -> some View {
        if let trip = plan.roundTrip {
            VStack(spacing: 0) {
                cardHeader("Round trip")
                CardDivider()
                resultRow(icon: "hourglass", title: "Wait on \(target.localizedBodyName)",
                          value: MissionFormat.duration(trip.waitDays))
                CardDivider()
                resultRow(icon: "arrow.uturn.backward", title: "Flight home",
                          value: MissionFormat.duration(trip.returnDays))
                CardDivider()
                resultRow(icon: "house.fill", title: "Back on \(origin.localizedBodyName)",
                          value: trip.homeDate.formatted(.dateTime.day().month(.wide).year().locale(AppLanguage.locale)))
                CardDivider()
                resultRow(icon: "sum", title: "Whole mission", value: MissionFormat.duration(trip.totalDays))
            }
            .appCard()
        }
    }

    // MARK: Real missions

    @ViewBuilder
    private func realMissionsCard(_ plan: MissionPlan) -> some View {
        let missions = RealMission.missions(from: origin, to: target)
        if !missions.isEmpty {
            VStack(spacing: 0) {
                cardHeader("Real missions")

                ForEach(missions) { mission in
                    CardDivider()
                    missionRow(mission, yourDays: plan.transfer.travelDays)
                }

                CardDivider()
                Text("Real missions often fly faster routes, or swing past other planets to pick up speed.")
                    .font(AppFont.regular(isPhone ? 12 : 17))
                    .foregroundColor(Palette.secondaryText)
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
                    .foregroundColor(Palette.secondaryText)
            }
            Spacer(minLength: 8)
            Text(MissionFormat.duration(mission.days))
                .font(AppFont.bold(isPhone ? 15 : 21))
                .foregroundColor(.white.opacity(mission.days < yourDays ? 1 : 0.6))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
    }

    // MARK: Rows

    private func cardHeader(_ title: LocalizedStringKey) -> some View {
        Text(title)
            .font(AppFont.regular(isPhone ? 12 : 17))
            .foregroundColor(Palette.secondaryText)
            .frame(maxWidth: .infinity)
            .padding(.top, 12)
            .padding(.bottom, 4)
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
                        .foregroundColor(Palette.secondaryText)
                }
                Spacer(minLength: 8)
                Image(systemName: "chevron.forward")
                    .font(.system(size: isPhone ? 12 : 16, weight: .semibold))
                    .foregroundColor(Palette.secondaryText)
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
                .foregroundColor(Palette.amber)
            VStack(alignment: .leading, spacing: 8) {
                Text("Spacecraft don't fly straight at a planet. They take a Hohmann transfer: half an ellipse that touches both orbits, which uses the least fuel. The planets must be lined up just right, so launch windows only open every so often.")
                    .font(AppFont.regular(isPhone ? 14 : 20))
                    .foregroundColor(.white)
                Text("Figures assume circular orbits and ignore escaping each planet's gravity.")
                    .font(AppFont.regular(isPhone ? 11 : 15))
                    .foregroundColor(Palette.secondaryText)
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .appCard(cornerRadius: 16)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack { MissionBuilderView() }
}
