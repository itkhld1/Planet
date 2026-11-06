//
//  OnboardingScenes.swift
//  Planet
//
//  The small animated scene at the top of each onboarding page. Each one is
//  driven by a clock rather than `repeatForever`, so it can pause when its
//  page is off screen and hold a sensible still frame with Reduce Motion.
//

import SwiftUI

// MARK: - Clock

/// Hands its content the current time, 30 times a second, while `active`.
/// With Reduce Motion it draws a single frame at `stillTime`.
struct SceneClock<Content: View>: View {
    var active = true
    var stillTime: Double = 0
    @ViewBuilder let content: (Double) -> Content

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        if reduceMotion {
            content(stillTime)
        } else {
            TimelineView(.animation(minimumInterval: 1.0 / 30, paused: !active)) { context in
                content(context.date.timeIntervalSinceReferenceDate)
            }
        }
    }
}

/// 0 before `from`, 1 after `to`, eased in between.
func sceneProgress(_ x: Double, from: Double, to: Double) -> Double {
    let p = min(max((x - from) / (to - from), 0), 1)
    return p * p * (3 - 2 * p)
}

// MARK: - Welcome

/// The Sun, floating and glowing, with three planets circling it on tilted
/// orbits — passing in front of it and behind it.
struct WelcomeScene: View {
    let size: CGFloat
    var active = true

    private struct Orbiter {
        let name: String
        let radius: CGFloat   // semi-major axis, as a fraction of `size`
        let period: Double
        let scale: CGFloat    // planet diameter, as a fraction of `size`
        let phase: Double
    }

    private let orbiters = [
        Orbiter(name: "Mercury", radius: 0.30, period: 7, scale: 0.07, phase: 0.6),
        Orbiter(name: "Earth", radius: 0.40, period: 12, scale: 0.10, phase: 2.6),
        Orbiter(name: "Mars", radius: 0.49, period: 18, scale: 0.085, phase: 4.4)
    ]

    /// How flat the orbits look: the vertical radius over the horizontal.
    private let tilt: CGFloat = 0.32

    var body: some View {
        SceneClock(active: active, stillTime: 0) { t in
            ZStack {
                ForEach(orbiters, id: \.name) { orbit in
                    Ellipse()
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        .frame(width: size * orbit.radius * 2, height: size * orbit.radius * 2 * tilt)
                        .zIndex(-2)
                }

                FloatingBody(imageName: "Sun", glow: Palette.amber, size: size * 0.34)
                    .zIndex(0)

                ForEach(orbiters, id: \.name) { orbit in
                    let angle = t * 2 * .pi / orbit.period + orbit.phase
                    let depth = sin(angle)   // -1 far side, +1 near side
                    Image(orbit.name)
                        .resizable()
                        .scaledToFit()
                        .frame(width: size * orbit.scale, height: size * orbit.scale)
                        .scaleEffect(1 + 0.18 * depth)
                        .brightness(-0.25 * max(-depth, 0))
                        .offset(x: cos(angle) * size * orbit.radius,
                                y: depth * size * orbit.radius * tilt)
                        // In front of the Sun on the near half, behind on the far.
                        .zIndex(depth)
                }
            }
            .frame(width: size, height: size)
        }
    }
}

// MARK: - Explore

/// A miniature of the map: planets running round their orbits, and every few
/// seconds a tap lands on Earth.
struct ExploreScene: View {
    let size: CGFloat
    var active = true

    private struct Orbiter {
        let name: String
        let radius: CGFloat
        let period: Double
        let scale: CGFloat
        let phase: Double
    }

    private let orbiters = [
        Orbiter(name: "Earth", radius: 0.19, period: 9, scale: 0.075, phase: 0.4),
        Orbiter(name: "Mars", radius: 0.28, period: 15, scale: 0.06, phase: 2.2),
        Orbiter(name: "Jupiter", radius: 0.39, period: 26, scale: 0.12, phase: 4.0),
        Orbiter(name: "Saturn", radius: 0.49, period: 38, scale: 0.13, phase: 5.3)
    ]

    /// Seconds between taps.
    private let tapCycle = 4.0

    var body: some View {
        SceneClock(active: active, stillTime: 0.6) { t in
            ZStack {
                ForEach(orbiters, id: \.name) { orbit in
                    Circle()
                        .stroke(Color.white.opacity(0.14), style: StrokeStyle(lineWidth: 1, dash: [3, 4]))
                        .frame(width: size * orbit.radius * 2, height: size * orbit.radius * 2)
                }

                Circle()
                    .fill(RadialGradient(colors: [Palette.amber.opacity(0.55), .clear],
                                         center: .center, startRadius: 0, endRadius: size * 0.14))
                    .frame(width: size * 0.28, height: size * 0.28)
                Image("Sun")
                    .resizable()
                    .scaledToFit()
                    .frame(width: size * 0.13, height: size * 0.13)

                ForEach(orbiters, id: \.name) { orbit in
                    Image(orbit.name)
                        .resizable()
                        .scaledToFit()
                        .frame(width: size * orbit.scale, height: size * orbit.scale)
                        .offset(position(of: orbit, at: t))
                }

                tap(at: t)
            }
            .frame(width: size, height: size)
        }
    }

