//
//  SpaceWeatherParsingTests.swift
//  PlanetTests
//
//  Fixtures are real responses from services.swpc.noaa.gov (November 2026).
//

import Foundation
import Testing
@testable import Planet

@Suite("NOAA space weather parsing")
struct SpaceWeatherParsingTests {
    private func json(_ text: String) -> Any {
        try! JSONSerialization.jsonObject(with: Data(text.utf8))
    }

    private var wind: Any { json(#"[{"proton_speed": 316, "time_tag": "2026-11-05T20:00:00Z"}]"#) }
    private var mag: Any { json(#"[{"bt": 4, "bz_gsm": -4, "time_tag": "2026-11-05T20:00:00Z"}]"#) }
    private var flux: Any { json(#"[{"flux":111,"time_tag":"2026-11-04T20:00:00"}]"#) }
    private var kp: Any {
        json(#"[{"time_tag":"2026-10-29T00:00:00","Kp":1.67,"a_running":6,"station_count":8},{"time_tag":"2026-10-29T03:00:00","Kp":"2.33","a_running":9,"station_count":8}]"#)
    }
    private var scales: Any {
        json(#"{"0": {"R": {"Scale": "0"}, "S": {"Scale": "1"}, "G": {"Scale": 2}}, "1": {"R": {"Scale": null}}}"#)
    }

    @Test func readsEveryField() throws {
        let report = try #require(SpaceWeatherService.report(wind: wind, magneticField: mag, flux: flux,
                                                             kp: kp, scales: scales))
        #expect(report.solarWindSpeed == 316)
        #expect(report.magneticFieldBz == -4)
        #expect(report.solarFlux == 111)
        // Newest row wins, and string numbers are accepted.
        #expect(report.kpIndex == 2.33)
        #expect(report.radioScale == 0)
        #expect(report.radiationScale == 1)
        #expect(report.geomagneticScale == 2)
    }

    @Test func oneFailedEndpointDoesNotBlankTheReport() throws {
        let report = try #require(SpaceWeatherService.report(wind: nil, magneticField: nil, flux: nil,
                                                             kp: kp, scales: nil))
        #expect(report.kpIndex == 2.33)
        #expect(report.solarWindSpeed == nil)
    }

    @Test func everyEndpointFailingIsAnError() {
        #expect(SpaceWeatherService.report(wind: nil, magneticField: nil, flux: nil, kp: nil, scales: nil) == nil)
    }

    @Test func unexpectedShapesAreIgnored() throws {
        let report = try #require(SpaceWeatherService.report(wind: json(#"{"oops": true}"#), magneticField: nil,
                                                             flux: nil, kp: json("[]"), scales: json("[]")))
        #expect(report.solarWindSpeed == nil)
        #expect(report.kpIndex == nil)
        #expect(report.geomagneticScale == nil)
    }
}
