//
//  DropdownView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Button mit Aufklapp-Menü für Auswahl-Listen, z.B. Währung oder Tischnummer
struct DropdownView<T: Hashable>: View {
    // nil, solange nichts gewählt ist
    let selected: T?
    let options: [T]
    let placeholder: String
    var fillWidth = false
    // macht aus einem Eintrag den Text, z.B. 5 -> "Tisch 5"
    var optionLabel: (T) -> String = { "\($0)" }
    let onSelected: (T) -> Void

    var body: some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button(optionLabel(option)) {
                    onSelected(option)
                }
            }
        } label: {
            HStack(spacing: 6) {
                Text(selected.map(optionLabel) ?? placeholder)
                    .lineLimit(1)
                if fillWidth {
                    Spacer(minLength: 0)
                }
                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .semibold))
            }
            .font(AppFont.labelLarge)
            .foregroundColor(AppColors.primary)
            .padding(.horizontal, 16)
            .frame(maxWidth: fillWidth ? .infinity : nil, minHeight: 40)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppColors.onSurfaceVariant.opacity(0.5))
            )
        }
        .accessibilityLabel(placeholder)
    }
}

#Preview {
    DropdownView(selected: "EUR", options: ["EUR", "USD", "GBP"], placeholder: "Währung wählen") { _ in }
}
