// SmartRecommendationEngine.swift
// Feature 3: Smart‑recommendation engine placeholder implementation

import Foundation
import Combine
import CoreML
import SwiftUI

/// Simple data structure representing a recommendation.
struct Recommendation: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let imageName: String // asset name for UI display
}

/// A very lightweight on‑device recommendation engine.
/// In a real app you would replace the stub model with a trained CoreML model that
/// takes user context (usage history, calendar events, location) and outputs scores.
final class SmartRecommendationEngine {
    // Placeholder: a static list of possible recommendations.
    private let allRecommendations: [Recommendation] = [
        Recommendation(title: "Explore Mars", subtitle: "AR view available", imageName: "mars_thumb"),
        Recommendation(title: "Space Weather Alerts", subtitle: "Stay up‑to‑date", imageName: "weather_thumb"),
        Recommendation(title: "Night‑mode UI", subtitle: "Try the planet‑themed skin", imageName: "night_thumb"),
        Recommendation(title: "Mission Builder", subtitle: "Plan a launch", imageName: "mission_thumb")
    ]

    /// Simulated inference – returns a shuffled subset of recommendations.
    func recommend(forUserID userID: String) -> [Recommendation] {
        // In a real implementation you would feed user features into a CoreML model.
        // Here we just randomize order to mimic a personalized response.
        return allRecommendations.shuffled().prefix(3).map { $0 }
    }
}

/// ViewModel that drives the UI.
final class RecommendationViewModel: ObservableObject {
    @Published var recommendations: [Recommendation] = []
    private let engine = SmartRecommendationEngine()
    private let userID: String = UUID().uuidString // placeholder unique identifier

    init() {
        loadRecommendations()
    }

    func loadRecommendations() {
        // Simulate a short delay as if a model were loading.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.recommendations = self.engine.recommend(forUserID: self.userID)
        }
    }
}

struct SmartRecommendationView: View {
    @StateObject private var viewModel = RecommendationViewModel()
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(viewModel.recommendations) { rec in
                    VStack {
                        Image(rec.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .cornerRadius(8)
                        Text(rec.title).font(.headline)
                        Text(rec.subtitle).font(.caption).foregroundColor(.secondary)
                    }
                    .frame(width: 120)
                }
            }
            .padding()
        }
        .onAppear {
            viewModel.loadRecommendations()
        }
    }
}

struct SmartRecommendationView_Previews: PreviewProvider {
    static var previews: some View {
        SmartRecommendationView()
    }
}
