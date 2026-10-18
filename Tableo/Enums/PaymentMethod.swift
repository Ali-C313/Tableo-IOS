//
//  PaymentMethod.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Es wird noch nicht echt bezahlt, die Auswahl wird nur mit der Bestellung gespeichert
enum PaymentMethod: String, Codable, CaseIterable {
    case bar = "BAR"
    case paypal = "PAYPAL"
    case applePay = "APPLE_PAY"
    case googlePay = "GOOGLE_PAY"
    case klarna = "KLARNA"
    case kreditkarte = "KREDITKARTE"

    var title: String {
        switch self {
        case .bar: return String(localized: "Barzahlung", bundle: .appLanguage)
        case .paypal: return "PayPal"
        case .applePay: return "Apple Pay"
        case .googlePay: return "Google Pay"
        case .klarna: return "Klarna"
        case .kreditkarte: return String(localized: "Kreditkarte", bundle: .appLanguage)
        }
    }
}
