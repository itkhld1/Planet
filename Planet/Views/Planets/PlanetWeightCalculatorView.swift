//
//  PlanetWeightCalculatorView.swift
//  Planet
//
//  Created by itkhld on 2024-09-30.
//
//  The weight and age calculators. Each is its own Explore entry and is
//  pushed onto Explore's stack, styled like Compare Planets.
//

import SwiftUI

/// Surface gravity (× Earth) and orbital period (Earth years) per planet.
private let calculatorPlanets: [(name: String, gravity: Double, year: Double)] = [
    ("Earth", 1.00, 1.00),
    ("Mercury", 0.38, 0.241),
    ("Venus", 0.91, 0.615),
    ("Mars", 0.38, 1.88),
    ("Jupiter", 2.34, 11.86),
    ("Saturn", 1.06, 29.46),
    ("Uranus", 0.92, 84.01),
    ("Neptune", 1.19, 164.79)
]

// MARK: - Weight

struct PlanetWeightCalculatorView: View {
    @AppStorage("weightOnEarth") private var weightOnEarth = ""
    @AppStorage(SettingsKey.weightUnit) private var weightUnitRaw = WeightUnit.kilograms.rawValue

    private static let poundsPerKilogram = 2.20462

    private var weightUnit: WeightUnit {
        WeightUnit(rawValue: weightUnitRaw) ?? .kilograms
    }

    private var parsed: Double? { MetricFormat.parse(weightOnEarth) }

    private var error: String? {
        guard !weightOnEarth.isEmpty, (parsed ?? 0) <= 0 else { return nil }
        return "Enter a valid weight greater than 0."
    }

    private var results: [(String, Double)] {
        guard let w = parsed, w > 0 else { return [] }
        return calculatorPlanets.map { ($0.name, w * $0.gravity) }
    }

    var body: some View {
        CalculatorScreen(
            prompt: "Your weight on Earth (\(weightUnit.shortName))",
            text: $weightOnEarth,
            error: error,
            results: results,
            unit: weightUnit.shortName,
            emptyHint: "Enter your weight to see how the planets' gravity changes it.",
            footnote: "Gravity is what gives you weight. Stronger gravity pulls harder, so the same body weighs more on Jupiter than on Mars."
        ) {
            unitPicker
        }
        .appNavigationStyle("Weight Calculator")
    }

    /// Switching units rewrites the entered value so the number keeps meaning
    /// the same thing (70 kg becomes 154.32 lbs, not 70 lbs).
    private var unitPicker: some View {
        Picker("Unit", selection: Binding(
            get: { weightUnit },
            set: { newUnit in
                convertEnteredWeight(from: weightUnit, to: newUnit)
                weightUnitRaw = newUnit.rawValue
                playHaptic(.light)
            }
        )) {
            ForEach(WeightUnit.allCases) { unit in
                Text(unit.displayName).tag(unit)
            }
        }
        .pickerStyle(.segmented)
    }

    private func convertEnteredWeight(from old: WeightUnit, to new: WeightUnit) {
        guard old != new, let value = parsed else { return }
        let converted = new == .pounds
            ? value * Self.poundsPerKilogram
            : value / Self.poundsPerKilogram
        weightOnEarth = MetricFormat.decimal(converted)
    }
}

// MARK: - Age

struct PlanetAgeCalculatorView: View {
    @AppStorage("ageOnEarth") private var ageOnEarth = ""

    private var parsed: Double? { MetricFormat.parse(ageOnEarth) }

    private var error: String? {
        guard !ageOnEarth.isEmpty, (parsed ?? 0) <= 0 else { return nil }
        return "Enter a valid age greater than 0."
    }

    private var results: [(String, Double)] {
        guard let a = parsed, a > 0 else { return [] }
        return calculatorPlanets.map { ($0.name, a / $0.year) }
    }

    var body: some View {
        CalculatorScreen(
            prompt: "Your age on Earth (years)",
            text: $ageOnEarth,
            error: error,
            results: results,
            unit: "yrs",
            emptyHint: "Enter your age to see how many orbits you'd have made on each planet.",
            footnote: "One year is a different length on every planet"
        ) {
            EmptyView()
        }
        .appNavigationStyle("Age Calculator")
    }
}

// MARK: - Shared layout

/// Input on top, live results in one card below, a tip at the bottom — the
/// same stack of panels Compare Planets uses.
private struct CalculatorScreen<Accessory: View>: View {
    let prompt: LocalizedStringKey
    @Binding var text: String
    let error: String?
    let results: [(String, Double)]
    let unit: String
    let emptyHint: LocalizedStringKey
    let footnote: LocalizedStringKey
    @ViewBuilder let accessory: () -> Accessory

    private var isPhone: Bool { deviceType() == "iPhone" }

    var body: some View {
        ZStack {
            AppGradientBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    accessory()
                    inputField

                    if results.isEmpty {
                        Text(emptyHint)
                            .font(AppFont.regular(isPhone ? 14 : 20))
                            .foregroundColor(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 30)
                    } else {
                        resultsCard
                    }

                    tip
                }
                .padding()
                .frame(maxWidth: 700)
                .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { hideKeyboard() }
            }
        }
    }

    private var inputField: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                TextField("", text: $text, prompt: Text(prompt).foregroundColor(.white.opacity(0.5)))
                    .keyboardType(.decimalPad)
                    .foregroundColor(.white)
                    .font(AppFont.bold(isPhone ? 17 : 24))

                if !text.isEmpty {
                    Button {
                        text = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .accessibilityLabel("Clear")
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.black.opacity(0.3))
            .cornerRadius(14)

            if let error {
                Label(error.localizedFromCatalog, systemImage: "exclamationmark.triangle.fill")
                    .font(AppFont.regular(isPhone ? 12 : 17))
                    .foregroundColor(.orange)
                    .padding(.horizontal, 6)
            }
        }
    }

    private var resultsCard: some View {
        VStack(spacing: 0) {
            ForEach(Array(results.enumerated()), id: \.element.0) { index, result in
                if index > 0 {
                    Divider().overlay(Color.white.opacity(0.15))
                }
                row(planet: result.0, value: "\(MetricFormat.decimal(result.1)) \(unit.localizedFromCatalog)")
            }
        }
        .appCard()
    }

    private func row(planet: String, value: String) -> some View {
        HStack(spacing: 14) {
            Image(planet)
                .resizable()
                .scaledToFit()
                .frame(width: isPhone ? 32 : 46, height: isPhone ? 32 : 46)

            Text(planet.localizedBodyName)
                .fontWeight(planet == "Earth" ? .bold : .regular)

            Spacer(minLength: 8)

            Text(value)
                .fontWeight(.bold)
        }
        .font(AppFont.regular(isPhone ? 14 : 20))
        .foregroundColor(.white.opacity(planet == "Earth" ? 1 : 0.9))
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .accessibilityElement(children: .combine)
    }

    private var tip: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(.yellow)
            Text(footnote)
                .font(AppFont.regular(isPhone ? 14 : 20))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .appCard(cornerRadius: 16)
        .accessibilityElement(children: .combine)
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    NavigationStack { PlanetWeightCalculatorView() }
}
