//
//  AppFeature.swift
//  Planet
//
//  The features reachable from the Explore tab, and how
//  each one opens.
//

import SwiftUI

enum AppFeature: String, CaseIterable, Identifiable {
    case spaceWeather
    case missionBuilder
    case encyclopedia
    case compare
    case simulation
    case quiz
    case missionControl
    case weight
    case age

    var id: String { rawValue }

    /// The cards the Explore tab groups features into.
    enum Section: String, CaseIterable, Identifiable {
        case learn, live, play

        var id: String { rawValue }

        var title: LocalizedStringKey {
            switch self {
            case .learn: return "Learn"
            case .live: return "Live from space"
            case .play: return "Play"
            }
        }

        var icon: String {
            switch self {
            case .learn: return "book.fill"
            case .live: return "antenna.radiowaves.left.and.right"
            case .play: return "gamecontroller.fill"
            }
        }

        var features: [AppFeature] {
            AppFeature.allCases.filter { $0.section == self }
        }
    }

    var section: Section {
        switch self {
        case .encyclopedia, .compare, .simulation: return .learn
        case .spaceWeather, .missionBuilder: return .live
        case .quiz, .missionControl, .weight, .age: return .play
        }
    }

    var title: LocalizedStringKey {
        switch self {
        case .spaceWeather: return "Space Weather"
        case .missionBuilder: return "Mission Builder"
        case .encyclopedia: return "Encyclopedia"
        case .compare: return "Compare Planets"
        case .quiz: return "Quiz"
        case .missionControl: return "Mission Control"
        case .weight: return "Weight Calculator"
        case .age: return "Age Calculator"
        case .simulation: return "3D Planets"
        }
    }

    var subtitle: LocalizedStringKey {
        switch self {
        case .spaceWeather: return "Live solar wind and aurora outlook"
        case .missionBuilder: return "How long would it take to fly there?"
        case .encyclopedia: return "Planets, moons and the Sun, searchable"
        case .compare: return "Two worlds side by side, to scale"
        case .quiz: return "Ten questions, fresh every round"
        case .missionControl: return "Plan real missions and earn stars"
        case .weight: return "What you'd weigh on other worlds"
        case .age: return "Your age on different planetary orbits"
        case .simulation: return "Spin every planet in 3D"
        }
    }

    var icon: String {
        switch self {
        case .spaceWeather: return "sun.max.trianglebadge.exclamationmark.fill"
        case .missionBuilder: return "paperplane.fill"
        case .encyclopedia: return "book.closed.fill"
        case .compare: return "arrow.left.and.right.square.fill"
        case .quiz: return "brain.head.profile"
        case .missionControl: return "flag.checkered"
        case .weight: return "scalemass.fill"
        case .age: return "birthday.cake.fill"
        case .simulation: return "rotate.3d"
        }
    }

    var gradient: [Color] {
        switch self {
        case .spaceWeather: return [.orange, .red]
        case .missionBuilder: return [.blue, Palette.accent]
        case .encyclopedia: return [.green, .teal]
        case .compare: return [.purple, .pink]
        case .quiz: return [.indigo, .purple]
        case .missionControl: return [.orange, .pink]
        case .weight: return [.teal, .blue]
        case .age: return [.yellow, .orange]
        case .simulation: return [.pink, .orange]
        }
    }

    /// Screens that bring their own NavigationStack are presented as sheets;
    /// pushing them would nest one stack inside another.
    var presentsAsSheet: Bool {
        switch self {
        case .encyclopedia: return true
        default: return false
        }
    }

    @ViewBuilder
    var destination: some View {
        switch self {
        case .spaceWeather: SpaceWeatherFeedView()
        case .missionBuilder: MissionBuilderView()
        case .encyclopedia: PlanetListView()
        case .compare: ComparePlanetsView()
        case .quiz: QuizView()
        case .missionControl: MissionChallengesView()
        case .weight: PlanetWeightCalculatorView()
        case .age: PlanetAgeCalculatorView()
        case .simulation:
            SimulationView()
                .navigationTitle("3D Planets")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

/// Opens a feature the right way for it — pushed, or as a sheet. Must sit
/// inside a NavigationStack.
struct FeatureButton<Label: View>: View {
    let feature: AppFeature
    @ViewBuilder let label: () -> Label
    @State private var showSheet = false

    var body: some View {
        Group {
            if feature.presentsAsSheet {
                Button {
                    playHaptic(.light)
                    showSheet = true
                } label: { label() }
                .sheet(isPresented: $showSheet) {
                    feature.destination
                        .appLanguageEnvironment()
                        .presentationDragIndicator(.visible)
                }
            } else {
                NavigationLink {
                    feature.destination
                } label: { label() }
            }
        }
        .buttonStyle(.plain)
    }
}
