//
//  ComparePlanetsView.swift
//  Planet
//

import SwiftUI

/// Puts two bodies side by side. Numbers like "142,984 km" mean little on
/// their own — seeing Jupiter's disc dwarf Earth's is what makes scale land.
struct ComparePlanetsView: View {
    @State private var leftName: String
    @State private var rightName: String

    private var isPhone: Bool { deviceType() == "iPhone" }

    /// Kept deliberately small so real ratios survive: Earth beside Jupiter is
    /// a true 11.6pt against 130pt. Only the Sun's extremes hit this floor, and
    /// when they do the view says so rather than quietly lying about scale.
    private let minDiscSize: CGFloat = 4

    init(left: String = "Earth", right: String = "Jupiter") {
        _leftName = State(initialValue: left)
        _rightName = State(initialValue: right)
    }

    private var left: BodyMetrics? { BodyMetrics.body(named: leftName) }
    private var right: BodyMetrics? { BodyMetrics.body(named: rightName) }

    private var maxDiscSize: CGFloat { isPhone ? 130 : 190 }

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.black, Color("GradientColor"), .purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            StarFieldView(count: 40)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    if let left, let right {
                        sizeComparison(left, right)
                        pickers
                        metricsCard(left, right)
                        summary(left, right)
                    }
                }
                .padding()
                .frame(maxWidth: 700)
            }
        }
        .navigationTitle("Compare")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    // MARK: - Size

    private func discSize(_ body: BodyMetrics, largest: Double) -> CGFloat {
        max(minDiscSize, maxDiscSize * CGFloat(body.diameterKm / largest))
    }

    /// True when the true ratio is too extreme to draw honestly — the Sun next
    /// to Mercury is 285:1, which would be a sub-pixel dot.
    private func isClamped(_ a: BodyMetrics, _ b: BodyMetrics) -> Bool {
        let largest = max(a.diameterKm, b.diameterKm)
        let smallest = min(a.diameterKm, b.diameterKm)
        return maxDiscSize * CGFloat(smallest / largest) < minDiscSize
    }

    /// Both discs are scaled against the larger of the two, so the ratio you
    /// see is the real ratio — until it has to be clamped.
    private func sizeComparison(_ leftBody: BodyMetrics, _ rightBody: BodyMetrics) -> some View {
        let largest = max(leftBody.diameterKm, rightBody.diameterKm)

        return VStack(spacing: 10) {
            HStack(alignment: .center, spacing: 20) {
                disc(leftBody, size: discSize(leftBody, largest: largest))
                disc(rightBody, size: discSize(rightBody, largest: largest))
            }
            .frame(height: maxDiscSize + 50)

            if isClamped(leftBody, rightBody) {
                Text("Not to scale — the smaller one is shown larger than it really is.")
                    .font(AppFont.regular(isPhone ? 11 : 15))
                    .foregroundColor(.white.opacity(0.55))
                    .multilineTextAlignment(.center)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: leftName)
        .animation(.easeInOut(duration: 0.35), value: rightName)
    }

    private func disc(_ body: BodyMetrics, size: CGFloat) -> some View {
        VStack(spacing: 10) {
            Spacer(minLength: 0)
            Image(body.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .shadow(color: .black.opacity(0.4), radius: 8)
            Text(body.name.localizedBodyName)
                .font(AppFont.bold(isPhone ? 15 : 21))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }

    // MARK: - Pickers

    private var pickers: some View {
        HStack(spacing: 12) {
            bodyMenu(selection: $leftName, exclude: rightName)
            Image(systemName: "arrow.left.and.right")
                .foregroundColor(.white.opacity(0.5))
            bodyMenu(selection: $rightName, exclude: leftName)
        }
    }

    /// Excludes the other side's pick — comparing a body with itself is noise.
    private func bodyMenu(selection: Binding<String>, exclude: String) -> some View {
        Menu {
            ForEach(BodyMetrics.all.filter { $0.name != exclude }) { body in
                Button(body.name.localizedBodyName) {
                    playHaptic(.light)
                    selection.wrappedValue = body.name
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

    // MARK: - Metrics

    private func metricsCard(_ l: BodyMetrics, _ r: BodyMetrics) -> some View {
        VStack(spacing: 0) {
            metricRow("Diameter",
                      MetricFormat.km(l.diameterKm), MetricFormat.km(r.diameterKm),
                      winner: rank(l.diameterKm, r.diameterKm))
            divider
            metricRow("Distance from Sun",
                      l.distanceText, r.distanceText,
                      winner: rank(l.distanceKm, r.distanceKm))
            divider
            metricRow("Day Length",
                      MetricFormat.hours(l.dayLengthHours), MetricFormat.hours(r.dayLengthHours),
                      winner: rank(l.dayLengthHours, r.dayLengthHours))
            divider
            metricRow("Year length",
                      l.yearText, r.yearText,
                      winner: rank(l.yearDays, r.yearDays))
            divider
            metricRow("Gravity",
                      MetricFormat.gravity(l.gravity), MetricFormat.gravity(r.gravity),
                      winner: rank(l.gravity, r.gravity))
            divider
            metricRow(satellitesLabel(l, r),
                      l.satellitesText, r.satellitesText,
                      winner: rank(l.satelliteCount, r.satelliteCount))
        }
        .background(Color.black.opacity(0.28))
        .cornerRadius(18)
    }

    /// "Moons" for two planets, but the Sun's are planets — so say so.
    private func satellitesLabel(_ l: BodyMetrics, _ r: BodyMetrics) -> String {
        l.satellitesLabel == r.satellitesLabel ? l.satellitesLabel : "Orbiting bodies"
    }

    private enum Winner { case left, right, neither }

    /// Ranks a row, or gives up when either side has no comparable number.
    private func rank<T: Comparable>(_ l: T?, _ r: T?) -> Winner {
        guard let l, let r else { return .neither }
        if l == r { return .neither }
        return l > r ? .left : .right
    }

    private var divider: some View {
        Divider().overlay(Color.white.opacity(0.15))
    }

    /// The larger value is brightened — it's the fastest way to read the table.
    private func metricRow(_ label: String, _ leftValue: String, _ rightValue: String,
                           winner: Winner) -> some View {
        let label = label.localizedFromCatalog
        return VStack(spacing: 6) {
            Text(label)
                .font(AppFont.regular(isPhone ? 12 : 17))
                .foregroundColor(.white.opacity(0.55))

            HStack {
                Text(leftValue)
                    .foregroundColor(.white.opacity(winner == .right ? 0.5 : 1))
                    .fontWeight(winner == .left ? .bold : .regular)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(rightValue)
                    .foregroundColor(.white.opacity(winner == .left ? 0.5 : 1))
                    .fontWeight(winner == .right ? .bold : .regular)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .font(AppFont.regular(isPhone ? 14 : 20))
            .multilineTextAlignment(.leading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(leftName.localizedBodyName) \(leftValue), \(rightName.localizedBodyName) \(rightValue)")
    }

    // MARK: - Summary

    /// One plain-language takeaway, which is what most kids will actually read.
    private func summary(_ l: BodyMetrics, _ r: BodyMetrics) -> some View {
        let ratio = max(l.diameterKm, r.diameterKm) / min(l.diameterKm, r.diameterKm)
        let bigger = l.diameterKm > r.diameterKm ? l.name : r.name
        let smaller = l.diameterKm > r.diameterKm ? r.name : l.name

        return HStack(alignment: .top, spacing: 10) {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(.yellow)
            // `String(format: "%.1f")` would print "109.2" in Western digits
            // inside otherwise-Persian text.
            Text("\(bigger) is about \(MetricFormat.decimal(ratio, maxDecimals: 1))× wider than \(smaller).")
                .font(AppFont.regular(isPhone ? 14 : 20))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .background(Color.black.opacity(0.28))
        .cornerRadius(16)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack {
        ComparePlanetsView()
    }
}
