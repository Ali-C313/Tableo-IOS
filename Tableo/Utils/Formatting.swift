//
//  Formatting.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

extension Double {
    /// 13.5 -> "13,50 €"
    var euro: String {
        String(format: "%.2f €", self).replacingOccurrences(of: ".", with: ",")
    }

    /// Preis in Fremdwährung, z.B. "$14.07"
    func foreignCurrency(_ code: String) -> String {
        let symbols = ["USD": "$", "GBP": "£", "TRY": "₺"]
        return (symbols[code] ?? code) + String(format: "%.2f", self)
    }
}

extension Int64 {
    /// Millisekunden -> "18.10.2026, 19:30"
    var dateTimeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy, HH:mm"
        return formatter.string(from: Date(timeIntervalSince1970: Double(self) / 1000))
    }
}

extension String {
    /// "Omar Haddad" -> "Omar", Kunden sehen vom Fahrer nur den Vornamen
    var firstName: String {
        components(separatedBy: " ").first ?? self
    }

    var isValidEmail: Bool {
        range(of: #"^[^@\s]+@[^@\s]+\.[^@\s]+$"#, options: .regularExpression) != nil
    }

    /// Bild aus den Assets zur Küche, z.B. "Burger" -> "cuisine_burger"
    var cuisineImageName: String? {
        switch lowercased().replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "") {
        case "burger": return "cuisine_burger"
        case "fastfood": return "cuisine_fastfood"
        case "kaffee", "café", "cafe", "coffee": return "cuisine_kaffee"
        case "frühstück", "fruehstueck", "brunch": return "cuisine_fruehstueck"
        case "shisha": return "cuisine_shisha"
        case "indisch": return "cuisine_indisch"
        case "getränke", "getraenke", "drinks": return "cuisine_getraenke"
        case "pizza": return "cuisine_pizza"
        case "pasta": return "cuisine_pasta"
        case "sushi": return "cuisine_sushi"
        case "asiatisch": return "cuisine_asiatisch"
        default: return nil
        }
    }
}

/// Aktuelle Zeit in Millisekunden, so speichert es auch die Android-App
func currentMillis() -> Int64 {
    Int64(Date().timeIntervalSince1970 * 1000)
}
