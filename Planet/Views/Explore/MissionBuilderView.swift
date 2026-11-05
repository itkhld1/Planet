//
//  MissionBuilderView.swift
//  Planet
//
//  Plan a trip between two planets using a Hohmann transfer orbit — the
//  minimum-energy route real missions are based on. Figures assume circular,
//  coplanar orbits, which is accurate enough to show the right scale
//  (Earth → Mars ≈ 8.5 months, the same ballpark as real Mars missions).
//

import SwiftUI

// MARK: - Physics

struct HohmannTransfer {
    /// Sun's gravitational parameter, km³/s².
    private static let muSun = 1.327_124_400_18e11
    private static let kmPerAU = 149_597_870.7

    let travelDays: Double
    let departureDeltaV: Double   // km/s, heliocentric
    let arrivalDeltaV: Double     // km/s, heliocentric
    let windowEveryDays: Double   // synodic period
    let transferDistanceKm: Double

    var totalDeltaV: Double { departureDeltaV + arrivalDeltaV }

    init?(from origin: PlanetMetrics, to target: PlanetMetrics) {
        let r1 = origin.distanceFromSunKm
        let r2 = target.distanceFromSunKm
        guard r1 > 0, r2 > 0, r1 != r2 else { return nil }

        let a = (r1 + r2) / 2
        let mu = Self.muSun
        // Half the period of the transfer ellipse.
        travelDays = .pi * (a * a * a / mu).squareRoot() / 86_400

        let v1 = (mu / r1).squareRoot()
        let v2 = (mu / r2).squareRoot()
        departureDeltaV = abs(v1 * ((2 * r2 / (r1 + r2)).squareRoot() - 1))
        arrivalDeltaV = abs(v2 * (1 - (2 * r1 / (r1 + r2)).squareRoot()))

        let p1 = origin.yearLengthDays
        let p2 = target.yearLengthDays
        windowEveryDays = 1 / abs(1 / p1 - 1 / p2)

        // Half the circumference of the ellipse (Ramanujan's approximation).
        let b: Double = (r1 * r2).squareRoot()
        let diff: Double = a - b
        let sum: Double = a + b
        let h: Double = (diff * diff) / (sum * sum)
        let correction: Double = 1 + 3 * h / (10 + (4 - 3 * h).squareRoot())
        transferDistanceKm = Double.pi * sum * correction / 2
    }
}

// MARK: - View

