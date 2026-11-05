//
//  SpaceWeatherFeedView.swift
//  Planet
//
//  Live space weather from NOAA's Space Weather Prediction Center.
//  The endpoints are public, need no key, and update every few minutes.
//

import SwiftUI

// MARK: - Model

struct SpaceWeatherReport {
    var solarWindSpeed: Double?      // km/s
    var magneticFieldBz: Double?     // nT, negative = geomagnetically effective
    var solarFlux: Double?           // 10.7 cm radio flux, solar flux units
    var kpIndex: Double?             // 0–9
    var geomagneticScale: Int?       // NOAA G-scale 0–5
    var radioScale: Int?             // NOAA R-scale 0–5
    var radiationScale: Int?         // NOAA S-scale 0–5
    var updated = Date()
}

// MARK: - Service

enum SpaceWeatherService {
    private static let base = "https://services.swpc.noaa.gov/products/"

    static func fetch() async throws -> SpaceWeatherReport {
        // Fetched together; one failing endpoint shouldn't blank the screen,
        // so each is optional and only a total failure throws.
        async let wind = json("summary/solar-wind-speed.json")
        async let mag = json("summary/solar-wind-mag-field.json")
        async let flux = json("summary/10cm-flux.json")
        async let kp = json("noaa-planetary-k-index.json")
        async let scales = json("noaa-scales.json")

        let (w, m, f, k, s) = await (try? wind, try? mag, try? flux, try? kp, try? scales)
        guard let report = report(wind: w, magneticField: m, flux: f, kp: k, scales: s) else {
            throw URLError(.cannotLoadFromNetwork)
        }
        return report
    }

    /// Builds a report from the decoded JSON of each endpoint. Nil only when
    /// every endpoint failed.
    static func report(wind: Any?, magneticField: Any?, flux: Any?, kp: Any?, scales: Any?,
                       updated: Date = Date()) -> SpaceWeatherReport? {
        if wind == nil && magneticField == nil && flux == nil && kp == nil && scales == nil {
            return nil
        }

        var report = SpaceWeatherReport(updated: updated)
        report.solarWindSpeed = latest(wind, key: "proton_speed")
        report.magneticFieldBz = latest(magneticField, key: "bz_gsm")
        report.solarFlux = latest(flux, key: "flux")
        report.kpIndex = latest(kp, key: "Kp")

        if let current = (scales as? [String: Any])?["0"] as? [String: Any] {
            report.geomagneticScale = scale(current["G"])
            report.radioScale = scale(current["R"])
            report.radiationScale = scale(current["S"])
        }
        return report
    }

    private static func json(_ path: String) async throws -> Any {
        guard let url = URL(string: base + path) else { throw URLError(.badURL) }
        var request = URLRequest(url: url)
        request.timeoutInterval = 15
        request.cachePolicy = .reloadIgnoringLocalCacheData
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw URLError(.badServerResponse) }
        return try JSONSerialization.jsonObject(with: data)
    }

    /// NOAA returns arrays of objects, newest last. Values are sometimes
    /// numbers and sometimes strings, so both are accepted.
    private static func latest(_ object: Any?, key: String) -> Double? {
        guard let rows = object as? [[String: Any]] else { return nil }
        for row in rows.reversed() {
            if let value = number(row[key]) { return value }
        }
        return nil
    }

    private static func scale(_ object: Any?) -> Int? {
        guard let dict = object as? [String: Any], let value = number(dict["Scale"]) else { return nil }
        return Int(value)
    }

    private static func number(_ value: Any?) -> Double? {
        switch value {
        case let n as NSNumber: return n.doubleValue
        case let s as String: return Double(s)
        default: return nil
        }
    }
}

// MARK: - View model

@MainActor
@Observable
final class SpaceWeatherViewModel {
    var report: SpaceWeatherReport?
    var isLoading = false
    var failed = false

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            report = try await SpaceWeatherService.fetch()
            failed = false
        } catch {
            failed = report == nil
        }
    }
}

// MARK: - View

/// Laid out like Compare Planets: a visual headline, then one dark card of
/// labelled rows, then a plain-language takeaway.
struct SpaceWeatherFeedView: View {
    @State private var viewModel = SpaceWeatherViewModel()

    private var isPhone: Bool { deviceType() == "iPhone" }

