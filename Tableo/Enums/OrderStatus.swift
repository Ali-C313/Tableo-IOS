//
//  OrderStatus.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Status einer Bestellung, gleiche Werte wie in der Android-App.
/// Tisch/Abholung: OFFEN -> IN_ZUBEREITUNG -> FERTIG -> ERLEDIGT
/// Lieferung: OFFEN -> IN_ZUBEREITUNG -> FERTIG -> ABHOLBEREIT -> ANGENOMMEN -> UNTERWEGS -> ERLEDIGT
enum OrderStatus: String, Codable, CaseIterable {
    case offen = "OFFEN"
    case inZubereitung = "IN_ZUBEREITUNG"
    case fertig = "FERTIG"
    // Personal ist fertig, Lieferung wartet auf einen Fahrer
    case abholbereit = "ABHOLBEREIT"
    // Fahrer hat sie in seiner Tour, ist aber noch nicht losgefahren
    case angenommen = "ANGENOMMEN"
    case unterwegs = "UNTERWEGS"
    case erledigt = "ERLEDIGT"
    case storniert = "STORNIERT"
    // alter Status, damit alte Bestellungen weiter geladen werden
    case bezahlt = "BEZAHLT"

    /// Abgeschlossen, gehört ins Archiv
    var isDone: Bool {
        self == .erledigt || self == .bezahlt || self == .storniert
    }

    /// Personal darf stornieren, bis der Fahrer losgefahren ist
    var canRestaurantCancel: Bool {
        self != .unterwegs && !isDone
    }

    /// Lieferung liegt beim Fahrer
    var isWithDriver: Bool {
        self == .abholbereit || self == .angenommen || self == .unterwegs
    }
}
