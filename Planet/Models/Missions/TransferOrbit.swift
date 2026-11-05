//
//  TransferOrbit.swift
//  Planet
//
//  The orbit maths behind Mission Builder and Mission Control. Figures assume
//  circular, coplanar orbits, which is accurate enough to show the right scale
//  (Earth → Mars ≈ 8.5 months, the same ballpark as real Mars missions).
//

import Foundation

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
