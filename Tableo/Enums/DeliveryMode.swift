//
//  DeliveryMode.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Schalter oben auf der Startseite, wie bei Lieferando
enum DeliveryMode: String, CaseIterable {
    case abholung = "ABHOLUNG"
    case lieferung = "LIEFERUNG"

    var title: String {
        switch self {
        case .abholung: return String(localized: "Abholung", bundle: .appLanguage)
        case .lieferung: return String(localized: "Lieferung", bundle: .appLanguage)
        }
    }
}
