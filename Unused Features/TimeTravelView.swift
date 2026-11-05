// TimeTravelView.swift
// Feature 5: "Time-travel" view placeholder implementation

import SwiftUI
import Combine

/// Represents a snapshot of a planet at a given historic epoch.
struct PlanetEpochSnapshot: Identifiable {
    let id = UUID()
    let planetName: String
    let epochLabel: String   // e.g., "200 Ma", "4.5 Ga"
    let imageName: String    // asset name for the rendered image
    let description: String
}

final class TimeTravelViewModel: ObservableObject {
    @Published var selectedPlanet: String = "Mars"
    @Published var selectedEpoch: String = "Present"
    @Published var snapshots: [PlanetEpochSnapshot] = []

    init() {
        loadSnapshots()
    }

    func loadSnapshots() {
        // Placeholder static data – replace with real scientific simulation assets.
        snapshots = [
            PlanetEpochSnapshot(planetName: "Mars", epochLabel: "Present", imageName: "mars_present", description: "Current red surface with thin atmosphere."),
            PlanetEpochSnapshot(planetName: "Mars", epochLabel: "3 Ga", imageName: "mars_3ga", description: "Early Mars with possible liquid water.")
        ]
    }

    var filteredSnapshots: [PlanetEpochSnapshot] {
        snapshots.filter { $0.planetName == selectedPlanet && ($0.epochLabel == selectedEpoch || selectedEpoch == "All") }
    }
}

struct TimeTravelView: View {
    @StateObject private var viewModel = TimeTravelViewModel()
    let planets = ["Mercury", "Venus", "Earth", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune"]
    let epochs = ["Present", "3 Ga", "1 Ga", "500 Ma", "All"]

    var body: some View {
        VStack {
            // Planet picker
            Picker("Planet", selection: $viewModel.selectedPlanet) {
                ForEach(planets, id: \.self) { Text($0) }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            // Epoch picker
            Picker("Epoch", selection: $viewModel.selectedEpoch) {
                ForEach(epochs, id: \.self) { Text($0) }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            // Gallery of snapshots
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.filteredSnapshots) { snap in
                        VStack(alignment: .leading) {
                            Text("\(snap.planetName) – \(snap.epochLabel)")
                                .font(.headline)
                            Image(snap.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                            Text(snap.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationTitle("Time Travel")
    }
}

struct TimeTravelView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView { TimeTravelView() }
    }
}
