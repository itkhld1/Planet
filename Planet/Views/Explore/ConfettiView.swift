//
//  ConfettiView.swift
//  Planet
//
//  A one-off burst of confetti. Drawn in a single Canvas, so it stays cheap
//  even with a hundred pieces. Place it in an overlay; it ignores touches.
//

import SwiftUI

struct ConfettiView: View {
    /// When the burst began. Pieces are fully worked out from this, so the
    /// view holds no state of its own.
    let start: Date
    var pieces = 110

    static let duration = 3.0

    private static let colors: [Color] = [.yellow, Palette.accent, .pink, .orange, .green, .purple, .white]

    private struct Piece {
        let x: Double          // 0…1 across the width
        let delay: Double
        let speed: Double      // initial fall speed, pt/s
        let sway: Double
        let swaySpeed: Double
        let spin: Double
        let size: CGSize
        let color: Color
    }

    /// Seeded from the start time so a redraw doesn't reshuffle the pieces.
    private var layout: [Piece] {
        var rng = SeededRandom(seed: UInt64(start.timeIntervalSinceReferenceDate * 1_000))
        return (0..<pieces).map { _ in
            Piece(x: rng.next(0, 1), delay: rng.next(0, 0.5), speed: rng.next(60, 220),
                  sway: rng.next(8, 28), swaySpeed: rng.next(2, 5), spin: rng.next(3, 9),
                  size: CGSize(width: rng.next(5, 9), height: rng.next(8, 14)),
                  color: Self.colors[Int(rng.next(0, Double(Self.colors.count) - 0.001))])
        }
    }

    var body: some View {
        let pieces = layout
        TimelineView(.animation) { context in
            let elapsed = context.date.timeIntervalSince(start)
            Canvas { ctx, size in
                guard elapsed < Self.duration else { return }
                for p in pieces {
                    let t = elapsed - p.delay
                    guard t > 0 else { continue }
                    let y = -20 + p.speed * t + 0.5 * 380 * t * t
                    guard y < size.height + 20 else { continue }
                    let x = p.x * size.width + sin(t * p.swaySpeed) * p.sway
                    let fade = min(1, (Self.duration - elapsed) / 0.6)

                    var piece = ctx
                    piece.opacity = fade
                    piece.translateBy(x: x, y: y)
                    piece.rotate(by: .radians(t * p.spin))
                    // Squashing one axis fakes the paper flipping over.
                    piece.scaleBy(x: cos(t * p.spin * 1.3), y: 1)
                    piece.fill(Path(CGRect(x: -p.size.width / 2, y: -p.size.height / 2,
                                           width: p.size.width, height: p.size.height)),
                               with: .color(p.color))
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

/// Small deterministic generator (SplitMix64). Also seeds the daily mission,
/// which must come out the same on every device.
struct SeededRandom {
    private var state: UInt64
    init(seed: UInt64) { state = seed &+ 0x9E37_79B9_7F4A_7C15 }

    mutating func next(_ lower: Double, _ upper: Double) -> Double {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        z ^= z >> 31
        return lower + (upper - lower) * Double(z >> 11) / Double(1 << 53)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        ConfettiView(start: Date())
    }
}
