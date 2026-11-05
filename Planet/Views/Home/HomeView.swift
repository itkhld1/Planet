//
//  HomeView.swift
//  Planet
//
//  Created by itkhld on 2024-10-04.
//

import SwiftUI
import StoreKit

struct HomeView: View {

    @State private var selectedPlanet: Planet?
    @State private var selectedStar: Star?

    // Zoom and pan. Both gestures apply small steps as they go (instead of
    // their total since the gesture began), so they can run together and
    // each new pinch continues from the current zoom.
    @State private var zoom: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var lastPinch: CGFloat?
    @State private var lastDrag: CGSize?

    /// Orbits are driven from this clock rather than `repeatForever`
    /// animations. Those, started in `onAppear`, also animated the screen's
    /// first layout, so the whole tab slowly grew in from the corner.
    @State private var clock = MapClock()
    @State private var isVisible = false
    @AppStorage(SettingsKey.mapDaysPerSecond) private var daysPerSecond = MapSpeed.defaultDaysPerSecond

    @AppStorage(SettingsKey.showPlanetLabels) private var showLabels = true
    @AppStorage(SettingsKey.hasSeenMapHint) private var hasSeenHint = false
    @State private var showHint = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.requestReview) private var requestReview
    @State private var didStart = false

    private let minZoom: CGFloat = 0.5
    private let maxZoom: CGFloat = 3

    private var isOffCenter: Bool {
        offset != .zero || zoom != 1
    }

    var body: some View {
        NavigationStack {
            // The map is laid out on the whole screen, so the Sun sits in its
            // true middle rather than the middle of the space between the
            // navigation bar and the tab bar.
            GeometryReader { geo in
                // Sizes are designed for an iPhone; larger screens scale up
                // so the system fills them.
                let fit: CGFloat = max(1, min(geo.size.width, geo.size.height) / 450)
                let scale: CGFloat = fit * zoom

                ZStack {
                    background

                    TimelineView(.animation(paused: !isVisible)) { context in
                        SolarSystemMap(
                            date: clock.date(at: context.date),
                            sunSpin: reduceMotion ? 0 : context.date.timeIntervalSinceReferenceDate,
                            scale: scale,
                            // Below 1× the orbits are too close for labels.
                            showLabels: showLabels && zoom >= 1,
                            labelScale: min(fit, 1.4),
                            selectedPlanet: $selectedPlanet,
                            selectedStar: $selectedStar
                        )
                    }
                    // The map is a spatial diagram, not text. Mirroring it in
                    // Persian would flip the orbits and put the planets in the
                    // wrong physical order, so this subtree stays left-to-right
                    // while the rest of the app follows the language.
                    .environment(\.layoutDirection, .leftToRight)
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("Solar System")
                    .offset(offset)
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .contentShape(Rectangle())
                .gesture(panGesture(fit: fit).simultaneously(with: pinchGesture(fit: fit)))
                .onTapGesture(count: 2) {
                    dismissHint()
                    recenter()
                }
            }
            .ignoresSafeArea()
            .overlay(alignment: .bottom) {
                VStack(spacing: 14) {
                    if showHint {
                        hint
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                    HStack(alignment: .bottom, spacing: 12) {
                        labelsButton
                        timeCard
                            .frame(maxWidth: 320)
                            .frame(maxWidth: .infinity)
                        // Always laid out, so the time card stays centred.
                        recenterButton
                            .opacity(isOffCenter ? 1 : 0)
                            .disabled(!isOffCenter)
                            .accessibilityHidden(!isOffCenter)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Solar System")
                        .font(AppFont.regular(15))
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
            }
            .sheet(item: $selectedPlanet, onDismiss: askForReviewIfDeserved) { planet in
                PlanetDetailView(planet: planet)
                    .appLanguageEnvironment()
                    .presentationDragIndicator(.visible)
                    // Opens half-height so the map stays in view; drag up
                    // for the rest.
                    .presentationDetents([.medium, .large])
            }
            .sheet(item: $selectedStar, onDismiss: askForReviewIfDeserved) { star in
                SunDetailView(star: star)
                    .appLanguageEnvironment()
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.medium, .large])
            }
            .onChange(of: selectedPlanet?.id) {
                guard selectedPlanet != nil else { return }
                dismissHint()
                ReviewPrompt.recordInteraction()
            }
            .onChange(of: selectedStar?.id) {
                guard selectedStar != nil else { return }
                dismissHint()
                ReviewPrompt.recordInteraction()
            }
            .onAppear {
                isVisible = true
                clock.setSpeed(currentSpeed)
                // With Reduce Motion on, open on today's positions, standing
                // still; Play is one tap away.
                if !didStart {
                    didStart = true
                    clock.jumpToToday()
                    if reduceMotion { clock.setPlaying(false) }
                }
                // Time stands still while the tab is hidden, so it doesn't
                // jump months ahead on return.
                clock.setSuspended(false)
                presentHintIfNeeded()
            }
            .onDisappear {
                isVisible = false
                clock.setSuspended(true)
            }
        }
    }

    // MARK: Review

    /// After a few planets explored, ask for a rating once they're back on
    /// the map: they've just enjoyed something, and they aren't mid-read.
    private func askForReviewIfDeserved() {
        guard ReviewPrompt.shouldAskAfterInteractions() else { return }
        // Let the sheet finish sliding away first.
        Task {
            try? await Task.sleep(for: .seconds(1))
            requestReview()
        }
    }

    // MARK: First-run hint

    private func presentHintIfNeeded() {
        guard !hasSeenHint, !showHint else { return }
        withAnimation(.easeOut.delay(0.6)) { showHint = true }
        // Don't wait forever for an interaction.
        Task {
            try? await Task.sleep(for: .seconds(8))
            dismissHint()
        }
    }

    private func dismissHint() {
        hasSeenHint = true
        guard showHint else { return }
        withAnimation(.easeIn) { showHint = false }
    }

    private var hint: some View {
        HStack(spacing: 14) {
            hintItem("hand.tap", "Tap a planet")
            hintItem("arrow.up.left.and.arrow.down.right", "Pinch to zoom")
            hintItem("hand.draw", "Drag to explore")
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(.ultraThinMaterial, in: Capsule())
        .environment(\.colorScheme, .dark)
        .accessibilityElement(children: .combine)
    }

    private func hintItem(_ icon: String, _ text: LocalizedStringKey) -> some View {
        Label(text, systemImage: icon)
            .font(AppFont.regular(12))
            .foregroundColor(.white)
            .labelStyle(.titleAndIcon)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
    }

    // MARK: Time

    private var timeCard: some View {
        VStack(spacing: 4) {
            // Only this row redraws as the date changes; the slider stays put.
            TimelineView(.animation(minimumInterval: 0.1, paused: !isVisible || !clock.isPlaying)) { context in
                let date = clock.date(at: context.date)
                let isToday = abs(date.timeIntervalSince(context.date)) < 86_400

                HStack(spacing: 10) {
                    Button {
                        playHaptic(.light)
                        clock.setPlaying(!clock.isPlaying)
                    } label: {
                        Image(systemName: clock.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(width: 30, height: 30)
                            .contentShape(Rectangle())
                    }
                    .accessibilityLabel(clock.isPlaying ? Text("Pause orbits") : Text("Play orbits"))

                    VStack(alignment: .leading, spacing: 1) {
                        Text(date.formatted(.dateTime.day().month(.abbreviated).year().locale(AppLanguage.locale)))
                            .font(AppFont.bold(13))
                            .monospacedDigit()
                            .lineLimit(1)
                            .accessibilityLabel(Text("Date on the map: \(date.formatted(.dateTime.day().month(.wide).year().locale(AppLanguage.locale)))"))
                        Text(MapSpeed.label(daysPerSecond: currentSpeed))
                            .font(AppFont.regular(11))
                            .foregroundColor(.white.opacity(0.7))
                            .monospacedDigit()
                            .lineLimit(1)
                            .accessibilityHidden(true)
                    }

                    Spacer(minLength: 0)

                    if !isToday {
                        Button {
                            playHaptic(.light)
                            clock.jumpToToday()
                        } label: {
                            Text("Today")
                                .font(AppFont.bold(12))
                                .padding(.vertical, 5)
                                .padding(.horizontal, 9)
                                .background(Color.cyan.opacity(0.35), in: Capsule())
                        }
                        .accessibilityHint("Shows where the planets are right now")
                    }
                }
            }

            SpeedSlider(position: speedPosition,
                        valueLabel: MapSpeed.label(daysPerSecond: currentSpeed)) {
                // Changing the speed means they want to see it move.
                if !clock.isPlaying { clock.setPlaying(true) }
            }
        }
        .foregroundColor(.white)
        .padding(.top, 8)
        .padding(.bottom, 4)
        .padding(.horizontal, 12)
        .background(Color.black.opacity(0.35), in: RoundedRectangle(cornerRadius: 18))
    }

    private var currentSpeed: Double {
        min(max(daysPerSecond, MapSpeed.range.lowerBound), MapSpeed.range.upperBound)
    }

    private var speedPosition: Binding<Double> {
        Binding(
            get: { MapSpeed.position(forDays: currentSpeed) },
            set: { position in
                let days = MapSpeed.days(at: position)
                daysPerSecond = days
                clock.setSpeed(days)
            }
        )
    }

    // MARK: Pieces

    private var background: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.black, Color("GradientColor"), .purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            StarFieldView(count: 100)
        }
    }

    private var recenterButton: some View {
        Button(action: recenter) {
            Image(systemName: "scope")
                .font(.title2)
                .foregroundColor(.white)
                .padding(12)
                .background(Color.black.opacity(0.35))
                .clipShape(Circle())
        }
        .accessibilityLabel("Recenter")
    }

    private var labelsButton: some View {
        Button {
            playHaptic(.light)
            withAnimation(.easeInOut(duration: 0.2)) { showLabels.toggle() }
        } label: {
            Image(systemName: showLabels ? "tag.fill" : "tag.slash")
                .font(.title2)
                .foregroundColor(.white)
                .padding(12)
                .background(Color.black.opacity(0.35))
                .clipShape(Circle())
        }
        .accessibilityLabel("Planet names")
        .accessibilityValue(showLabels ? Text("On") : Text("Off"))
    }

    // MARK: Gestures

    /// How far the map may be panned. Grows with zoom, so Neptune can always
    /// be brought to the middle of the screen.
    private func panLimit(fit: CGFloat) -> CGFloat {
        max(150, (SolarSystemMap.outerOrbit + 40) * fit * zoom)
    }

    private func clamped(_ size: CGSize, fit: CGFloat) -> CGSize {
        let limit = panLimit(fit: fit)
        return CGSize(width: min(max(size.width, -limit), limit),
                      height: min(max(size.height, -limit), limit))
    }

    private func panGesture(fit: CGFloat) -> some Gesture {
        DragGesture()
            .onChanged { value in
                if showHint { dismissHint() }
                let last = lastDrag ?? .zero
                offset = clamped(CGSize(width: offset.width + value.translation.width - last.width,
                                        height: offset.height + value.translation.height - last.height),
                                 fit: fit)
                lastDrag = value.translation
            }
            .onEnded { _ in lastDrag = nil }
    }

    private func pinchGesture(fit: CGFloat) -> some Gesture {
        MagnifyGesture()
            .onChanged { value in
                if showHint { dismissHint() }
                let step = value.magnification / (lastPinch ?? 1)
                let newZoom = min(max(zoom * step, minZoom), maxZoom)
                // Scale the pan with the zoom so the point in the middle of
                // the screen stays put, rather than everything sliding
                // towards the Sun.
                let ratio = newZoom / zoom
                zoom = newZoom
                offset = clamped(CGSize(width: offset.width * ratio, height: offset.height * ratio), fit: fit)
                lastPinch = value.magnification
            }
            .onEnded { _ in lastPinch = nil }
    }

    private func recenter() {
        withAnimation(.easeInOut) {
            offset = .zero
            zoom = 1
        }
    }
}

// MARK: - Map

/// The Sun, the orbits and the planets at one moment.
///
/// Positions are computed from `date` on every frame instead of being
/// animated, so the planets are always where the hit areas are. They're real:
/// each planet's mean longitude from JPL's orbital elements (the same data as
/// Mission Builder), seen from above the Sun's north pole, so everything
/// moves anticlockwise at its true relative speed. Orbits are treated as
/// circles, so Mercury and Mars can be off by up to ~20°.
struct SolarSystemMap: View {
    /// The simulated date the planets are shown at.
    let date: Date
    /// Seconds of real time, for the Sun's (decorative) spin.
    let sunSpin: TimeInterval
    let scale: CGFloat
    var showLabels = false
    /// Labels follow the screen size but not the zoom, so they stay readable
    /// without crowding the map when zoomed in.
    var labelScale: CGFloat = 1
    @Binding var selectedPlanet: Planet?
    @Binding var selectedStar: Star?

    /// Neptune's orbit radius at 1×, in points.
    static let outerOrbit: CGFloat = planets.filter { $0.orbiteRadius > 0 }.map(\.orbiteRadius).max() ?? 195

    /// Apple's minimum comfortable tap target.
    private let minTapSize: CGFloat = 44

    private var orbitingPlanets: [Planet] {
        planets.filter { $0.orbiteRadius > 0 }
    }

    var body: some View {
        ZStack {
            sunGlow

            ForEach(orbitingPlanets) { planet in
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    .frame(width: planet.orbiteRadius * 2 * scale, height: planet.orbiteRadius * 2 * scale)
                    .allowsHitTesting(false)
            }

            sunView

            // Outer planets first, so where tap areas overlap the smaller
            // inner planets are on top.
            ForEach(Array(orbitingPlanets.enumerated()).reversed(), id: \.element.id) { index, planet in
                planetView(planet)
                    // VoiceOver reads by screen position, which keeps changing
                    // here; this fixes the order to Sun, Mercury … Neptune.
                    .accessibilitySortPriority(Double(99 - index))
            }
        }
    }

    private var sunGlow: some View {
        ZStack {
            ForEach([(30.0, 5.0, 0.3), (60.0, 10.0, 0.3), (150.0, 15.0, 0.2)], id: \.0) { size, blur, opacity in
                Circle()
                    .fill(Color.yellow)
                    .frame(width: size * scale, height: size * scale)
                    .blur(radius: blur * scale)
                    .opacity(opacity)
            }
        }
        .allowsHitTesting(false)
    }

    private var sunView: some View {
        let size = 50 * scale
        return Image("Sun")
            .resizable()
            .frame(width: size, height: size)
            .rotationEffect(.degrees(sunSpin.truncatingRemainder(dividingBy: 100) / 100 * 360))
            .frame(width: max(size, minTapSize), height: max(size, minTapSize))
            .contentShape(Circle())
            .onTapGesture { selectedStar = sun }
            .accessibilityLabel("Sun")
            .accessibilityHint("Shows details about the Sun")
            .accessibilityAddTraits(.isButton)
            .accessibilitySortPriority(100)
    }

    private func planetView(_ planet: Planet) -> some View {
        let radians = LaunchWindow.longitude(planet.name, on: date) ?? planet.initialAngle * .pi / 180
        let radius = planet.orbiteRadius * scale
        let size = planet.size * 2 * scale

        return Image(planet.imageName)
            .resizable()
            .frame(width: size, height: size)
            // A larger invisible tap area: the planets are small and moving.
            .frame(width: max(size, minTapSize), height: max(size, minTapSize))
            .contentShape(Circle())
            .onTapGesture {
                playHaptic(.light)
                selectedPlanet = planet
            }
            .overlay {
                if showLabels {
                    Text(planet.name.localizedBodyName)
                        .font(AppFont.regular(10 * labelScale))
                        .foregroundColor(.white.opacity(0.85))
                        .shadow(color: .black, radius: 2)
                        .fixedSize()
                        .offset(y: size / 2 + 8 * labelScale)
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                        .transition(.opacity)
                }
            }
            // Screen y points down, so negate it for anticlockwise motion.
            .offset(x: radius * cos(radians), y: -radius * sin(radians))
            .accessibilityLabel(planet.name.localizedBodyName)
            .accessibilityHint("Shows details about \(planet.name.localizedBodyName)")
            .accessibilityAddTraits(.isButton)
    }
}

#Preview {
    HomeView()
}

