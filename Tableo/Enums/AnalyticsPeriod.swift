//
//  AnalyticsPeriod.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Zeiträume für die Statistik
enum AnalyticsPeriod: CaseIterable {
    case last24h
    case last3d
    case lastMonth
    case last6Months

    var title: String {
        switch self {
        case .last24h: return String(localized: "24 Stunden", bundle: .appLanguage)
        case .last3d: return String(localized: "3 Tage", bundle: .appLanguage)
        case .lastMonth: return String(localized: "1 Monat", bundle: .appLanguage)
        case .last6Months: return String(localized: "6 Monate", bundle: .appLanguage)
        }
    }

    var millis: Int64 {
        switch self {
        case .last24h: return 24 * 60 * 60 * 1000
        case .last3d: return 3 * 24 * 60 * 60 * 1000
        case .lastMonth: return 30 * 24 * 60 * 60 * 1000
        case .last6Months: return 182 * 24 * 60 * 60 * 1000
        }
    }

    /// Anzahl der Balken
    var bucketCount: Int {
        self == .last3d ? 3 : 6
    }

    /// Beschriftung unter den Balken
    var labelFormat: String {
        switch self {
        case .last24h: return "HH:mm"
        case .last3d: return "EEE"
        case .lastMonth: return "dd.MM."
        case .last6Months: return "MMM"
        }
    }
}
