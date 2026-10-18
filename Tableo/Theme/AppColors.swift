//
//  AppColors.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI
import UIKit

// Kupfer als Hauptfarbe
private let copper40 = UIColor(hex: 0xB5651D)
private let copper80 = UIColor(hex: 0xE8A768)
private let espresso10 = UIColor(hex: 0x1B1712)
private let espresso20 = UIColor(hex: 0x2A241C)
private let espresso30 = UIColor(hex: 0x382E22)
private let sage40 = UIColor(hex: 0x6B7A5E)
private let sage80 = UIColor(hex: 0xC3D0B4)
private let cream95 = UIColor(hex: 0xF7F1E7)
private let cream90 = UIColor(hex: 0xEFE6D4)
private let mutedCream = UIColor(hex: 0xC9B79C)
private let mutedEspresso = UIColor(hex: 0x6B6155)
private let errorRed = UIColor(hex: 0xBA1A1A)
// Karten etwas heller als der Hintergrund
private let espressoContainer = UIColor(hex: 0x241E17)
private let creamContainer = UIColor(hex: 0xF2EAD9)

/// Farben der App, jeweils für hell und dunkel
enum AppColors {
    static let primary = dynamic(light: copper40, dark: copper80)
    static let onPrimary = dynamic(light: cream95, dark: espresso10)
    static let secondary = dynamic(light: sage40, dark: sage80)
    static let tertiary = dynamic(light: UIColor(hex: 0x7D5260), dark: UIColor(hex: 0xEFB8C8))
    static let background = dynamic(light: cream95, dark: espresso10)
    static let onBackground = dynamic(light: espresso10, dark: cream95)
    static let surface = dynamic(light: .white, dark: espresso20)
    static let onSurface = dynamic(light: espresso10, dark: cream95)
    static let surfaceVariant = dynamic(light: cream90, dark: espresso30)
    static let surfaceContainer = dynamic(light: creamContainer, dark: espressoContainer)
    static let onSurfaceVariant = dynamic(light: mutedEspresso, dark: mutedCream)
    static let outline = dynamic(light: mutedEspresso.withAlphaComponent(0.25), dark: mutedCream.withAlphaComponent(0.3))
    static let error = Color(uiColor: errorRed)
    static let onError = Color.white
    /// Grün für "Im Dienst"
    static let onDutyGreen = Color(uiColor: UIColor(hex: 0x2E7D32))
    /// Dunkle Schrift auf der weißen Kapsel oben auf der Startseite
    static let espresso = Color(uiColor: espresso10)

    private static func dynamic(light: UIColor, dark: UIColor) -> Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? dark : light
        })
    }
}

extension UIColor {
    convenience init(hex: UInt32) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}
