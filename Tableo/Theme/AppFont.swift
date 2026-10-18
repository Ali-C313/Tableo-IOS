//
//  AppFont.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI
import UIKit
import CoreText

/// Fraunces für Überschriften und Preise, Manrope für normalen Text und Buttons
enum AppFont {
    static let headlineLarge = display(size: 32, weight: 600)
    static let headlineMedium = display(size: 28, weight: 600)
    static let headlineSmall = display(size: 26, weight: 600)
    static let titleLarge = display(size: 22, weight: 600)
    static let titleMedium = display(size: 18, weight: 500)
    static let titleSmall = text(size: 14, weight: 600)
    static let bodyLarge = text(size: 16, weight: 400)
    static let bodyMedium = text(size: 14, weight: 400)
    static let bodySmall = text(size: 12, weight: 400)
    static let labelLarge = text(size: 14, weight: 600)
    static let labelMedium = text(size: 12, weight: 600)
    static let labelSmall = text(size: 11, weight: 500)

    // Namen der Schriften in Resources/Fonts
    private static let displayName = "Fraunces-9ptBlack"
    private static let textName = "Manrope-ExtraLight"

    static func display(size: CGFloat, weight: CGFloat) -> Font {
        variable(displayName, size: size, weight: weight)
    }

    static func text(size: CGFloat, weight: CGFloat) -> Font {
        variable(textName, size: size, weight: weight)
    }

    private static func variable(_ name: String, size: CGFloat, weight: CGFloat) -> Font {
        guard let base = UIFont(name: name, size: size) else {
            return .system(size: size)
        }
        // 'wght' = 0x77676874, 'opsz' = 0x6F70737A
        let variations: [UInt32: CGFloat] = [0x7767_6874: weight, 0x6F70_737A: size]
        let key = UIFontDescriptor.AttributeName(rawValue: kCTFontVariationAttribute as String)
        let descriptor = base.fontDescriptor.addingAttributes([key: variations])
        return Font(UIFont(descriptor: descriptor, size: size) as CTFont)
    }
}
