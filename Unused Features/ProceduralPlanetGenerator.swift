// ProceduralPlanetGenerator.swift
// Feature 2: Procedural planet generation placeholder

import Foundation
import SwiftUI

/// Simple model representing a procedurally generated planet.
struct ProceduralPlanet {
    let name: String
    let radius: Double // in km
    let atmosphere: String
    let terrainDescription: String
}

/// Generator that creates random planet data. Replace with a proper physics‑based generator later.
class ProceduralPlanetGenerator {
    private let planetNames = ["Xenon", "Aurelia", "Rigil", "Zyra", "Tethys", "Erebus"]
    private let atmospheres = ["None", "Thin (CO₂)", "Breathable (N₂/O₂)", "Thick (Methane)", "Toxic (Sulfur)" ]
    private let terrains = ["Rocky", "Oceanic", "Desert", "Ice", "Lava", "Forest"]

    func generate(count: Int = 1) -> [ProceduralPlanet] {
        var planets: [ProceduralPlanet] = []
        for _ in 0..<count {
            let name = planetNames.randomElement() ?? "Planet"
            let radius = Double.random(in: 2000...70000)
            let atmosphere = atmospheres.randomElement() ?? "None"
            let terrain = terrains.randomElement() ?? "Rocky"
            let planet = ProceduralPlanet(name: name,
                                          radius: radius,
                                          atmosphere: atmosphere,
                                          terrainDescription: "A \(terrain) world with \(atmosphere) atmosphere.")
            planets.append(planet)
        }
        return planets
    }
}

// Example usage (to be moved into a view later):
// let generator = ProceduralPlanetGenerator()
// let newPlanets = generator.generate(count: 5)
