// SolarSystemSimulationView.swift
// Feature 3: Live solar‑system simulation placeholder implementation

import SwiftUI
import Combine

/// Simple data model for a planetary body in the simulation.
struct CelestialBody: Identifiable {
    let id = UUID()
    let name: String
    let orbitalPeriod: Double // in Earth days
    let distanceFromSun: Double // arbitrary units for UI scaling
    var angle: Double = 0 // current angle on orbit (radians)
}

/// ViewModel that updates orbital positions over time.
final class SolarSystemViewModel: ObservableObject {
    @Published var bodies: [CelestialBody] = []
    private var timer: AnyCancellable?
    private let timeStep: Double = 0.05 // simulation speed factor

    init() {
        // Placeholder bodies – replace with real data later.
        bodies = [
            CelestialBody(name: "Mercury", orbitalPeriod: 88, distanceFromSun: 0.4),
            CelestialBody(name: "Venus",   orbitalPeriod: 225, distanceFromSun: 0.7),
            CelestialBody(name: "Earth",   orbitalPeriod: 365, distanceFromSun: 1.0),
            CelestialBody(name: "Mars",    orbitalPeriod: 687, distanceFromSun: 1.5)
        ]
        startSimulation()
    }

    private func startSimulation() {
        timer = Timer.publish(every: 0.016, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.updatePositions() }
    }

    private func updatePositions() {
        for i in bodies.indices {
            let period = bodies[i].orbitalPeriod
            // Increment angle proportionally to simulation speed.
            bodies[i].angle += (2 * .pi / period) * timeStep
            bodies[i].angle.formTruncatingRemainder(dividingBy: 2 * .pi)
        }
    }
}

struct SolarSystemSimulationView: View {
    @StateObject private var viewModel = SolarSystemViewModel()
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                // Sun placeholder
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 40, height: 40)
                    .position(x: proxy.size.width/2, y: proxy.size.height/2)
                // Planets
                ForEach(viewModel.bodies) { body in
                    Circle()
                        .fill(Color.blue.opacity(0.7))
                        .frame(width: 20, height: 20)
                        .position(x: proxy.size.width/2 + CGFloat(body.distanceFromSun * 60) * cos(body.angle),
                                  y: proxy.size.height/2 + CGFloat(body.distanceFromSun * 60) * sin(body.angle))
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .padding()
    }
}

struct SolarSystemSimulationView_Previews: PreviewProvider {
    static var previews: some View {
        SolarSystemSimulationView()
    }
}
