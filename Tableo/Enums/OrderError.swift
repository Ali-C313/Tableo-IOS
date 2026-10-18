//
//  OrderError.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Fehler beim Stornieren
enum OrderError: LocalizedError {
    case alreadyOnTheWay
    case alreadyInPreparation

    var errorDescription: String? {
        switch self {
        case .alreadyOnTheWay:
            return String(localized: "Die Bestellung ist schon unterwegs und kann nicht mehr storniert werden", bundle: .appLanguage)
        case .alreadyInPreparation:
            return String(localized: "Die Bestellung wird schon zubereitet und kann nicht mehr storniert werden", bundle: .appLanguage)
        }
    }
}
