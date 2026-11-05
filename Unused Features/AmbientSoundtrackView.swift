// AmbientSoundtrackView.swift
// Feature 9: Dynamic ambient soundtrack placeholder implementation

import SwiftUI
import AVFoundation

/// A very simple ambient soundtrack generator that picks a short audio file
/// based on the selected planet's type. In a full implementation you would
/// generate procedural music (e.g., using AudioKit) that reacts to planet
/// characteristics such as size, atmosphere, and distance.
struct AmbientSoundtrackView: View {
    @State private var player: AVAudioPlayer?
    @State private var isPlaying = false
    // Placeholder mapping – in a real app this would be data‑driven.
    private let planetSoundMap: [String: String] = [
        "Mercury": "metallic",
        "Venus": "humm",
        "Earth": "ambient",
        "Mars": "drone",
        "Jupiter": "deep",
        "Saturn": "ring"
    ]

    var body: some View {
        VStack {
            Text(isPlaying ? "Playing soundtrack…" : "Tap to start soundtrack")
                .padding()
            Button(isPlaying ? "Stop" : "Play") {
                isPlaying ? stopSound() : playSound(for: "Earth") // default placeholder planet
            }
            .padding()
            .background(isPlaying ? Color.red : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
    }

    private func playSound(for planet: String) {
        guard let soundName = planetSoundMap[planet] ?? planetSoundMap["Earth"] else { return }
        // Expect a short .mp3 file bundled in the app (e.g., "ambient.mp3").
        if let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") {
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.numberOfLoops = -1 // loop indefinitely
                player?.play()
                isPlaying = true
            } catch {
                print("Failed to play sound: \(error)")
            }
        }
    }

    private func stopSound() {
        player?.stop()
        isPlaying = false
    }
}

struct AmbientSoundtrackView_Previews: PreviewProvider {
    static var previews: some View {
        AmbientSoundtrackView()
    }
}
