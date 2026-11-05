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
    /// Whether the target will be at the meeting point — colours the arrival
    /// marker green or orange. `nil` leaves it neutral (a challenge before
    /// launch, where the answer mustn't be given away).
    let isAligned: Bool?
    var mode: Mode = .loop
    /// Overrides the diagram's height (the share card uses a fixed size).
    var height: CGFloat? = nil
    /// On arrival, trace how far the target was from the meeting point.
    var showsMiss = false

    enum Mode: Equatable {
        /// The flight on repeat, as on Mission Builder.
        case loop
        /// One frame at this point of the flight. Used by the share image.
        case still(Double)
        /// Planets frozen at launch, for lining up a shot. With `showGuide`, a
        /// marker shows where the target needs to be for a hit.
        case aim(showGuide: Bool)
        /// The flight once, from `start`, then holding on arrival.
        case flight(start: Date)
    }

    /// How long a challenge launch takes on screen.
    static let launchFlightSeconds = 4.0

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    // The player's own spacecraft: its colour paints the trail, its icon flies.
    private var craftColorIndex: Int { ProgressStore.shared.spacecraftColor }
    private var craftIconIndex: Int { ProgressStore.shared.spacecraftIcon }

    private var isPhone: Bool { deviceType() == "iPhone" }
    private var travelDays: Double { transfer.travelDays }
    private var originRadius: Double { transfer.originRadius }
    private var targetRadius: Double { transfer.targetRadius }

    /// Seconds the flight takes on screen, then a pause on the arrival.
    private let flightSeconds = 6.0
    private let pauseSeconds = 1.5

    var body: some View {
        VStack(spacing: 8) {
            // Still frames skip TimelineView entirely: ImageRenderer (used for
            // the share image) doesn't reliably draw timeline content.
            switch mode {
            case .still(let progress):
                frame(progress: progress)
            case .aim(let showGuide):
                frame(progress: 0, guide: showGuide)
            case .flight(let start):
                TimelineView(.animation(paused: reduceMotion)) { context in
                    let elapsed = context.date.timeIntervalSince(start)
                    frame(progress: reduceMotion ? 1 : min(max(elapsed / Self.launchFlightSeconds, 0), 1))
                }
            case .loop:
                TimelineView(.animation(paused: reduceMotion)) { context in
                    frame(progress: reduceMotion ? 1 : progress(at: context.date))
                }
            }

            Text("Distances not to scale")
                .font(AppFont.regular(isPhone ? 11 : 15))
                .foregroundColor(Palette.secondaryText)
        }
        // A spatial diagram: never mirror it for right-to-left languages.
        .environment(\.layoutDirection, .leftToRight)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Orbit diagram: \(origin.localizedBodyName) to \(target.localizedBodyName)"))
    }

    private func frame(progress: Double, guide: Bool = false) -> some View {
        VStack(spacing: 8) {
            Canvas { ctx, size in
                draw(in: &ctx, size: size, progress: progress, guide: guide)
            }
            .frame(height: height ?? (isPhone ? 280 : 400))

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

    private func draw(in ctx: inout GraphicsContext, size: CGSize, progress f: Double, guide: Bool) {
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
        ctx.stroke(route, with: .color(Palette.accent.opacity(0.35)), style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
        ctx.stroke(flown, with: .color(Spacecraft.color(craftColorIndex)), style: StrokeStyle(lineWidth: 2, lineCap: .round))

        // Arrival marker: green when the target will be there, orange when
        // not, white when that's still a secret.
        let arrival = point(departAngle + transfer.sweptAngle, s(targetRadius), center: center)
        let ring: CGFloat = planetSize + 10
        let ringColor: Color = isAligned.map { $0 ? Palette.success : Palette.warning } ?? .white
        ctx.stroke(Path(ellipseIn: CGRect(x: arrival.x - ring / 2, y: arrival.y - ring / 2, width: ring, height: ring)),
                   with: .color(ringColor.opacity(0.8)),
                   style: StrokeStyle(lineWidth: 1.5, dash: [3, 3]))

        // Aim guide: where the target must be *now* to reach the meeting
        // point together with the spacecraft — it has to lead by the angle it
        // covers during the flight.
        if guide {
            let aimAngle = departAngle + transfer.sweptAngle - nT * travelDays
            let aim = point(aimAngle, s(targetRadius), center: center)
            let g: CGFloat = planetSize + 6
            ctx.fill(Path(ellipseIn: CGRect(x: aim.x - g / 2, y: aim.y - g / 2, width: g, height: g)),
                     with: .color(.yellow.opacity(0.15)))
            ctx.stroke(Path(ellipseIn: CGRect(x: aim.x - g / 2, y: aim.y - g / 2, width: g, height: g)),
                       with: .color(.yellow.opacity(0.9)),
                       style: StrokeStyle(lineWidth: 1.5, dash: [2, 3]))
        }

        // Miss: an arc along the target's orbit from the empty meeting point
        // to where the planet really was, and an ✕ on the spot it missed.
        if showsMiss && f >= 1 {
            let from = departAngle + transfer.sweptAngle
            let to = targetStart + nT * travelDays
            var delta = (to - from).truncatingRemainder(dividingBy: 2 * .pi)
            if delta > .pi { delta -= 2 * .pi }
            if delta < -.pi { delta += 2 * .pi }
            var arc = Path()
            for i in 0...40 {
                let p = point(from + delta * Double(i) / 40, s(targetRadius), center: center)
                if i == 0 { arc.move(to: p) } else { arc.addLine(to: p) }
            }
            ctx.stroke(arc, with: .color(.orange), style: StrokeStyle(lineWidth: 3, lineCap: .round))

            let x: CGFloat = 6
            var cross = Path()
            cross.move(to: CGPoint(x: arrival.x - x, y: arrival.y - x))
            cross.addLine(to: CGPoint(x: arrival.x + x, y: arrival.y + x))
            cross.move(to: CGPoint(x: arrival.x + x, y: arrival.y - x))
            cross.addLine(to: CGPoint(x: arrival.x - x, y: arrival.y + x))
            ctx.stroke(cross, with: .color(.orange), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
        }

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

        // The player's spacecraft, with a soft glow in its colour.
        let craftColor = Spacecraft.color(craftColorIndex)
        let icon = Spacecraft.icon(craftIconIndex)
        let sc = spacecraft(at: f)
        let craft = point(departAngle + sc.swept, s(sc.r), center: center)
        ctx.fill(Path(ellipseIn: CGRect(x: craft.x - 10, y: craft.y - 10, width: 20, height: 20)),
                 with: .color(craftColor.opacity(0.35)))

        if icon.symbol == "circle.fill" {
            ctx.fill(Path(ellipseIn: CGRect(x: craft.x - 3.5, y: craft.y - 3.5, width: 7, height: 7)),
                     with: .color(.white))
        } else {
            var symbol = ctx.resolve(Image(systemName: icon.symbol))
            symbol.shading = .color(.white)
            var c = ctx
            c.translateBy(x: craft.x, y: craft.y)
            if let pointsAt = icon.pointsAt {
                // Face along the route: direction to a point a little further on.
                let ahead = spacecraft(at: min(f + 0.01, 1))
                let behind = spacecraft(at: max(f - 0.01, 0))
                let p2 = point(departAngle + ahead.swept, s(ahead.r), center: center)
                let p1 = point(departAngle + behind.swept, s(behind.r), center: center)
                let heading = atan2(p2.y - p1.y, p2.x - p1.x)
                c.rotate(by: .radians(heading - pointsAt * .pi / 180))
            }
            let side: CGFloat = 13
            c.draw(symbol, in: CGRect(x: -side / 2, y: -side / 2, width: side, height: side))
        }
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