    var body: some View {
        ZStack {
            AppGradientBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    if let report = viewModel.report {
                        auroraHeadline(report)
                        metricsCard(report)
                        scalesCard(report)
                        summary

                        Text("Data: NOAA Space Weather Prediction Center · Updated \(report.updated.formatted(date: .omitted, time: .shortened))")
                            .font(AppFont.regular(isPhone ? 11 : 15))
                            .foregroundColor(Palette.secondaryText)
                            .multilineTextAlignment(.center)
                    } else if viewModel.failed {
                        errorState
                    } else {
                        ProgressView()
                            .tint(.white)
                            .padding(.top, 80)
                    }
                }
                .padding()
                .frame(maxWidth: 700)
                .frame(maxWidth: .infinity)
            }
            .refreshable { await viewModel.load() }
        }
        .appNavigationStyle("Space Weather")
        .task { await viewModel.load() }
    }

    // MARK: Aurora headline

    private func auroraHeadline(_ report: SpaceWeatherReport) -> some View {
        let kp = report.kpIndex ?? 0
        let (title, detail, color): (LocalizedStringKey, LocalizedStringKey, Color) = {
            switch kp {
            case ..<4:
                return ("Quiet", "Auroras only near the poles tonight.", .green)
            case ..<5:
                return ("Unsettled", "Auroras possible at high latitudes.", .yellow)
            case ..<7:
                return ("Geomagnetic storm", "Auroras may reach further from the poles than usual.", .orange)
            default:
                return ("Strong storm", "Auroras may be visible far from the poles.", .red)
            }
        }()

        return VStack(spacing: 10) {
            Image("Earth")
                .resizable()
                .scaledToFit()
                .frame(width: isPhone ? 110 : 160, height: isPhone ? 110 : 160)
                .shadow(color: color.opacity(0.6), radius: 24)
                .padding(.vertical, 6)

            Text("Aurora outlook")
                .font(AppFont.regular(isPhone ? 12 : 17))
                .foregroundColor(Palette.secondaryText)
            Text(title)
                .font(AppFont.bold(isPhone ? 24 : 34))
                .foregroundColor(color)
            Text(detail)
                .font(AppFont.regular(isPhone ? 14 : 20))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)

            // Kp gauge 0–9
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Palette.card)
                    Capsule()
                        .fill(LinearGradient(colors: [.green, .yellow, .orange, .red], startPoint: .leading, endPoint: .trailing))
                        .frame(width: max(8, geo.size.width * min(kp, 9) / 9))
                }
            }
            .frame(height: 8)
            .environment(\.layoutDirection, .leftToRight)
            .padding(.top, 4)

            Text("Kp index: \(MetricFormat.plain(kp, decimals: 1)) / 9")
                .font(AppFont.regular(isPhone ? 12 : 17))
                .foregroundColor(Palette.secondaryText)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }

    // MARK: Metrics

    private func metricsCard(_ report: SpaceWeatherReport) -> some View {
        VStack(spacing: 0) {
            metricRow("Solar wind", icon: "wind",
                      value: report.solarWindSpeed.map { String(format: String(localized: "%@ km/s", bundle: Bundle.appLanguage), MetricFormat.plain($0, decimals: 0)) },
                      note: "Speed of particles from the Sun")
            divider
            metricRow("Magnetic field Bz", icon: "arrow.up.and.down",
                      value: report.magneticFieldBz.map { String(format: String(localized: "%@ nT", bundle: Bundle.appLanguage), MetricFormat.plain($0, decimals: 1)) },
                      note: "Negative values help auroras form")
            divider
            metricRow("Solar flux", icon: "sun.max.fill",
                      value: report.solarFlux.map { MetricFormat.plain($0, decimals: 0) + " sfu" },
                      note: "How active the Sun is")
            divider
            metricRow("Kp index", icon: "gauge.with.dots.needle.33percent",
                      value: report.kpIndex.map { MetricFormat.plain($0, decimals: 1) },
                      note: "Disturbance of Earth's magnetic field")
        }
        .appCard()
    }

    private var divider: some View {
        Divider().overlay(Color.white.opacity(0.15))
    }

    private func metricRow(_ title: LocalizedStringKey, icon: String, value: String?, note: LocalizedStringKey) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: isPhone ? 15 : 21))
                .foregroundColor(.white.opacity(0.7))
                .frame(width: isPhone ? 22 : 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppFont.regular(isPhone ? 14 : 20))
                    .foregroundColor(.white)
                Text(note)
                    .font(AppFont.regular(isPhone ? 12 : 17))
                    .foregroundColor(Palette.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 8)

            Text(value ?? "—")
                .font(AppFont.bold(isPhone ? 15 : 21))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
    }

    // MARK: NOAA scales

    private func scalesCard(_ report: SpaceWeatherReport) -> some View {
        VStack(spacing: 0) {
            Text("NOAA storm scales")
                .font(AppFont.regular(isPhone ? 12 : 17))
                .foregroundColor(Palette.secondaryText)
                .frame(maxWidth: .infinity)
                .padding(.top, 12)
                .padding(.bottom, 4)
            scaleRow("G", title: "Geomagnetic storms", level: report.geomagneticScale)
            divider
            scaleRow("S", title: "Solar radiation storms", level: report.radiationScale)
            divider
            scaleRow("R", title: "Radio blackouts", level: report.radioScale)
        }
        .appCard()
    }

    private func scaleRow(_ letter: String, title: LocalizedStringKey, level: Int?) -> some View {
        let level = level ?? 0
        let color: Color = level == 0 ? .green : level <= 2 ? .yellow : level <= 3 ? .orange : .red
        return HStack(spacing: 12) {
            Text(title)
                .font(AppFont.regular(isPhone ? 14 : 20))
                .foregroundColor(.white)
            Spacer()
            Text(verbatim: "\(letter)\(level)")
                .font(AppFont.bold(isPhone ? 14 : 20))
                .foregroundColor(.black)
                .frame(width: isPhone ? 40 : 54, height: isPhone ? 26 : 34)
                .background(RoundedRectangle(cornerRadius: 8).fill(color))
                .environment(\.layoutDirection, .leftToRight)
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
            Text("Scales run from 0 (none) to 5 (extreme).")
                .font(AppFont.regular(isPhone ? 14 : 20))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .appCard(cornerRadius: 16)
    }

    private var errorState: some View {
        VStack(spacing: 12) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 40))
                .foregroundColor(Palette.secondaryText)
            Text("Couldn't load space weather")
                .font(AppFont.bold(isPhone ? 16 : 22))
                .foregroundColor(.white)
            Text("Check your internet connection and try again.")
                .font(AppFont.regular(isPhone ? 13 : 18))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            Button {
                playHaptic(.light)
                Task { await viewModel.load() }
            } label: {
                Text("Try Again")
                    .font(AppFont.bold(isPhone ? 15 : 21))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Palette.card)
                    .cornerRadius(14)
            }
        }
        .padding(.top, 80)
    }
}

#Preview {
    NavigationStack { SpaceWeatherFeedView() }
}