// MARK: - Time

/// How fast time runs on the map, in simulated days per real second.
enum MapSpeed {
    static let range: ClosedRange<Double> = 1...365
    static let defaultDaysPerSecond: Double = 7

    /// The slider runs on a log scale: equal distances multiply the speed,
    /// so a day, a week, a month and a year per second all get room.
    static func position(forDays days: Double) -> Double {
        log(days / range.lowerBound) / log(range.upperBound / range.lowerBound)
    }

    static func days(at position: Double) -> Double {
        range.lowerBound * pow(range.upperBound / range.lowerBound, position)
    }

    /// Marks on the slider, which the thumb snaps to.
    struct Preset: Identifiable {
        let days: Double
        let name: LocalizedStringKey
        var id: Double { days }
        var position: Double { MapSpeed.position(forDays: days) }
    }

    static let presets: [Preset] = [
        Preset(days: 1, name: "Day"),
        Preset(days: 7, name: "Week"),
        Preset(days: 30.44, name: "Month"),
        Preset(days: 365, name: "Year")
    ]

    /// "3 days/s", "2 weeks/s", "5 months/s": rounded to the nearest unit
    /// that reads naturally.
    static func label(daysPerSecond days: Double) -> String {
        func format(_ key: String.LocalizationValue, _ value: Double) -> String {
            String(format: String(localized: key, bundle: Bundle.appLanguage), MetricFormat.plain(value, decimals: 0))
        }
        if days < 1.5 { return String(localized: "1 day/s", bundle: Bundle.appLanguage) }
        if days < 7 { return format("%@ days/s", days.rounded()) }
        if days < 30 {
            let weeks = (days / 7).rounded()
            return weeks <= 1 ? String(localized: "1 week/s", bundle: Bundle.appLanguage) : format("%@ weeks/s", weeks)
        }
        let months = (days / 30.44).rounded()
        if months >= 12 { return String(localized: "1 year/s", bundle: Bundle.appLanguage) }
        return months <= 1 ? String(localized: "1 month/s", bundle: Bundle.appLanguage) : format("%@ months/s", months)
    }
}

