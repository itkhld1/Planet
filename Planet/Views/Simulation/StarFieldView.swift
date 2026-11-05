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
    private struct Star: Identifiable {
        let id = UUID()
        let x: CGFloat
        let y: CGFloat
        let radius: CGFloat
        let opacity: Double
    }

    private let stars: [Star]
    private let color: Color

    /// - Parameters:
    ///   - count: number of stars to draw.
    ///   - color: star color.
    init(count: Int = 100, color: Color = .white) {
        self.color = color
        self.stars = (0..<count).map { _ in
            Star(
                x: .random(in: 0...1),
                y: .random(in: 0...1),
                radius: .random(in: 0.5...1.5),
                opacity: .random(in: 0.5...1.0)
            )
        }
    }

    var body: some View {
        Canvas { context, size in
            for star in stars {
                let diameter = star.radius * 2
                let rect = CGRect(
                    x: star.x * size.width - star.radius,
                    y: star.y * size.height - star.radius,
                    width: diameter,
                    height: diameter
                )
                context.fill(
                    Path(ellipseIn: rect),
                    with: .color(color.opacity(star.opacity))
                )
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

#Preview {
    ZStack {
        Color.black
        StarFieldView()
    }
}
