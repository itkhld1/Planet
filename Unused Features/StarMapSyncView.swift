// StarMapSyncView.swift
// Feature 10: Cross‑device Star‑Map sync placeholder implementation

import SwiftUI
import Combine
import CloudKit

/// Simple sync manager that uses a public CloudKit database to store the currently selected planet.
/// In a full implementation you would sync the entire UI state (dashboard layout, favorites, etc.).
final class StarMapSyncManager: ObservableObject {
    @Published var selectedPlanet: String = "" {
        didSet { saveSelection() }
    }
    private let container = CKContainer.default()
    private let database = CKContainer.default().publicCloudDatabase
    private let recordID = CKRecord.ID(recordName: "StarMapSyncRecord")

    init() {
        fetchSelection()
    }

    private func fetchSelection() {
        database.fetch(withRecordID: recordID) { record, error in
            if let record = record, let planet = record["planet"] as? String {
                DispatchQueue.main.async { self.selectedPlanet = planet }
            } else {
                // No record exists yet – create a default one.
                self.createDefaultRecord()
            }
        }
    }

    private func createDefaultRecord() {
        let record = CKRecord(recordType: "StarMapSync", recordID: recordID)
        record["planet"] = "Earth" as CKRecordValue
        database.save(record) { _, _ in }
    }

    private func saveSelection() {
        let record = CKRecord(recordType: "StarMapSync", recordID: recordID)
        record["planet"] = selectedPlanet as CKRecordValue
        database.save(record) { _, _ in }
    }
}

struct StarMapSyncView: View {
    @StateObject private var syncManager = StarMapSyncManager()
    var body: some View {
        VStack {
            Text("Current Planet (synced across devices):")
                .font(.headline)
            Text(syncManager.selectedPlanet.isEmpty ? "None" : syncManager.selectedPlanet)
                .font(.title)
                .padding()
            Button("Select Random Planet") {
                let planets = ["Mercury", "Venus", "Earth", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune"]
                syncManager.selectedPlanet = planets.randomElement() ?? "Earth"
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
}

struct StarMapSyncView_Previews: PreviewProvider {
    static var previews: some View {
        StarMapSyncView()
    }
}
