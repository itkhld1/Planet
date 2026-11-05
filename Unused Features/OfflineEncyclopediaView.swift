// OfflineEncyclopediaView.swift
// Feature 4: Offline planetary encyclopedia placeholder implementation

import SwiftUI
import SQLite3

/// Simple wrapper around a bundled, compressed SQLite database that stores planet entries.
/// In a full implementation the DB would be shipped as a .zip (or pre‑compressed) file and
/// expanded on first launch, then queried with full‑text search.
struct OfflineEncyclopediaView: View {
    @State private var searchText: String = ""
    @State private var results: [PlanetEntry] = []

    var body: some View {
        VStack {
            TextField("Search planets...", text: $searchText, onCommit: performSearch)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            List(results) { entry in
                VStack(alignment: .leading) {
                    Text(entry.name).font(.headline)
                    Text(entry.summary).font(.subheadline).foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Encyclopedia")
    }

    private func performSearch() {
        // Placeholder: return static data. Replace with real SQLite FTS query.
        let sample = [
            PlanetEntry(name: "Mars", summary: "The Red Planet, fourth from the Sun.")
        ]
        results = searchText.isEmpty ? [] : sample.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
}

struct PlanetEntry: Identifiable {
    let id = UUID()
    let name: String
    let summary: String
}

struct OfflineEncyclopediaView_Previews: PreviewProvider {
    static var previews: some View {
        OfflineEncyclopediaView()
    }
}
