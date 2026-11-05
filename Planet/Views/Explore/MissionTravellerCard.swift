//
//  MissionTravellerCard.swift
//  Planet
//
//  Makes a Mission Builder trip personal: the spacecraft, everyone's age on
//  arrival and back home, and whether there's enough food on board.
//

import SwiftUI

struct MissionTravellerCard: View {
    let plan: MissionPlan

    /// Written by the Age Calculator; read here for "your age on arrival".
    @AppStorage(SettingsKey.ageOnEarth) private var ageOnEarth = ""

    private var isPhone: Bool { deviceType() == "iPhone" }

    private var earthAge: Double? {
        guard let age = MetricFormat.parse(ageOnEarth), age > 0 else { return nil }
        return age
    }

    var body: some View {
        let t = plan.transfer
        let crew = ProgressStore.shared.crew
        let people = 1 + crew.count
        let trip = plan.roundTrip

        VStack(spacing: 0) {
            NavigationLink {
                SpacecraftView()
            } label: {
                SpacecraftSummaryRow()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.plain)

            CardDivider()
            crewRow(name: Text("You"), age: earthAge, t: t, trip: trip)
            ForEach(Array(crew.enumerated()), id: \.element.id) { i, member in
                CardDivider()
                crewRow(name: member.name.trimmingCharacters(in: .whitespaces).isEmpty
                            ? Text("Crewmate \(i + 1)") : Text(verbatim: member.name),
                        age: member.age, t: t, trip: trip)
            }
            CardDivider()
            supplies(people: people, t: t, trip: trip)
        }
        .appCard()
    }

    /// One person: their age on arrival, and when they're back home.
    private func crewRow(name: Text, age: Double?, t: TransferOrbit, trip: MissionPlan.RoundTrip?) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "person.fill")
                .font(.system(size: isPhone ? 15 : 21))
                .foregroundColor(.white.opacity(0.7))
                .frame(width: isPhone ? 22 : 30)
            name
                .font(AppFont.regular(isPhone ? 14 : 20))
                .foregroundColor(.white)
                .lineLimit(1)
            Spacer(minLength: 8)
            if let age {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(MetricFormat.plain(age + t.travelDays / 365.25, decimals: 1)) on arrival")
                        .font(AppFont.bold(isPhone ? 14 : 20))
                        .foregroundColor(.white)
                    if let trip {
                        Text("\(MetricFormat.plain(age + trip.totalDays / 365.25, decimals: 1)) back home")
                            .font(AppFont.regular(isPhone ? 12 : 17))
                            .foregroundColor(Palette.secondaryText)
                    }
                }
            } else {
                NavigationLink {
                    PlanetAgeCalculatorView()
                } label: {
                    Text("Add your age")
                        .font(AppFont.bold(isPhone ? 14 : 20))
                        .foregroundColor(Palette.accent)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .accessibilityElement(children: .combine)
    }

    /// A long trip has to carry a lot of food.
    private func supplies(people: Int, t: TransferOrbit, trip: MissionPlan.RoundTrip?) -> some View {
        let food = Supplies.kg(crew: people, days: t.travelDays)
        let fill = food / Supplies.holdKg
        let barColor: Color = fill <= 0.8 ? .green : fill <= 1 ? .yellow : .orange

        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: "fork.knife")
                    .font(.system(size: isPhone ? 15 : 21))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(width: isPhone ? 22 : 30)
                Text("Food for the flight")
                    .font(AppFont.regular(isPhone ? 14 : 20))
                    .foregroundColor(.white.opacity(0.8))
                Spacer(minLength: 8)
                Text(verbatim: "\(Supplies.weight(food)) / \(Supplies.weight(Supplies.holdKg))")
                    .font(AppFont.bold(isPhone ? 14 : 20))
                    .foregroundColor(barColor)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Palette.card)
                    Capsule().fill(barColor)
                        .frame(width: max(6, geo.size.width * min(fill, 1)))
                }
            }
            .frame(height: 8)
            .environment(\.layoutDirection, .leftToRight)
            .animation(.easeInOut(duration: 0.25), value: fill)

            Group {
                if fill > 1 {
                    Text("Too much for the hold! Pick a faster route or a smaller crew.")
                        .foregroundColor(.orange)
                } else {
                    Text("\(people) people × \(MissionFormat.duration(t.travelDays)) × 1.7 kg a day")
                        .foregroundColor(Palette.secondaryText)
                }
            }
            .font(AppFont.regular(isPhone ? 12 : 17))
            .fixedSize(horizontal: false, vertical: true)

            if let trip {
                Text("Whole round trip: \(Supplies.weight(Supplies.kg(crew: people, days: trip.totalDays))) of food")
                    .font(AppFont.regular(isPhone ? 12 : 17))
                    .foregroundColor(Palette.secondaryText)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .accessibilityElement(children: .combine)
    }
}
