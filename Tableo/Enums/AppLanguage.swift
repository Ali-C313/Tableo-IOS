//
//  AppLanguage.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Sprachen der App. Der Name steht immer in der Sprache selbst
enum AppLanguage: String, CaseIterable {
    // leer = Sprache vom iPhone
    case system = ""
    case deutsch = "de"
    case english = "en"
    case tuerkce = "tr"
    case arabic = "ar"
    case espanol = "es"
    case francais = "fr"
    case italiano = "it"
    case polski = "pl"
    case russian = "ru"
    case ukrainian = "uk"

    var title: String {
        switch self {
        case .system: return String(localized: "Wie am Handy", bundle: .appLanguage)
        case .deutsch: return "Deutsch"
        case .english: return "English"
        case .tuerkce: return "Türkçe"
        case .arabic: return "العربية"
        case .espanol: return "Español"
        case .francais: return "Français"
        case .italiano: return "Italiano"
        case .polski: return "Polski"
        case .russian: return "Русский"
        case .ukrainian: return "Українська"
        }
    }

    /// Arabisch liest sich von rechts nach links
    var isRightToLeft: Bool { self == .arabic }

    var locale: Locale {
        self == .system ? .current : Locale(identifier: rawValue)
    }
}