/// Laid out like Compare Planets: the two planets side by side, a pair of
/// menus to pick them, one card of results and a plain-language takeaway.
struct MissionBuilderView: View {
    private static let planetNames = ["Mercury", "Venus", "Earth", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune"]

    @State private var origin = "Earth"
    @State private var target = "Mars"
    @State private var launchDate = Date()

    private var isPhone: Bool { deviceType() == "iPhone" }

    private var transfer: HohmannTransfer? {
        guard let o = PlanetMetrics.metrics(for: origin),
              let t = PlanetMetrics.metrics(for: target) else { return nil }
        return HohmannTransfer(from: o, to: t)
    }

    var body: some View {
        ZStack {
            AppGradientBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    route
                    pickers
                    launchDateCard
                    if let transfer {
                        resultsCard(transfer)
                        summary
                    }
                }
                .padding()
                .frame(maxWidth: 700)
                .frame(maxWidth: .infinity)
            }
        }
        .appNavigationStyle("Mission Builder")
    }

    // MARK: Route

    private var route: some View {
        HStack(alignment: .center, spacing: 12) {
            planetDisc(origin)
            Image(systemName: "airplane")
                .font(.system(size: isPhone ? 20 : 28))
                .foregroundColor(.white.opacity(0.6))
                .environment(\.layoutDirection, .leftToRight)
            planetDisc(target)
        }
        .frame(height: (isPhone ? 100 : 150) + 40)
        .animation(.easeInOut(duration: 0.35), value: origin)
        .animation(.easeInOut(duration: 0.35), value: target)
    }

    private func planetDisc(_ name: String) -> some View {
        VStack(spacing: 10) {
            Image(name)
                .resizable()
                .scaledToFit()
                .frame(width: isPhone ? 100 : 150, height: isPhone ? 100 : 150)
                .shadow(color: .black.opacity(0.4), radius: 8)
            Text(name.localizedBodyName)
                .font(AppFont.bold(isPhone ? 15 : 21))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }

    // MARK: Pickers

    private var pickers: some View {
        HStack(spacing: 12) {
            planetMenu(selection: $origin, exclude: target)
            Button {
                playHaptic(.light)
                swap(&origin, &target)
            } label: {
                Image(systemName: "arrow.left.arrow.right")
                    .foregroundColor(.white.opacity(0.7))
            }
            .accessibilityLabel("Swap planets")
            planetMenu(selection: $target, exclude: origin)
        }
    }

    /// Excludes the other side's pick — a trip to where you already are is noise.
    private func planetMenu(selection: Binding<String>, exclude: String) -> some View {
        Menu {
            ForEach(Self.planetNames.filter { $0 != exclude }, id: \.self) { name in
                Button(name.localizedBodyName) {
                    playHaptic(.light)
                    selection.wrappedValue = name
                }
            }
        } label: {
            HStack {
                Text(selection.wrappedValue.localizedBodyName)
                    .font(AppFont.bold(isPhone ? 15 : 21))
                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: isPhone ? 11 : 15))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.3))
            .cornerRadius(14)
        }
    }

    private var launchDateCard: some View {
        DatePicker(selection: $launchDate, displayedComponents: .date) {
            Text("Launch date")
                .font(AppFont.regular(isPhone ? 14 : 20))
                .foregroundColor(.white)
        }
        .colorScheme(.dark)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .appCard()
    }

    // MARK: Results

    private func resultsCard(_ t: HohmannTransfer) -> some View {
        let arrival = Calendar.current.date(byAdding: .day, value: Int(t.travelDays.rounded()), to: launchDate) ?? launchDate

        return VStack(spacing: 0) {
            resultRow(icon: "clock.fill", title: "Travel time", value: durationText(t.travelDays))
            divider
            resultRow(icon: "calendar", title: "Arrival", value: arrival.formatted(.dateTime.day().month(.wide).year().locale(AppLanguage.locale)))
            divider
            resultRow(icon: "point.topleft.down.to.point.bottomright.curvepath.fill", title: "Distance flown", value: MetricFormat.km(t.transferDistanceKm))
            divider
            resultRow(icon: "flame.fill", title: "Engine burns (Δv)",
                      value: String(format: String(localized: "%@ km/s", bundle: Bundle.appLanguage), MetricFormat.plain(t.totalDeltaV, decimals: 1)))
            divider
            resultRow(icon: "arrow.triangle.2.circlepath", title: "Launch window every", value: durationText(t.windowEveryDays))
        }
        .appCard()
    }

    private var divider: some View {
        Divider().overlay(Color.white.opacity(0.15))
    }

    private func resultRow(icon: String, title: LocalizedStringKey, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: isPhone ? 15 : 21))
                .foregroundColor(.white.opacity(0.7))
                .frame(width: isPhone ? 22 : 30)
            Text(title)
                .font(AppFont.regular(isPhone ? 14 : 20))
                .foregroundColor(.white.opacity(0.8))
            Spacer(minLength: 8)
            Text(value)
                .font(AppFont.bold(isPhone ? 15 : 21))
                .foregroundColor(.white)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
    }

    // MARK: Summary

    private var summary: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(.yellow)
            VStack(alignment: .leading, spacing: 8) {
                Text("Spacecraft don't fly straight at a planet. They take a Hohmann transfer: half an ellipse that touches both orbits, which uses the least fuel. The planets must be lined up just right, so launch windows only open every so often.")
                    .font(AppFont.regular(isPhone ? 14 : 20))
                    .foregroundColor(.white)
                Text("Figures assume circular orbits and ignore escaping each planet's gravity.")
                    .font(AppFont.regular(isPhone ? 11 : 15))
                    .foregroundColor(.white.opacity(0.55))
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .appCard(cornerRadius: 16)
        .accessibilityElement(children: .combine)
    }

    /// Days under ~2 years read as months; longer trips as years.
    private func durationText(_ days: Double) -> String {
        if days < 60 {
            return String(format: String(localized: "%@ days", bundle: Bundle.appLanguage), MetricFormat.plain(days, decimals: 0))
        }
        if days < 730 {
            return String(format: String(localized: "%@ months", bundle: Bundle.appLanguage), MetricFormat.plain(days / 30.44, decimals: 1))
        }
        return String(format: String(localized: "%@ years", bundle: Bundle.appLanguage), MetricFormat.plain(days / 365.25, decimals: 1))
    }
}

#Preview {
    NavigationStack { MissionBuilderView() }
}
