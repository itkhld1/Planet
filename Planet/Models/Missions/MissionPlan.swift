//
//  MissionPlan.swift
//  Planet
//
//  Everything Mission Builder works out for one trip: the transfer, whether
//  the planets are lined up, the round trip and the radio delay. Kept out of
//  the view so it can be tested.
//

import Foundation

struct MissionPlan {
    let origin: String
    let target: String
    let launchDate: Date
    /// 0 = cheapest (Hohmann), 1 = fastest this app allows.
    let speed: Double
    let transfer: TransferOrbit

    init?(origin: String, target: String, launchDate: Date, speed: Double) {
        guard let o = PlanetMetrics.metrics(for: origin),
              let t = PlanetMetrics.metrics(for: target),
              let transfer = TransferOrbit(from: o, to: t, speed: speed) else { return nil }
        self.origin = origin
        self.target = target
        self.launchDate = launchDate
        self.speed = speed
        self.transfer = transfer
    }

    /// The calendar day of arrival, as shown to the user.
    var arrivalDay: Date {
        Calendar.current.date(byAdding: .day, value: Int(transfer.travelDays.rounded()), to: launchDate) ?? launchDate
    }

    private var arrival: Date {
        launchDate.addingTimeInterval(transfer.travelDays * 86_400)
    }

    var windowEveryDays: Double {
        LaunchWindow.synodicDays(origin, target) ?? transfer.windowEveryDays
    }

    // MARK: Launch window

    enum WindowStatus: Equatable {
        case open
        case closed(next: Date)
    }

    /// Whether the launch date is close to an alignment, and if not, when the
    /// next one is. Also looks back one tolerance, so a date just after the
    /// ideal day still counts as open.
    var windowStatus: WindowStatus? {
        guard let synodic = LaunchWindow.synodicDays(origin, target) else { return nil }
        let tolerance = LaunchWindow.tolerance(synodicDays: synodic) * 86_400
        let searchFrom = launchDate.addingTimeInterval(-tolerance)
        guard let ideal = LaunchWindow.next(from: origin, to: target, travelDays: transfer.travelDays,
                                            sweptAngle: transfer.sweptAngle, after: searchFrom) else {
            return nil
        }
        return abs(ideal.timeIntervalSince(launchDate)) <= tolerance ? .open : .closed(next: ideal)
    }

    var isAligned: Bool { windowStatus == .open }

    // MARK: Round trip

    struct RoundTrip {
        let waitDays: Double
        let returnDays: Double
        let totalDays: Double
        let homeDate: Date
    }

    /// Fly out, wait at the destination for the planets to line up again,
    /// then fly home on the same kind of route.
    var roundTrip: RoundTrip? {
        guard let o = PlanetMetrics.metrics(for: origin),
              let tg = PlanetMetrics.metrics(for: target),
              let back = TransferOrbit(from: tg, to: o, speed: speed),
              let leave = LaunchWindow.next(from: target, to: origin, travelDays: back.travelDays,
                                            sweptAngle: back.sweptAngle, after: arrival) else { return nil }
        let home = leave.addingTimeInterval(back.travelDays * 86_400)
        return RoundTrip(waitDays: leave.timeIntervalSince(arrival) / 86_400,
                         returnDays: back.travelDays,
                         totalDays: home.timeIntervalSince(launchDate) / 86_400,
                         homeDate: home)
    }

    // MARK: Signal delay

    /// How long a radio message takes from the target back to the origin
    /// planet, on the day you arrive. Uses both planets' real positions then.
    var signalDelaySeconds: Double? {
        guard let o = PlanetMetrics.metrics(for: origin),
              let tg = PlanetMetrics.metrics(for: target),
              let lO = LaunchWindow.longitude(origin, on: arrival),
              let lT = LaunchWindow.longitude(target, on: arrival) else { return nil }
        let r1 = o.distanceFromSunKm, r2 = tg.distanceFromSunKm
        let distance = (r1 * r1 + r2 * r2 - 2 * r1 * r2 * cos(lT - lO)).squareRoot()
        return distance / 299_792.458
    }
}
