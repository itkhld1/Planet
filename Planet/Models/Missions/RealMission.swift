//
//  RealMission.swift
//  Planet
//
//

import Foundation

/// Real spacecraft that made the same trip, for scale. Times are launch to
/// arrival (orbit insertion, landing or closest flyby).
struct RealMission: Identifiable {
    let name: String
    let year: Int
    let days: Double
    var id: String { name }

    private static let byRoute: [String: [RealMission]] = [
        "Earth→Mercury": [RealMission(name: "MESSENGER", year: 2004, days: 2_418),
                          RealMission(name: "BepiColombo", year: 2018, days: 2_600)],
        "Earth→Venus": [RealMission(name: "Venus Express", year: 2005, days: 153),
                        RealMission(name: "Magellan", year: 1989, days: 462)],
        "Earth→Mars": [RealMission(name: "Perseverance", year: 2020, days: 203),
                       RealMission(name: "Curiosity", year: 2011, days: 254),
                       RealMission(name: "InSight", year: 2018, days: 205)],
        "Earth→Jupiter": [RealMission(name: "Juno", year: 2011, days: 1_795),
                          RealMission(name: "Galileo", year: 1989, days: 2_242)],
        "Earth→Saturn": [RealMission(name: "Cassini", year: 1997, days: 2_451),
                         RealMission(name: "Voyager 1", year: 1977, days: 1_168)],
        "Earth→Uranus": [RealMission(name: "Voyager 2", year: 1977, days: 3_079)],
        "Earth→Neptune": [RealMission(name: "Voyager 2", year: 1977, days: 4_389)]
    ]

    static func missions(from origin: String, to target: String) -> [RealMission] {
        byRoute["\(origin)→\(target)"] ?? []
    }
}
