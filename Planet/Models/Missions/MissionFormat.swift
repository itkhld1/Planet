//
//  MissionFormat.swift
//  Planet
//
//

import Foundation

/// Number formats shared by Mission Builder, Mission Control and the share card.
enum MissionFormat {
    /// Days under ~2 months read as days, under ~2 years as months, then years.
    static func duration(_ days: Double) -> String {
        if days < 60 {
            return String(format: String(localized: "%@ days", bundle: Bundle.appLanguage), MetricFormat.plain(days, decimals: 0))
        }
        if days < 730 {
            return String(format: String(localized: "%@ months", bundle: Bundle.appLanguage), MetricFormat.plain(days / 30.44, decimals: 1))
        }
        return String(format: String(localized: "%@ years", bundle: Bundle.appLanguage), MetricFormat.plain(days / 365.25, decimals: 1))
    }

    static func deltaV(_ kmPerSecond: Double) -> String {
        String(format: String(localized: "%@ km/s", bundle: Bundle.appLanguage), MetricFormat.plain(kmPerSecond, decimals: 1))
    }

    /// Radio delay: seconds, then minutes, then hours.
    static func signalDelay(_ seconds: Double) -> String {
        if seconds < 90 {
            return String(format: String(localized: "%@ seconds", bundle: Bundle.appLanguage), MetricFormat.plain(seconds, decimals: 0))
        }
        if seconds < 90 * 60 {
            return String(format: String(localized: "%@ minutes", bundle: Bundle.appLanguage), MetricFormat.plain(seconds / 60, decimals: 0))
        }
        return String(format: String(localized: "%@ hours", bundle: Bundle.appLanguage), MetricFormat.plain(seconds / 3_600, decimals: 1))
    }
}
