//
//  AppStyle.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Gefüllter Button in der Hauptfarbe
struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFont.labelLarge)
            .foregroundColor(isEnabled ? AppColors.onPrimary : AppColors.onSurface.opacity(0.4))
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, minHeight: 44)
            .background(isEnabled ? AppColors.primary : AppColors.onSurface.opacity(0.12))
            .cornerRadius(12)
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

/// Umrandeter Button für Neben-Aktionen
struct OutlineButtonStyle: ButtonStyle {
    var color: Color = AppColors.primary
    var fillWidth = true
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFont.labelLarge)
            .foregroundColor(isEnabled ? color : AppColors.onSurface.opacity(0.4))
            .padding(.horizontal, 16)
            .frame(maxWidth: fillWidth ? .infinity : nil, minHeight: 44)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.onSurfaceVariant.opacity(0.5)))
            .contentShape(Rectangle())
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

extension View {
    /// Karte mit leicht abgesetztem Hintergrund
    func cardStyle(color: Color = AppColors.surfaceContainer, radius: CGFloat = 20, shadow: Bool = true) -> some View {
        self
            .background(color)
            .cornerRadius(radius)
            .shadow(color: .black.opacity(shadow ? 0.08 : 0), radius: 3, y: 1)
    }

    /// Eingabefeld mit Rahmen, rot bei Fehler
    func fieldStyle(isError: Bool = false) -> some View {
        self
            .font(AppFont.bodyLarge)
            .padding(.horizontal, 14)
            .frame(minHeight: 50)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isError ? AppColors.error : AppColors.onSurfaceVariant.opacity(0.5))
            )
    }

    /// Hintergrund der Screens
    func screenBackground() -> some View {
        self.background(AppColors.background.ignoresSafeArea())
    }
}
