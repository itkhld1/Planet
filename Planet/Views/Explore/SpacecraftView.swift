//
//  SpacecraftView.swift
//  Planet
//
//  The player's own spacecraft and crew. A name, a colour and an icon make
//  it theirs — it's what flies in every orbit diagram — and the crew turn
//  "259 days" into "Sara will be 13 when she gets there".
//

import SwiftUI

// MARK: - Spacecraft

/// The looks a spacecraft can have. The player's choice is saved in
/// `ProgressStore`.
enum Spacecraft {
    static let colors: [Color] = [Palette.accent, .orange, .pink, .green, .yellow, .purple]

    /// Symbol, and the direction it points in at rest (screen degrees,
    /// clockwise from east) so it can be turned to face along the route.
    /// `nil` means it doesn't point anywhere and is never rotated.
    static let icons: [(symbol: String, pointsAt: Double?)] = [
        ("circle.fill", nil),
        ("location.north.fill", -90),
        ("paperplane.fill", -45),
        ("airplane", 0),
        ("star.fill", nil),
        ("sparkle", nil)
    ]

    static func color(_ index: Int) -> Color { colors[min(max(index, 0), colors.count - 1)] }
    static func icon(_ index: Int) -> (symbol: String, pointsAt: Double?) { icons[min(max(index, 0), icons.count - 1)] }

    /// The name to show: what the player typed, or a default.
    static func displayName(_ stored: String) -> String {
        let trimmed = stored.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? String(localized: "Explorer 1", bundle: Bundle.appLanguage) : trimmed
    }
}

// MARK: - Crew

struct CrewMember: Codable, Identifiable, Equatable {
    var id = UUID()
    var name: String
    var age: Double
}

enum Crew {
    static let maxCrewmates = 3
}

/// Food for the flight. NASA gives each space station astronaut about
/// 1.7 kg of food a day, packaging included; the hold size is a game rule.
enum Supplies {
    static let kgPerPersonPerDay = 1.7
    static let holdKg = 1_500.0

    static func kg(crew: Int, days: Double) -> Double {
        Double(crew) * days * kgPerPersonPerDay
    }

    static func weight(_ kg: Double) -> String {
        kg >= 1_000
            ? String(format: String(localized: "%@ tonnes", bundle: Bundle.appLanguage), MetricFormat.plain(kg / 1_000, decimals: 1))
            : String(format: String(localized: "%@ kg", bundle: Bundle.appLanguage), MetricFormat.plain(kg, decimals: 0))
    }
}

// MARK: - Badge

/// The spacecraft's icon on a glowing disc, as used around the app.
struct SpacecraftBadge: View {
    let colorIndex: Int
    let iconIndex: Int
    var size: CGFloat = 44

    var body: some View {
        // A negative colour index draws a neutral, unselected badge.
        let color = colorIndex < 0 ? Color.white.opacity(0.3) : Spacecraft.color(colorIndex)
        let icon = Spacecraft.icon(iconIndex)
        Image(systemName: icon.symbol)
            .font(.system(size: size * 0.45, weight: .bold))
            .foregroundColor(.white)
            // Pointing icons are shown heading up and to the right.
            .rotationEffect(.degrees(icon.pointsAt.map { -45 - $0 } ?? 0))
            .frame(width: size, height: size)
            .background(Circle().fill(color.opacity(0.85)))
            .shadow(color: color.opacity(0.6), radius: size * 0.25)
            .accessibilityHidden(true)
    }
}

// MARK: - Editor

struct SpacecraftView: View {
    @Bindable private var progress = ProgressStore.shared
    @AppStorage(SettingsKey.ageOnEarth) private var ageOnEarth = ""

    private var isPhone: Bool { deviceType() == "iPhone" }

    private var name: String { progress.spacecraftName }
    private var colorIndex: Int { progress.spacecraftColor }
    private var iconIndex: Int { progress.spacecraftIcon }
    private var crew: [CrewMember] { progress.crew }

