//
//  Localization.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

extension Bundle {
    /// Sprachpaket der Sprache, die in den Einstellungen gewählt ist.
    /// Für Texte, die nicht direkt in einer View stehen, z.B. String(localized: "Gast", bundle: .appLanguage)
    static var appLanguage: Bundle {
        let code = UserDefaults.standard.string(forKey: "app_language") ?? ""
        guard !code.isEmpty,
              let path = Bundle.main.path(forResource: code, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return .main
        }
        return bundle
    }
}
