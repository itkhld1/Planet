//
//  TransferOrbitDiagram.swift
//  Planet
//
//  An animated top-down view of a Hohmann transfer: the Sun, both orbits,
//  the half-ellipse the spacecraft flies, and both planets moving at their
//  real speeds from the chosen launch date. When the launch date isn't in a
//  window, the target visibly isn't there when the spacecraft arrives —
//  which is the whole point of launch windows.
//

import SwiftUI

struct TransferOrbitDiagram: View {
    let origin: String
    let target: String
    let launchDate: Date
    let transfer: TransferOrbit
    /// Whether the launch date is in a window — colours the arrival marker.
    let isAligned: Bool
    /// Draws a still frame at this point of the flight instead of animating —
    /// used for the share image.
    var stillProgress: Double? = nil

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var isPhone: Bool { deviceType() == "iPhone" }
    private var travelDays: Double { transfer.travelDays }
    private var originRadius: Double { transfer.originRadius }
    private var targetRadius: Double { transfer.targetRadius }

    /// Seconds the flight takes on screen, then a pause on the arrival.
    private let flightSeconds = 6.0
    private let pauseSeconds = 1.5

    var body: some View {
        VStack(spacing: 8) {
            // A still frame skips TimelineView entirely: ImageRenderer (used
            // for the share image) doesn't reliably draw timeline content.
            if let stillProgress {
                frame(progress: stillProgress, height: 300)
            } else {
                TimelineView(.animation(paused: reduceMotion)) { context in
                    frame(progress: reduceMotion ? 1 : progress(at: context.date),
                          height: isPhone ? 280 : 400)
                }
            }

            Text("Distances not to scale")
                .font(AppFont.regular(isPhone ? 11 : 15))
                .foregroundColor(.white.opacity(0.55))
        }
        // A spatial diagram: never mirror it for right-to-left languages.
        .environment(\.layoutDirection, .leftToRight)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Orbit diagram: \(origin.localizedBodyName) to \(target.localizedBodyName)"))
    }

    private func frame(progress: Double, height: CGFloat) -> some View {
        VStack(spacing: 8) {
            Canvas { ctx, size in
                draw(in: &ctx, size: size, progress: progress)
            }
            .frame(height: height)

            Text("Day \(MetricFormat.plain(travelDays * progress, decimals: 0)) of \(MetricFormat.plain(travelDays, decimals: 0))")
                .font(AppFont.bold(isPhone ? 13 : 18))
                .foregroundColor(.white)
                .monospacedDigit()
        }
    }

    // MARK: - Timing

