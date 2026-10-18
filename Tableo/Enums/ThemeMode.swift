//
//  ThemeMode.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Hell, Dunkel oder wie das iPhone
enum ThemeMode: String, CaseIterable {
    case system = "SYSTEM"
    case light = "LIGHT"
    case dark = "DARK"

    var title: String {
        switch self {
        case .system: return String(localized: "Standard", bundle: .appLanguage)
        case .light: return String(localized: "Hell", bundle: .appLanguage)
        case .dark: return String(localized: "Dunkel", bundle: .appLanguage)
        }
    }

    /// nil = wie das iPhone
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