    private func position(of orbit: Orbiter, at t: Double) -> CGSize {
        let angle: CGFloat = t * 2 * .pi / orbit.period + orbit.phase
        return CGSize(width: cos(angle) * size * orbit.radius,
                      height: sin(angle) * size * orbit.radius)
    }

    /// A ripple and a finger on Earth at the start of each cycle.
    @ViewBuilder
    private func tap(at t: Double) -> some View {
        let local = t.truncatingRemainder(dividingBy: tapCycle)
        let earth = position(of: orbiters[0], at: t)
        let ripple = sceneProgress(local, from: 0.3, to: 1.4)
        let finger = local < 0.3 ? sceneProgress(local, from: 0, to: 0.3)
                                 : 1 - sceneProgress(local, from: 1.2, to: 1.7)

        Circle()
            .stroke(Palette.accent, lineWidth: 2)
            .frame(width: size * 0.08, height: size * 0.08)
            .scaleEffect(1 + 2 * ripple)
            .opacity(local > 0.3 ? 1 - ripple : 0)
            .offset(earth)

        Image(systemName: "hand.point.up.left.fill")
            .font(.system(size: size * 0.09))
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.5), radius: 4)
            .scaleEffect(local < 0.45 ? 1 - 0.15 * sceneProgress(local, from: 0.2, to: 0.35) : 1)
            .opacity(finger)
            .offset(x: earth.width + size * 0.05, y: earth.height + size * 0.07)
    }
}

// MARK: - Quiz

/// A question card playing on a loop: the answers slide in, the right one
/// lights up, and the score ring fills.
struct QuizScene: View {
    let size: CGFloat
    var active = true

    private let cycle = 6.0
    private let correct = 1
    private let barWidths: [CGFloat] = [0.50, 0.62, 0.42]

    var body: some View {
        // The still frame shows the finished state.
        SceneClock(active: active, stillTime: 4.5) { t in
            let p = t.truncatingRemainder(dividingBy: cycle)
            let fadeOut = 1 - sceneProgress(p, from: 5.3, to: 5.9)
            let revealed = sceneProgress(p, from: 2.0, to: 2.3)
            let score = sceneProgress(p, from: 2.3, to: 3.3)

            VStack(spacing: size * 0.06) {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.12), lineWidth: size * 0.025)
                    Circle()
                        .trim(from: 0, to: 0.8 * score)
                        .stroke(Palette.amber, style: StrokeStyle(lineWidth: size * 0.025, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Image(systemName: "star.fill")
                        .font(.system(size: size * 0.08))
                        .foregroundStyle(Palette.amber)
                        .scaleEffect(0.7 + 0.3 * score + 0.25 * sin(.pi * score))
                }
                .frame(width: size * 0.26, height: size * 0.26)

                VStack(spacing: size * 0.035) {
                    ForEach(0..<3, id: \.self) { index in
                        let shown = sceneProgress(p, from: 0.2 + 0.25 * Double(index), to: 0.6 + 0.25 * Double(index))
                        let isRight = index == correct
                        answer(index: index, highlighted: isRight ? revealed : 0)
                            .scaleEffect(isRight ? 1 + 0.06 * sin(.pi * revealed) : 1)
                            .opacity(shown * (isRight ? 1 : 1 - 0.45 * revealed))
                            .offset(x: (1 - shown) * size * 0.25)
                    }
                }
            }
            .padding(size * 0.06)
            .frame(width: size * 0.82)
            .appCard(cornerRadius: size * 0.07)
            .opacity(fadeOut)
            .frame(width: size, height: size)
        }
    }

    private func answer(index: Int, highlighted: Double) -> some View {
        HStack(spacing: size * 0.04) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.4), lineWidth: 1.5)
                Circle()
                    .fill(Palette.success)
                    .opacity(highlighted)
                Image(systemName: "checkmark")
                    .font(.system(size: size * 0.035, weight: .bold))
                    .foregroundStyle(Palette.deepSpace)
                    .opacity(highlighted)
            }
            .frame(width: size * 0.065, height: size * 0.065)

            Capsule()
                .fill(Color.white.opacity(0.35))
                .frame(width: size * barWidths[index], height: size * 0.03)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, size * 0.04)
        .frame(height: size * 0.11)
        .background(
            RoundedRectangle(cornerRadius: size * 0.035)
                .fill(Palette.success.opacity(0.25 * highlighted))
        )
        .overlay(
            RoundedRectangle(cornerRadius: size * 0.035)
                .stroke(Color.white.opacity(0.12 * (1 - highlighted)), lineWidth: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: size * 0.035)
                .stroke(Palette.success.opacity(highlighted), lineWidth: 1)
        )
    }
}