/// The date shown on the map: a simulated date that advances at
/// `daysPerSecond` while playing.
///
/// Stored as an anchor (this simulated date at that real moment), so reading
/// it each frame is cheap and changing speed never makes the planets jump.
struct MapClock {
    private(set) var isPlaying = true
    private var anchorDate = Date()
    private var anchorWall = Date()
    private var daysPerSecond = MapSpeed.defaultDaysPerSecond
    private var isSuspended = false

    private var isRunning: Bool { isPlaying && !isSuspended }

    func date(at wall: Date) -> Date {
        guard isRunning else { return anchorDate }
        return anchorDate.addingTimeInterval(wall.timeIntervalSince(anchorWall) * daysPerSecond * 86_400)
    }

    /// Fixes the current simulated date as the new anchor, before a change.
    private mutating func rebase() {
        let now = Date()
        anchorDate = date(at: now)
        anchorWall = now
    }

    mutating func setSpeed(_ days: Double) {
        rebase()
        daysPerSecond = days
    }

    mutating func setPlaying(_ playing: Bool) {
        rebase()
        isPlaying = playing
    }

    mutating func setSuspended(_ suspended: Bool) {
        rebase()
        isSuspended = suspended
    }

    mutating func jumpToToday() {
        anchorDate = Date()
        anchorWall = Date()
    }
}