    var body: some View {
        ZStack {
            AppGradientBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    preview
                    nameCard
                    looksCard
                    crewCard
                }
                .padding()
                .frame(maxWidth: 700)
                .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .appNavigationStyle("Spacecraft & Crew")
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { hideKeyboard() }
            }
        }
    }

    // MARK: Preview

    private var preview: some View {
        VStack(spacing: 12) {
            SpacecraftBadge(colorIndex: colorIndex, iconIndex: iconIndex, size: isPhone ? 96 : 130)
                .animation(.spring(duration: 0.3), value: colorIndex)
                .animation(.spring(duration: 0.3), value: iconIndex)
            Text(Spacecraft.displayName(name))
                .font(AppFont.bold(isPhone ? 22 : 30))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
        .accessibilityElement(children: .combine)
    }

    // MARK: Name

    private var nameCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Name")
                .font(AppFont.regular(isPhone ? 14 : 20))
                .foregroundColor(.white)
            TextField("", text: $progress.spacecraftName, prompt: Text(Spacecraft.displayName("")).foregroundColor(Palette.secondaryText))
                .font(AppFont.bold(isPhone ? 17 : 24))
                .foregroundColor(.white)
                .submitLabel(.done)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Palette.card)
                .cornerRadius(14)
                .onChange(of: name) { _, new in
                    if new.count > 24 { progress.spacecraftName = String(new.prefix(24)) }
                }
        }
        .padding(16)
        .appCard()
    }

    // MARK: Colour & icon

    private var looksCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Colour")
                .font(AppFont.regular(isPhone ? 14 : 20))
                .foregroundColor(.white)
            HStack(spacing: 12) {
                ForEach(Spacecraft.colors.indices, id: \.self) { i in
                    Button {
                        playHaptic(.light)
                        progress.spacecraftColor = i
                    } label: {
                        Circle()
                            .fill(Spacecraft.colors[i])
                            .frame(width: isPhone ? 36 : 48, height: isPhone ? 36 : 48)
                            .overlay(Circle().stroke(Color.white, lineWidth: colorIndex == i ? 3 : 0).padding(-4))
                    }
                    .accessibilityLabel(Text("Colour \(i + 1)"))
                    .accessibilityAddTraits(colorIndex == i ? [.isButton, .isSelected] : .isButton)
                }
            }
            .frame(maxWidth: .infinity)

            Divider().overlay(Color.white.opacity(0.15))

            Text("Icon")
                .font(AppFont.regular(isPhone ? 14 : 20))
                .foregroundColor(.white)
            HStack(spacing: 12) {
                ForEach(Spacecraft.icons.indices, id: \.self) { i in
                    Button {
                        playHaptic(.light)
                        progress.spacecraftIcon = i
                    } label: {
                        SpacecraftBadge(colorIndex: iconIndex == i ? colorIndex : -1, iconIndex: i,
                                        size: isPhone ? 40 : 54)
                            .opacity(iconIndex == i ? 1 : 0.6)
                    }
                    .accessibilityLabel(Text("Icon \(i + 1)"))
                    .accessibilityAddTraits(iconIndex == i ? [.isButton, .isSelected] : .isButton)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(16)
        .appCard()
        .environment(\.layoutDirection, .leftToRight)
    }

    // MARK: Crew

    private var crewCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Crew", systemImage: "person.3.fill")
                .font(AppFont.bold(isPhone ? 17 : 24))
                .foregroundColor(.white)

            // You — your age comes from the Age Calculator.
            HStack(spacing: 12) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: isPhone ? 22 : 30))
                    .foregroundColor(Palette.accent)
                Text("You")
                    .font(AppFont.regular(isPhone ? 15 : 21))
                    .foregroundColor(.white)
                Spacer()
                if let age = MetricFormat.parse(ageOnEarth), age > 0 {
                    Text(String(format: String(localized: "%@ years", bundle: Bundle.appLanguage),
                                MetricFormat.plain(age, decimals: 0)))
                        .font(AppFont.bold(isPhone ? 15 : 21))
                        .foregroundColor(.white)
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
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(Color.white.opacity(0.12))
            .cornerRadius(14)

            ForEach(crew) { member in
                crewRow(member)
            }

            if crew.count < Crew.maxCrewmates {
                Button {
                    playHaptic(.light)
                    progress.crew.append(CrewMember(name: "", age: 30))
                } label: {
                    Label("Add a crewmate", systemImage: "plus.circle.fill")
                        .font(AppFont.bold(isPhone ? 15 : 21))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Palette.card)
                        .cornerRadius(14)
                }
            }

            Text("Everyone on board needs about 1.7 kg of food a day, and you'll see how old they are when you arrive.")
                .font(AppFont.regular(isPhone ? 12 : 17))
                .foregroundColor(Palette.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .appCard()
    }

    private func crewRow(_ member: CrewMember) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "person.fill")
                .font(.system(size: isPhone ? 16 : 22))
                .foregroundColor(.white.opacity(0.7))
                .frame(width: isPhone ? 22 : 30)
            TextField("", text: binding(member, \.name),
                      prompt: Text("Crewmate's name").foregroundColor(Palette.secondaryText))
                .font(AppFont.regular(isPhone ? 15 : 21))
                .foregroundColor(.white)
                .submitLabel(.done)
            Stepper(value: binding(member, \.age), in: 1...99, step: 1) {
                Text(String(format: String(localized: "%@ years", bundle: Bundle.appLanguage),
                            MetricFormat.plain(member.age, decimals: 0)))
                    .font(AppFont.bold(isPhone ? 14 : 20))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .fixedSize()
            }
            .fixedSize()
            Button {
                playHaptic(.light)
                progress.crew.removeAll { $0.id == member.id }
            } label: {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red.opacity(0.8))
            }
            .accessibilityLabel(Text("Remove crewmate"))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.white.opacity(0.12))
        .cornerRadius(14)
    }

    /// Edits one field of one crewmate and saves the whole crew.
    private func binding<T>(_ member: CrewMember, _ field: WritableKeyPath<CrewMember, T>) -> Binding<T> {
        Binding(
            get: { (crew.first { $0.id == member.id } ?? member)[keyPath: field] },
            set: { value in
                if let i = progress.crew.firstIndex(where: { $0.id == member.id }) {
                    progress.crew[i][keyPath: field] = value
                }
            }
        )
    }
}

#Preview {
    NavigationStack { SpacecraftView() }
}