// MARK: - Weigh in

/// Someone standing on a scale while the world under them changes: the
/// reading rolls to their weight on each planet in turn.
struct WeighScene: View {
    let size: CGFloat
    var active = true

    /// Surface gravity relative to Earth's.
    private let worlds: [(name: String, gravity: Double)] = [
        ("Earth", 1.0), ("Mars", 0.38), ("Jupiter", 2.53),
        ("Mercury", 0.38), ("Saturn", 1.07), ("Neptune", 1.14)
    ]
    private let earthWeight = 60.0
    private let slot = 3.0

    var body: some View {
        SceneClock(active: active, stillTime: 1.5) { t in
            let step = Int(t / slot)
            let local = t.truncatingRemainder(dividingBy: slot)
            let current = worlds[step % worlds.count]
            let previous = worlds[(step + worlds.count - 1) % worlds.count]
            let swap = sceneProgress(local, from: 0, to: 0.6)
            let weight = earthWeight * (previous.gravity + (current.gravity - previous.gravity) * sceneProgress(local, from: 0.1, to: 0.9))
            // The scale dips when the reading goes up, and bounces back.
            let dip = (current.gravity - previous.gravity) * sin(.pi * sceneProgress(local, from: 0.1, to: 0.7)) * size * 0.012

            ZStack {
                planet(previous.name).opacity(1 - swap)
                planet(current.name).opacity(swap)

                VStack(spacing: size * 0.015) {
                    Image(systemName: "figure.stand")
                        .font(.system(size: size * 0.2))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.5), radius: 6)
                    Capsule()
                        .fill(Color.white.opacity(0.85))
                        .frame(width: size * 0.32, height: size * 0.03)
                    Text(Int(weight.rounded()), format: .number)
                        .font(AppFont.bold(size * 0.085))
                        .monospacedDigit()
                        .foregroundStyle(Palette.deepSpace)
                        .padding(.horizontal, size * 0.05)
                        .padding(.vertical, size * 0.012)
                        .background(Capsule().fill(Palette.accent))
                }
                .offset(y: size * 0.2 + dip)
            }
            .frame(width: size, height: size)
        }
        .accessibilityHidden(true)
    }

    private func planet(_ name: String) -> some View {
        ZStack {
            Circle()
                .fill(RadialGradient(colors: [Palette.color(forPlanet: name).opacity(0.45), .clear],
                                     center: .center, startRadius: size * 0.2, endRadius: size * 0.42))
                .frame(width: size * 0.84, height: size * 0.84)
            Image(name)
                .resizable()
                .scaledToFit()
                .frame(width: size * 0.5, height: size * 0.5)
        }
        .offset(y: -size * 0.12)
    }
}

// MARK: - 3D

/// Saturn turning in space, with arrows sweeping round it to say "drag me".
struct ThreeDScene: View {
    let size: CGFloat
    var active = true

    var body: some View {
        SceneClock(active: active, stillTime: 0) { t in
            ZStack {
                Circle()
                    .fill(RadialGradient(colors: [Palette.color(forPlanet: "Saturn").opacity(0.4), .clear],
                                         center: .center, startRadius: size * 0.15, endRadius: size * 0.45))
                    .frame(width: size * 0.9, height: size * 0.9)

                Image("Saturn")
                    .resizable()
                    .scaledToFit()
                    .frame(width: size * 0.58, height: size * 0.58)
                    .rotation3DEffect(.degrees(28 * sin(t * 2 * .pi / 6)), axis: (x: 0, y: 1, z: 0), perspective: 0.6)
                    .rotation3DEffect(.degrees(12 * sin(t * 2 * .pi / 9 + 1)), axis: (x: 1, y: 0, z: 0), perspective: 0.6)
                    .shadow(color: .black.opacity(0.4), radius: 14)

                ForEach(0..<2, id: \.self) { arm in
                    Circle()
                        .trim(from: 0, to: 0.22)
                        .stroke(Palette.accent.opacity(0.85), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                        .overlay(alignment: .trailing) {
                            Image(systemName: "arrowtriangle.up.fill")
                                .font(.system(size: size * 0.04))
                                .foregroundStyle(Palette.accent.opacity(0.85))
                                .offset(x: size * 0.02, y: -size * 0.01)
                        }
                        .frame(width: size * 0.8, height: size * 0.8)
                        // Turning anticlockwise, so the arc's start leads.
                        .rotationEffect(.degrees(Double(arm) * 180 - t * 40))
                }
            }
            .frame(width: size, height: size)
        }
    }
}

#Preview("Welcome") {
    WelcomeScene(size: 260).frame(maxWidth: .infinity, maxHeight: .infinity).background(Palette.deepSpace)
}

#Preview("Explore") {
    ExploreScene(size: 260).frame(maxWidth: .infinity, maxHeight: .infinity).background(Palette.deepSpace)
}
