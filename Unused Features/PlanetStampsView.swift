// PlanetStampsView.swift
// Feature 6: Social "Planet Stamps" placeholder implementation

import SwiftUI

/// Simple representation of a stamp (could later be an NFT or image).
struct PlanetStamp: Identifiable {
    let id = UUID()
    let planetName: String
    let imageName: String // name of asset in the bundle
    let description: String
    var owned: Bool = false
}

struct PlanetStampsView: View {
    @State private var stamps: [PlanetStamp] = []

    var body: some View {
        VStack {
            Text("Planet Stamps Collection")
                .font(.title2)
                .padding()
            if stamps.isEmpty {
                Text("Discover planets to earn stamps.")
                    .foregroundColor(.secondary)
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))]) {
                        ForEach(stamps) { stamp in
                            VStack {
                                Image(stamp.imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 80)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(stamp.owned ? Color.green : Color.gray, lineWidth: 2)
                                    )
                                Text(stamp.planetName)
                                    .font(.caption)
                            }
                            .onTapGesture { toggleOwnership(stamp) }
                        }
                    }
                }
            }
        }
        .onAppear(perform: loadSampleStamps)
    }

    private func loadSampleStamps() {
        // Placeholder data – replace with real data fetched from a backend.
        stamps = [
            PlanetStamp(planetName: "Mars", imageName: "mars_stamp", description: "Red planet stamp"),
            PlanetStamp(planetName: "Saturn", imageName: "saturn_stamp", description: "Ringed giant stamp")
        ]
    }

    private func toggleOwnership(_ stamp: PlanetStamp) {
        if let index = stamps.firstIndex(where: { $0.id == stamp.id }) {
            stamps[index].owned.toggle()
        }
    }
}

struct PlanetStampsView_Previews: PreviewProvider {
    static var previews: some View {
        PlanetStampsView()
    }
}