    private func progress(at date: Date) -> Double {
        let cycle = flightSeconds + pauseSeconds
        let t = date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: cycle)
        return min(t / flightSeconds, 1)
    }

    // MARK: - Geometry

    /// Square-root radial scale, so Mercury's orbit is still visible next to
    /// Neptune's (a true scale would make it 1/78th the size).
    private func scaled(_ r: Double, maxR: Double, radius: CGFloat) -> CGFloat {
        CGFloat((r / maxR).squareRoot()) * radius
    }

    /// Screen point for a heliocentric angle (radians, counter-clockwise from
    /// the right) and a screen-space distance from the Sun.
    private func point(_ angle: Double, _ distance: CGFloat, center: CGPoint) -> CGPoint {
        CGPoint(x: center.x + distance * CGFloat(cos(angle)),
                y: center.y - distance * CGFloat(sin(angle)))
    }

    private func spacecraft(at f: Double) -> (swept: Double, r: Double) {
        transfer.position(at: f)
    }

    // MARK: - Drawing

    private func draw(in ctx: inout GraphicsContext, size: CGSize, progress f: Double) {
        guard let departAngle = LaunchWindow.longitude(origin, on: launchDate),
              let targetStart = LaunchWindow.longitude(target, on: launchDate),
              let nO = LaunchWindow.meanMotion(origin),
              let nT = LaunchWindow.meanMotion(target) else { return }

        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let planetSize: CGFloat = isPhone ? 24 : 34
        let radius = min(size.width, size.height) / 2 - planetSize / 2 - 6
        let maxR = (0...40).map { spacecraft(at: Double($0) / 40).r }.reduce(max(originRadius, targetRadius), max)
        func s(_ r: Double) -> CGFloat { scaled(r, maxR: maxR, radius: radius) }

        // Orbits
        for r in [originRadius, targetRadius] {
            let d = s(r)
            ctx.stroke(Path(ellipseIn: CGRect(x: center.x - d, y: center.y - d, width: 2 * d, height: 2 * d)),
                       with: .color(.white.opacity(0.18)), lineWidth: 1)
        }

        // Transfer path: the whole route dashed, the flown part solid.
        var route = Path()
        var flown = Path()
        let steps = 120
        for i in 0...steps {
            let fi = Double(i) / Double(steps)
            let sc = spacecraft(at: fi)
            let p = point(departAngle + sc.swept, s(sc.r), center: center)
            if i == 0 { route.move(to: p) } else { route.addLine(to: p) }
            if fi <= f {
                if i == 0 { flown.move(to: p) } else { flown.addLine(to: p) }
            }
        }
        ctx.stroke(route, with: .color(.cyan.opacity(0.35)), style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
        ctx.stroke(flown, with: .color(.cyan), style: StrokeStyle(lineWidth: 2, lineCap: .round))

        // Arrival marker: green when the target will be there, orange when not.
        let arrival = point(departAngle + transfer.sweptAngle, s(targetRadius), center: center)
        let ring: CGFloat = planetSize + 10
        ctx.stroke(Path(ellipseIn: CGRect(x: arrival.x - ring / 2, y: arrival.y - ring / 2, width: ring, height: ring)),
                   with: .color((isAligned ? Color.green : .orange).opacity(0.8)),
                   style: StrokeStyle(lineWidth: 1.5, dash: [3, 3]))

        // Sun
        let sunSize: CGFloat = isPhone ? 26 : 36
        ctx.fill(Path(ellipseIn: CGRect(x: center.x - sunSize, y: center.y - sunSize, width: sunSize * 2, height: sunSize * 2)),
                 with: .radialGradient(Gradient(colors: [.yellow.opacity(0.45), .clear]),
                                       center: center, startRadius: 0, endRadius: sunSize))
        drawImage("Sun", at: center, size: sunSize, in: &ctx)

        // Planets move at their real rates for the elapsed mission time.
        let elapsedDays = travelDays * f
        let originNow = point(departAngle + nO * elapsedDays, s(originRadius), center: center)
        let targetNow = point(targetStart + nT * elapsedDays, s(targetRadius), center: center)
        drawImage(origin, at: originNow, size: planetSize, in: &ctx)
        drawImage(target, at: targetNow, size: planetSize, in: &ctx)
        drawLabel(origin, near: originNow, center: center, offset: planetSize * 0.8, in: &ctx)
        drawLabel(target, near: targetNow, center: center, offset: planetSize * 0.8, in: &ctx)

        // Spacecraft, with a soft glow.
        let sc = spacecraft(at: f)
        let craft = point(departAngle + sc.swept, s(sc.r), center: center)
        ctx.fill(Path(ellipseIn: CGRect(x: craft.x - 8, y: craft.y - 8, width: 16, height: 16)),
                 with: .color(.cyan.opacity(0.3)))
        ctx.fill(Path(ellipseIn: CGRect(x: craft.x - 3.5, y: craft.y - 3.5, width: 7, height: 7)),
                 with: .color(.white))
    }

    private func drawImage(_ name: String, at p: CGPoint, size: CGFloat, in ctx: inout GraphicsContext) {
        let image = ctx.resolve(Image(name))
        ctx.draw(image, in: CGRect(x: p.x - size / 2, y: p.y - size / 2, width: size, height: size))
    }

    /// Puts the name on the side away from the Sun, so it doesn't sit on
    /// top of the orbits in the middle.
    private func drawLabel(_ name: String, near p: CGPoint, center: CGPoint, offset: CGFloat, in ctx: inout GraphicsContext) {
        let dx = p.x - center.x, dy = p.y - center.y
        let length = max(1, (dx * dx + dy * dy).squareRoot())
        let at = CGPoint(x: p.x + dx / length * offset * 1.4, y: p.y + dy / length * offset * 1.1)
        let text = ctx.resolve(Text(name.localizedBodyName)
            .font(AppFont.bold(isPhone ? 11 : 15))
            .foregroundColor(.white.opacity(0.85)))
        ctx.draw(text, at: at)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        if let earth = PlanetMetrics.metrics(for: "Earth"),
           let mars = PlanetMetrics.metrics(for: "Mars"),
           let transfer = TransferOrbit(from: earth, to: mars) {
            TransferOrbitDiagram(origin: "Earth", target: "Mars", launchDate: Date(),
                                 transfer: transfer, isAligned: true)
                .padding()
        }
    }
}
