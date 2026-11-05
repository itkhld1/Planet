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
    /// Flips once on first appearance, to draw the orbits in.
    @State private var revealed = false
    /// The planet just tapped, and when: drives its ripple and bounce.
    @State private var tapped: (name: String, at: Date)?

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
                            animate: !reduceMotion,
                            revealed: revealed,
                            now: context.date,
                            tapped: tapped,
                            onTapPlanet: openPlanet,
                            // Above this the Moon laps Earth faster than the
                            // eye can follow, so it's hidden.
                            showMoon: !clock.isPlaying || currentSpeed <= 30,
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
                    if reduceMotion {
                        revealed = true
                    } else {
                        // A beat after the screen appears, so the reveal is seen.
                        Task {
                            try? await Task.sleep(for: .seconds(0.15))
                            revealed = true
                        }
                    }
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

    // MARK: Tapping a planet

    /// A ripple and a bounce first, then the details: the tap feels like it
    /// landed on the planet before the sheet covers the map.
    private func openPlanet(_ planet: Planet) {
        playHaptic(.light)
        guard !reduceMotion else {
            selectedPlanet = planet
            return
        }
        tapped = (planet.name, Date())
        Task {
            try? await Task.sleep(for: .seconds(0.3))
            selectedPlanet = planet
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
            TimelineView(.animation(minimumInterval: 0.1, paused: !isVisible)) { context in
                let date = clock.date(at: context.date)
                let isToday = abs(date.timeIntervalSince(context.date)) < 86_400

                HStack(spacing: 10) {
                    Button {
                        playHaptic(.light)
                        withAnimation { clock.setPlaying(!clock.isPlaying) }
                    } label: {
                        Image(systemName: clock.isPlaying ? "pause.fill" : "play.fill")
                            .contentTransition(.symbolEffect(.replace))
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
                            // Glides back rather than jumping, so you see
                            // the planets wind back to where they are now.
                            if reduceMotion {
                                clock.jumpToToday()
                            } else {
                                clock.glideToToday()
                            }
                        } label: {
                            Text("Today")
                                .font(AppFont.bold(12))
                                .padding(.vertical, 5)
                                .padding(.horizontal, 9)
                                .background(Palette.accent.opacity(0.35), in: Capsule())
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
        // Frosted, since it floats over the moving map.
        .glassCard(cornerRadius: 18)
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
            SpaceGradient()
            StarFieldView(count: 100)
        }
    }

    private var recenterButton: some View {
        Button(action: recenter) {
            Image(systemName: "scope")
                .font(.title2)
                .foregroundColor(.white)
                .padding(12)
                .background(.ultraThinMaterial, in: Circle())
                .overlay(Circle().stroke(Palette.cardStroke, lineWidth: 1))
                .environment(\.colorScheme, .dark)
        }
        .accessibilityLabel("Recenter")
    }

    private var labelsButton: some View {
        Button {
            playHaptic(.light)
            withAnimation(.easeInOut(duration: 0.2)) { showLabels.toggle() }
        } label: {
            Image(systemName: showLabels ? "tag.fill" : "tag.slash")
                .contentTransition(.symbolEffect(.replace))
                .font(.title2)
                .foregroundColor(.white)
                .padding(12)
                .background(.ultraThinMaterial, in: Circle())
                .overlay(Circle().stroke(Palette.cardStroke, lineWidth: 1))
                .environment(\.colorScheme, .dark)
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
    /// Seconds of real time, for the Sun's (decorative) spin and glow.
    let sunSpin: TimeInterval
    /// False with Reduce Motion: no breathing glow or solar wind.
    var animate = true
    /// The opening reveal: orbits draw in one by one, then the planets appear.
    var revealed = true
    /// Real time, for effects that run in seconds rather than map days.
    var now = Date()
    var tapped: (name: String, at: Date)?
    var onTapPlanet: ((Planet) -> Void)?
    var showMoon = true
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

            ForEach(Array(orbitingPlanets.enumerated()), id: \.element.id) { index, planet in
                orbit(planet, index: index)
            }

            asteroidBelt

            if animate {
                solarWind
                comet
            }

            sunView
                .scaleEffect(revealed ? 1 : 0.4)
                .opacity(revealed ? 1 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.65), value: revealed)

            // Outer planets first, so where tap areas overlap the smaller
            // inner planets are on top.
            ForEach(Array(orbitingPlanets.enumerated()).reversed(), id: \.element.id) { index, planet in
                planetView(planet, index: index)
                    // VoiceOver reads by screen position, which keeps changing
                    // here; this fixes the order to Sun, Mercury … Neptune.
                    .accessibilitySortPriority(Double(99 - index))
            }
        }
    }

    /// Orbits fade outward, which gives the map depth. The selected planet's
    /// orbit lights up in its own colour while its details are open, and
    /// the rest step back.
    private func orbit(_ planet: Planet, index: Int) -> some View {
        let isSelected = selectedPlanet?.name == planet.name
        let fade = 0.35 - 0.2 * Double(index) / Double(max(orbitingPlanets.count - 1, 1))
        let opacity = selectedPlanet == nil ? fade : fade * 0.5
        return Circle()
            .trim(from: 0, to: revealed ? 1 : 0)
            .stroke(isSelected ? planet.color.opacity(0.9) : Color.white.opacity(opacity),
                    lineWidth: isSelected ? 1.5 : 1)
            // Drawn from the top, inner orbits first.
            .rotationEffect(.degrees(-90))
            .animation(.easeInOut(duration: 0.9).delay(0.1 + 0.07 * Double(index)), value: revealed)
            .frame(width: planet.orbiteRadius * 2 * scale, height: planet.orbiteRadius * 2 * scale)
            .allowsHitTesting(false)
    }

    /// The Sun's glow, slowly breathing in and out.
    private var sunGlow: some View {
        let breath = animate ? 1 + 0.07 * sin(sunSpin * 2 * .pi / 4) : 1
        return ZStack {
            ForEach([(30.0, 5.0, 0.3), (60.0, 10.0, 0.3), (150.0, 15.0, 0.2)], id: \.0) { size, blur, opacity in
                Circle()
                    .fill(Palette.amber)
                    .frame(width: size * scale * breath, height: size * scale * breath)
                    .blur(radius: blur * scale)
                    .opacity(opacity)
            }
        }
        .allowsHitTesting(false)
    }

    /// Faint rings rippling out from the Sun, like the solar wind.
    private var solarWind: some View {
        ZStack {
            ForEach(0..<2, id: \.self) { ring in
                let progress = (sunSpin / 6 + Double(ring) / 2).truncatingRemainder(dividingBy: 1)
                let diameter = (28 + 56 * progress) * 2 * scale
                Circle()
                    .stroke(Palette.amber.opacity(0.3 * pow(1 - progress, 1.5)), lineWidth: 1)
                    .frame(width: diameter, height: diameter)
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
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

    private func planetView(_ planet: Planet, index: Int) -> some View {
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
                if let onTapPlanet {
                    onTapPlanet(planet)
                } else {
                    playHaptic(.light)
                    selectedPlanet = planet
                }
            }
            .overlay {
                if planet.name == "Earth" && showMoon {
                    moon(around: size)
                }
            }
            .overlay {
                if showLabels {
                    let isSelected = selectedPlanet?.name == planet.name
                    Text(planet.name.localizedBodyName)
                        .font(isSelected ? AppFont.bold(10 * labelScale) : AppFont.regular(10 * labelScale))
                        .foregroundColor(isSelected ? planet.color : .white.opacity(0.85))
                        .shadow(color: .black, radius: 2)
                        .fixedSize()
                        // Earth's label sits below the Moon's orbit.
                        .offset(y: size / 2 + 8 * labelScale + (planet.name == "Earth" && showMoon ? 7 * scale : 0))
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                        .transition(.opacity)
                }
            }
            .overlay { ripple(for: planet, size: size) }
            .scaleEffect(bounce(for: planet))
            // Appear after their orbit has drawn in.
            .scaleEffect(revealed ? 1 : 0.2)
            .opacity(revealed ? 1 : 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.4 + 0.07 * Double(index)), value: revealed)
            // Screen y points down, so negate it for anticlockwise motion.
            .offset(x: radius * cos(radians), y: -radius * sin(radians))
            .accessibilityLabel(planet.name.localizedBodyName)
            .accessibilityHint("Shows details about \(planet.name.localizedBodyName)")
            .accessibilityAddTraits(.isButton)
    }

    // MARK: Tap feedback

    private static let tapEffectLength = 0.6

    /// 0…1 through the tap effect for this planet, or nil when none is running.
    private func tapProgress(for planet: Planet) -> Double? {
        guard animate, let tapped, tapped.name == planet.name else { return nil }
        let progress = now.timeIntervalSince(tapped.at) / Self.tapEffectLength
        return (0...1).contains(progress) ? progress : nil
    }

    private func bounce(for planet: Planet) -> CGFloat {
        guard let p = tapProgress(for: planet) else { return 1 }
        return 1 + 0.3 * sin(p * .pi)
    }

    /// A ring in the planet's colour, spreading out and fading.
    @ViewBuilder
    private func ripple(for planet: Planet, size: CGFloat) -> some View {
        if let p = tapProgress(for: planet) {
            let diameter = size + (12 + 50 * p) * scale
            Circle()
                .stroke(planet.color.opacity(0.9 * (1 - p)), lineWidth: 2)
                .frame(width: diameter, height: diameter)
                .allowsHitTesting(false)
        }
    }

    // MARK: Asteroid belt

    /// Rocks between Mars and Jupiter, each at a fixed distance and starting
    /// angle. Seeded, so the belt is the same every time.
    private static let asteroids: [(radius: Double, angle: Double, size: Double, opacity: Double)] = {
        var rng = SeededGenerator(seed: 2026)
        return (0..<160).map { _ in
            (radius: .random(in: 0...1, using: &rng),
             angle: .random(in: 0...(2 * .pi), using: &rng),
             size: .random(in: 0.6...1.5, using: &rng),
             opacity: .random(in: 0.25...0.6, using: &rng))
        }
    }()

    /// Inner rocks lap faster than outer ones, by Kepler's third law: the
    /// belt spans roughly 2.2 to 3.3 AU, so 3.3 to 6 years a lap.
    private var asteroidBelt: some View {
        let inner = 117.0, outer = 128.0
        let days = date.timeIntervalSince(Date(timeIntervalSince1970: 946_728_000)) / 86_400
        return Canvas { context, canvasSize in
            let centre = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
            for rock in Self.asteroids {
                let au = 2.2 + 1.1 * rock.radius
                let years = pow(au, 1.5)
                let angle = rock.angle + 2 * .pi * days / (365.25 * years)
                let r = (inner + (outer - inner) * rock.radius) * Double(scale)
                let point = CGPoint(x: centre.x + r * cos(angle), y: centre.y - r * sin(angle))
                let d = rock.size * Double(max(scale, 0.7))
                context.fill(Path(ellipseIn: CGRect(x: point.x - d / 2, y: point.y - d / 2, width: d, height: d)),
                             with: .color(Color(red: 0.8, green: 0.75, blue: 0.68).opacity(rock.opacity)))
            }
        }
        .frame(width: outer * 2.1 * scale, height: outer * 2.1 * scale)
        .opacity(revealed ? 1 : 0)
        .animation(.easeIn(duration: 1).delay(0.6), value: revealed)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    // MARK: Comet

    private static let cometSlot = 40.0
    private static let cometDuration = 14.0

    /// Every so often a comet sweeps past the Sun. Its tail always points
    /// away from the Sun, as real comet tails do, and grows as it gets
    /// closer. Timed in real seconds, like the shooting stars.
    private var comet: some View {
        let t = now.timeIntervalSinceReferenceDate
        let slot = floor(t / Self.cometSlot)
        var rng = SeededGenerator(seed: UInt64(bitPattern: Int64(slot)) &* 7 &+ 11)
        let start = slot * Self.cometSlot + .random(in: 2...(Self.cometSlot - Self.cometDuration - 2), using: &rng)
        let progress = (t - start) / Self.cometDuration
        let closest = Double.random(in: 50...140, using: &rng)
        let approach = Double.random(in: 0...(2 * .pi), using: &rng)
        let side: Double = Bool.random(using: &rng) ? 1 : -1
        let extent = (SolarSystemMap.outerOrbit + 60) * 2.2

        return Canvas { context, canvasSize in
            guard (0...1).contains(progress) else { return }
            let s = Double(scale)
            let centre = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
            // A straight pass: the closest point, then along the
            // perpendicular. Fast near the Sun, slower far out.
            let along = (progress * 2 - 1)
            let curved = along * abs(along) * 0.6 + along * 0.4
            let span = 330.0
            let nx = cos(approach), ny = sin(approach)
            let px = -ny * side, py = nx * side
            let x = (nx * closest + px * curved * span) * s
            let y = (ny * closest + py * curved * span) * s
            let head = CGPoint(x: centre.x + x, y: centre.y + y)
            let distance = max(hypot(x, y), 1)
            let away = CGPoint(x: x / distance, y: y / distance)
            let tailLength = min(140, 20 + 5000 / (distance / s)) * s
            let tail = CGPoint(x: head.x + away.x * tailLength, y: head.y + away.y * tailLength)
            let fade = min(1, min(progress, 1 - progress) * 6)

            var path = Path()
            path.move(to: head)
            path.addLine(to: tail)
            context.stroke(path,
                           with: .linearGradient(Gradient(colors: [Color(red: 0.75, green: 0.92, blue: 1).opacity(0.75 * fade), .clear]),
                                                 startPoint: head, endPoint: tail),
                           style: StrokeStyle(lineWidth: 3 * s, lineCap: .round))
            context.fill(Path(ellipseIn: CGRect(x: head.x - 2.5 * s, y: head.y - 2.5 * s, width: 5 * s, height: 5 * s)),
                         with: .color(.white.opacity(fade)))
        }
        .frame(width: extent * scale, height: extent * scale)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    /// The Moon circling Earth at its real rate (27.3 days a lap), from its
    /// mean longitude. Seen from above, like the planets.
    private func moon(around earthSize: CGFloat) -> some View {
        let days = date.timeIntervalSince(Date(timeIntervalSince1970: 946_728_000)) / 86_400
        let longitude = (218.316 + 13.176_396 * days) * .pi / 180
        let distance = earthSize / 2 + 5 * scale
        let size = max(3, 3.2 * scale)
        return Circle()
            .fill(Color(white: 0.85))
            .frame(width: size, height: size)
            .offset(x: distance * cos(longitude), y: -distance * sin(longitude))
            .allowsHitTesting(false)
            .accessibilityHidden(true)
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
        if let glide, wall < glide.start.addingTimeInterval(glide.duration) {
            let p = max(0, wall.timeIntervalSince(glide.start) / glide.duration)
            let eased = p < 0.5 ? 2 * p * p : 1 - pow(-2 * p + 2, 2) / 2
            return glide.from.addingTimeInterval(glide.to.timeIntervalSince(glide.from) * eased)
        }
        guard isRunning else { return anchorDate }
        return anchorDate.addingTimeInterval(wall.timeIntervalSince(anchorWall) * daysPerSecond * 86_400)
    }

    /// Fixes the current simulated date as the new anchor, before a change.
    private mutating func rebase() {
        let now = Date()
        anchorDate = date(at: now)
        anchorWall = now
        glide = nil
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
        glide = nil
        anchorDate = Date()
        anchorWall = Date()
    }

    /// An eased trip from one simulated date to another, over real seconds.
    private var glide: (from: Date, to: Date, start: Date, duration: Double)?

    /// Winds the map back (or forward) to today over a second or so, so the
    /// planets visibly travel there; then carries on as before.
    mutating func glideToToday() {
        let now = Date()
        let from = date(at: now)
        let duration = 1.2
        glide = (from, now, now, duration)
        // Where things stand when the glide ends: today, at that moment.
        anchorDate = now
        anchorWall = now.addingTimeInterval(duration)
    }
}
