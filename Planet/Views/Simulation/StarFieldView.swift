//
//  StarFieldView.swift
//  Planet
//
//  A reusable starfield background.
//
//  Fixes long-standing issues with the old inline implementation:
//   1. Stars were positioned with `CGFloat.random(...)` directly inside a
//      `ForEach`, so every re-render (zoom, drag, tab switch) reshuffled all
//      stars. Here the positions are generated once in `init` and stored, so
//      they stay put.
//   2. It drew ~100 individually-shadowed `Circle` views. This draws every
//      star in a single `Canvas`, which is dramatically cheaper.
//   3. Each star kicked off its own `repeatForever` animation in `onAppear`.
//      Those never stopped and stacked up every time a screen re-appeared,
//      eventually saturating the main thread and freezing the UI. This view
//      is fully static: it draws once and never animates.
//

import SwiftUI

struct StarFieldView: View {

    /// A single star, positioned in relative (0...1) coordinates so the field
    /// scales to whatever size it is given.
    private struct Star {
        let x: CGFloat
        let y: CGFloat
        let radius: CGFloat
        let opacity: Double
        /// 0 for a steady star; otherwise how strongly it twinkles.
        let twinkle: Double
        let period: Double
        let phase: Double
    }

    private let stars: [Star]
    private let color: Color
    private let animated: Bool
    /// Varies the shooting stars between screens.
    private let seed: UInt64

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// - Parameters:
    ///   - count: number of stars to draw.
    ///   - color: star color.
    ///   - animated: whether some stars twinkle. False for images rendered
    ///     with `ImageRenderer`.
    init(count: Int = 100, color: Color = .white, animated: Bool = true) {
        self.color = color
        self.animated = animated
        self.seed = UInt64(count)
        // Seeded, so the same field comes back every time this view is
        // rebuilt. With plain random numbers the stars jumped to new places
        // whenever the screen redrew (zooming the map, changing speed…).
        var rng = SeededGenerator(seed: UInt64(count))
        self.stars = (0..<count).map { _ in
            let twinkles = Double.random(in: 0...1, using: &rng) < 0.35
            return Star(
                x: .random(in: 0...1, using: &rng),
                y: .random(in: 0...1, using: &rng),
                radius: .random(in: 0.5...1.5, using: &rng),
                opacity: .random(in: 0.5...1.0, using: &rng),
                twinkle: twinkles ? .random(in: 0.4...0.85, using: &rng) : 0,
                period: .random(in: 2.5...7, using: &rng),
                phase: .random(in: 0...(2 * .pi), using: &rng)
            )
        }
    }

    var body: some View {
        Group {
            if animated && !reduceMotion {
                // 30 fps keeps the shooting stars smooth.
                TimelineView(.animation(minimumInterval: 1.0 / 30)) { context in
                    field(at: context.date.timeIntervalSinceReferenceDate)
                }
            } else {
                field(at: nil)
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    /// The stars at time `t`, or all steady when `t` is nil.
    private func field(at t: Double?) -> some View {
        Canvas { context, size in
            for star in stars {
                var opacity = star.opacity
                if let t, star.twinkle > 0 {
                    // Dims and brightens around its own brightness, never
                    // quite going out.
                    let wave = (sin(t * 2 * .pi / star.period + star.phase) + 1) / 2
                    opacity *= 1 - star.twinkle * wave
                }
                let diameter = star.radius * 2
                let rect = CGRect(
                    x: star.x * size.width - star.radius,
                    y: star.y * size.height - star.radius,
                    width: diameter,
                    height: diameter
                )
                context.fill(
                    Path(ellipseIn: rect),
                    with: .color(color.opacity(opacity))
                )
            }
            if let t {
                drawShootingStars(in: &context, size: size, at: t)
            }
        }
    }

    // MARK: Shooting stars

    /// Seconds per slot; each slot has a chance of one shooting star.
    private static let slotLength = 5.0

    /// Now and then, a streak of light across the upper sky.
    ///
    /// Time is cut into slots, and each slot's streak (if it has one) is
    /// worked out from a generator seeded with the slot number, so there's
    /// nothing to store and every frame agrees on where it is.
    private func drawShootingStars(in context: inout GraphicsContext, size: CGSize, at t: Double) {
        let slot = floor(t / Self.slotLength)
        // The previous slot's streak may still be finishing.
        for index in [slot - 1, slot] {
            var rng = SeededGenerator(seed: UInt64(bitPattern: Int64(index)) &* 31 &+ seed)
            guard Double.random(in: 0...1, using: &rng) < 0.55 else { continue }

            let start = index * Self.slotLength + .random(in: 0...(Self.slotLength - 1), using: &rng)
            let duration = Double.random(in: 0.7...1.1, using: &rng)
            let progress = (t - start) / duration
            guard progress >= 0, progress <= 1 else { continue }

            let origin = CGPoint(x: .random(in: 0.1...0.9, using: &rng) * size.width,
                                 y: .random(in: 0.04...0.4, using: &rng) * size.height)
            // Falling down and to one side, at 15–35°.
            let angle = Double.random(in: 15...35, using: &rng) * .pi / 180
            let direction: Double = Bool.random(using: &rng) ? 1 : -1
            let travel = CGFloat.random(in: 140...260, using: &rng)
            let unit = CGPoint(x: cos(angle) * direction, y: sin(angle))

            // Fast at first, easing out as it burns up.
            let eased = 1 - pow(1 - progress, 2)
            let head = CGPoint(x: origin.x + unit.x * travel * eased,
                               y: origin.y + unit.y * travel * eased)
            let tailLength = 70 * (1 - progress * 0.6)
            let tail = CGPoint(x: head.x - unit.x * tailLength, y: head.y - unit.y * tailLength)
            let brightness = sin(progress * .pi)

            var path = Path()
            path.move(to: tail)
            path.addLine(to: head)
            context.stroke(path,
                           with: .linearGradient(Gradient(colors: [color.opacity(0), color.opacity(0.9 * brightness)]),
                                                 startPoint: tail, endPoint: head),
                           style: StrokeStyle(lineWidth: 1.4, lineCap: .round))
            context.fill(Path(ellipseIn: CGRect(x: head.x - 1.5, y: head.y - 1.5, width: 3, height: 3)),
                         with: .color(color.opacity(brightness)))
        }
    }
}

/// SplitMix64: a tiny, fast generator, here for repeatable star positions.
struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) { state = seed &+ 0x9E37_79B9_7F4A_7C15 }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

#Preview {
    ZStack {
        Color.black
        StarFieldView()
    }
}
