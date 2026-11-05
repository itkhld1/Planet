// TelescopeIntegrationView.swift
// Feature 7: Live telescope feed integration placeholder implementation

import SwiftUI
import Combine

/// Placeholder view that would display live images from a public telescope API (e.g., NASA APOD or ESO).
/// In a full implementation the view would fetch JSON metadata and image URLs, then show them.
struct TelescopeIntegrationView: View {
    @State private var imageUrl: URL?
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            if let url = imageUrl {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                    case .failure:
                        Image(systemName: "photo")
                            .foregroundColor(.secondary)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else if isLoading {
                ProgressView("Loading latest telescope image…")
            } else if let err = errorMessage {
                Text(err)
                    .foregroundColor(.red)
            } else {
                Text("No image loaded.")
            }
            Button("Refresh") { fetchLatestImage() }
                .padding(.top)
        }
        .onAppear { fetchLatestImage() }
        .padding()
    }

    private func fetchLatestImage() {
        // Placeholder: replace with real API call.
        isLoading = true
        errorMessage = nil
        // Simulate async network call with a short delay.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Example static image from NASA's public collection.
            self.imageUrl = URL(string: "https://apod.nasa.gov/apod/image/2309/M31_Hubble_960.jpg")
            self.isLoading = false
        }
    }
}

struct TelescopeIntegrationView_Previews: PreviewProvider {
    static var previews: some View {
        TelescopeIntegrationView()
    }
}
