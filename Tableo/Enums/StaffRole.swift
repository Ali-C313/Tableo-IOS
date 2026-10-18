//
//  StaffRole.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Aufgabe im Restaurant, vergibt die Leitung im Team
enum StaffRole: String, Codable, CaseIterable {
    case ohne = "OHNE"
    case leitung = "LEITUNG"
    case kellner = "KELLNER"
    case koch = "KOCH"
    case kuechenhilfe = "KUECHENHILFE"
    case bar = "BAR"
    case lieferant = "LIEFERANT"

    var title: String {
        switch self {
        case .ohne: return String(localized: "Ohne Rolle", bundle: .appLanguage)
        case .leitung: return String(localized: "Leitung", bundle: .appLanguage)
        case .kellner: return String(localized: "Kellner", bundle: .appLanguage)
        case .koch: return String(localized: "Koch", bundle: .appLanguage)
        case .kuechenhilfe: return String(localized: "Küchenhilfe", bundle: .appLanguage)
        case .bar: return String(localized: "Bar", bundle: .appLanguage)
        case .lieferant: return String(localized: "Lieferant", bundle: .appLanguage)
        }
    }
}
