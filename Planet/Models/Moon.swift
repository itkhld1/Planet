//
//  Moon.swift
//  Planet
//

import SwiftUI

/// A notable moon. The facts here mirror what `PlanetDetails` already says in
/// prose — this just makes them browsable instead of buried in a wall of text.
struct Moon: Identifiable {
    let id = UUID()
    let name: String
    /// The planet this moon orbits.
    let planet: String
    /// One-line hook shown in the list.
    let tagline: String
    /// Stored as a number, not "5,150 km": a pre-formatted English string can't
    /// be translated and can't render Persian digits.
    let diameterKm: Double
    let description: String
    let facts: [String]
    /// There are no moon images in the asset catalog, so each moon gets a
    /// tint to tell them apart at a glance.
    let tint: Color

    // The stored strings above are always English — `name` is the lookup key
    // used by `moons(of:)` and the display-name catalog, so it must not change.
    // These are what the UI should read.

    private var translation: MoonText? { MoonTranslations.text(for: name) }

    var localizedTagline: String { translation?.tagline ?? tagline }
    var localizedDiameter: String { MetricFormat.km(diameterKm) }
    var localizedDescription: String { translation?.description ?? description }
    var localizedFacts: [String] { translation?.facts ?? facts }

    static let all: [Moon] = [
        // Earth
        Moon(name: "The Moon", planet: "Earth",
             tagline: "Earth's only natural satellite",
             diameterKm: 3475,
             description: "Earth's only natural satellite and the fifth-largest moon in the Solar System. It stabilises Earth's axial tilt and drives the ocean tides.",
             facts: ["Fifth-largest moon in the Solar System",
                     "Stabilises Earth's 23.5° axial tilt",
                     "Its gravity causes the tides",
                     "The only place beyond Earth humans have walked"],
             tint: Color(red: 0.80, green: 0.80, blue: 0.82)),

        // Mars
        Moon(name: "Phobos", planet: "Mars",
             tagline: "Spiralling in toward Mars",
             diameterKm: 22.5,
             description: "The larger of Mars' two moons. Phobos is an irregularly shaped object that is slowly spiralling inward toward Mars.",
             facts: ["Expected to crash into Mars or break into a ring in about 50 million years",
                     "Irregularly shaped rather than round",
                     "Thought to be a captured asteroid"],
             tint: Color(red: 0.55, green: 0.45, blue: 0.40)),

        Moon(name: "Deimos", planet: "Mars",
             tagline: "The smaller, more distant twin",
             diameterKm: 12.4,
             description: "The smaller of Mars' two moons, Deimos orbits at a greater distance than Phobos and is also irregularly shaped.",
             facts: ["Orbits farther out than Phobos",
                     "Also believed to be a captured asteroid from the asteroid belt"],
             tint: Color(red: 0.60, green: 0.52, blue: 0.45)),

        // Jupiter
        Moon(name: "Io", planet: "Jupiter",
             tagline: "The most volcanic world we know",
             diameterKm: 3643,
             description: "The most volcanically active body in the Solar System, covered in lava flows and sulfur. Jupiter's immense tidal forces keep its interior molten.",
             facts: ["The most volcanically active body in the Solar System",
                     "Covered in lava flows and sulfur",
                     "One of the four Galilean moons discovered in 1610",
                     "Its volcanism helps power Jupiter's auroras"],
             tint: Color(red: 0.93, green: 0.82, blue: 0.35)),

        Moon(name: "Europa", planet: "Jupiter",
             tagline: "An ocean under the ice",
             diameterKm: 3122,
             description: "A frozen moon with a subsurface ocean beneath its icy crust, making it a prime candidate in the search for extraterrestrial life.",
             facts: ["Hides a global ocean beneath its ice shell",
                     "A leading candidate in the search for life",
                     "One of the four Galilean moons",
                     "Its surface is among the smoothest in the Solar System"],
             tint: Color(red: 0.72, green: 0.82, blue: 0.88)),

        Moon(name: "Ganymede", planet: "Jupiter",
             tagline: "The largest moon in the Solar System",
             diameterKm: 5268,
             description: "The largest moon in the Solar System — bigger than the planet Mercury — and the only moon known to have its own magnetic field.",
             facts: ["Larger than the planet Mercury",
                     "The only moon known to generate its own magnetic field",
                     "One of the four Galilean moons"],
             tint: Color(red: 0.70, green: 0.63, blue: 0.55)),

        Moon(name: "Callisto", planet: "Jupiter",
             tagline: "One of the oldest surfaces known",
             diameterKm: 4821,
             description: "Heavily cratered and considered to have one of the oldest surfaces in the Solar System — a record of billions of years of impacts.",
             facts: ["One of the most heavily cratered objects in the Solar System",
                     "Its surface is among the oldest known",
                     "One of the four Galilean moons"],
             tint: Color(red: 0.45, green: 0.42, blue: 0.45)),

        // Saturn
        Moon(name: "Titan", planet: "Saturn",
             tagline: "Rivers and lakes of liquid methane",
             diameterKm: 5150,
             description: "Saturn's largest moon and the second-largest in the Solar System — larger than Mercury. Titan has a thick nitrogen atmosphere with clouds of methane and ethane, and liquid lakes on its surface.",
             facts: ["The second-largest moon in the Solar System",
                     "The only other body known to have stable liquids on its surface",
                     "Has a thick atmosphere made mostly of nitrogen",
                     "The Huygens probe landed here in 2005"],
             tint: Color(red: 0.90, green: 0.66, blue: 0.25)),

        Moon(name: "Enceladus", planet: "Saturn",
             tagline: "Geysers spraying water into space",
             diameterKm: 504,
             description: "A small, icy moon with a subsurface ocean beneath its ice shell. Enceladus has geysers that spew water vapour and organic molecules from its southern pole.",
             facts: ["Shoots geysers of water vapour from its south pole",
                     "Hides a subsurface ocean",
                     "Its plumes contain organic molecules",
                     "A prime candidate in the search for life"],
             tint: Color(red: 0.85, green: 0.92, blue: 0.95)),

        Moon(name: "Mimas", planet: "Saturn",
             tagline: "The \"Death Star\" moon",
             diameterKm: 396,
             description: "Sometimes called the \"Death Star moon\" because a single enormous crater gives it a striking resemblance to the Star Wars battle station.",
             facts: ["Its huge Herschel crater dominates one side",
                     "One of the smallest bodies rounded by its own gravity"],
             tint: Color(red: 0.66, green: 0.68, blue: 0.70)),

        Moon(name: "Rhea", planet: "Saturn",
             tagline: "Saturn's icy second-largest moon",
             diameterKm: 1527,
             description: "The second-largest moon of Saturn, covered with ice and heavily cratered.",
             facts: ["Saturn's second-largest moon",
                     "Made largely of water ice",
                     "Heavily cratered surface"],
             tint: Color(red: 0.78, green: 0.80, blue: 0.83)),

        Moon(name: "Iapetus", planet: "Saturn",
             tagline: "Two-toned: one side dark, one bright",
             diameterKm: 1469,
             description: "Known for its striking two-tone colouration, with one hemisphere much darker than the other.",
             facts: ["One side is far darker than the other",
                     "Has a strange equatorial ridge, giving it a walnut shape"],
             tint: Color(red: 0.50, green: 0.46, blue: 0.42)),

        // Uranus
        Moon(name: "Titania", planet: "Uranus",
             tagline: "The largest moon of Uranus",
             diameterKm: 1578,
             description: "The largest of Uranus's moons. It is heavily cratered and shows evidence of geological activity such as faults and valleys.",
             facts: ["The largest of Uranus's 27 known moons",
                     "Shows faults and valleys from past geological activity",
                     "Named after a character from Shakespeare"],
             tint: Color(red: 0.62, green: 0.66, blue: 0.72)),

        Moon(name: "Oberon", planet: "Uranus",
             tagline: "Ancient and heavily cratered",
             diameterKm: 1523,
             description: "The second-largest moon of Uranus, known for its heavily cratered surface.",
             facts: ["Uranus's second-largest moon",
                     "Its many craters point to a very old surface",
                     "Named after a character from Shakespeare"],
             tint: Color(red: 0.55, green: 0.52, blue: 0.56)),

        Moon(name: "Ariel", planet: "Uranus",
             tagline: "The brightest of Uranus's moons",
             diameterKm: 1158,
             description: "Ariel has fewer craters than the other major moons and shows signs of recent geological activity, such as valleys and smooth plains.",
             facts: ["Fewer craters suggest a younger, resurfaced world",
                     "Has valleys and smooth plains",
                     "The brightest of Uranus's moons"],
             tint: Color(red: 0.74, green: 0.78, blue: 0.80)),

        Moon(name: "Umbriel", planet: "Uranus",
             tagline: "The darkest of the major moons",
             diameterKm: 1169,
             description: "The darkest of Uranus's major moons, with an old, heavily cratered surface.",
             facts: ["The darkest of Uranus's major moons",
                     "Its old surface is covered in craters"],
             tint: Color(red: 0.38, green: 0.38, blue: 0.42)),

        Moon(name: "Miranda", planet: "Uranus",
             tagline: "The strangest surface in the Solar System",
             diameterKm: 471,
             description: "The smallest and most geologically active of Uranus's major moons. Miranda has huge canyons and cliffs, making it one of the strangest-looking moons in the Solar System.",
             facts: ["Has cliffs up to 20 km high — the tallest known",
                     "Its jumbled surface looks stitched together",
                     "The smallest of Uranus's five major moons"],
             tint: Color(red: 0.60, green: 0.64, blue: 0.68)),

        // Neptune
        Moon(name: "Triton", planet: "Neptune",
             tagline: "A captured world orbiting backwards",
             diameterKm: 2707,
             description: "Neptune's largest moon. Triton orbits in a retrograde direction — opposite the planet's rotation — suggesting it was captured from the Kuiper Belt. It has a thin atmosphere and geysers that erupt nitrogen gas.",
             facts: ["Orbits backwards, opposite to Neptune's spin",
                     "Likely a captured Kuiper Belt object",
                     "Has geysers that erupt nitrogen gas",
                     "One of the few geologically active moons"],
             tint: Color(red: 0.72, green: 0.76, blue: 0.86)),

        Moon(name: "Proteus", planet: "Neptune",
             tagline: "Lumpy and heavily cratered",
             diameterKm: 420,
             description: "Neptune's second-largest moon, with an irregular shape and a heavily cratered surface.",
             facts: ["Neptune's second-largest moon",
                     "Irregularly shaped rather than round",
                     "About as large as a body can get without gravity rounding it"],
             tint: Color(red: 0.48, green: 0.50, blue: 0.55)),

        Moon(name: "Nereid", planet: "Neptune",
             tagline: "One of the most eccentric orbits known",
             diameterKm: 340,
             description: "Known for its highly eccentric orbit — one of the most elliptical of any moon in the Solar System.",
             facts: ["Its orbit is one of the most elliptical of any moon",
                     "Its distance from Neptune varies enormously"],
             tint: Color(red: 0.58, green: 0.60, blue: 0.66))
    ]

    /// The moons of a given planet, in the order listed above.
    static func moons(of planet: String) -> [Moon] {
        all.filter { $0.planet == planet }
    }
}
