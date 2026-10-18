//
//  FilterChipView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Auswahl-Chip, ausgewählt in der Hauptfarbe
struct FilterChipView: View {
    let label: String
    let selected: Bool
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            HStack(spacing: 4) {
                if selected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .semibold))
                }
                Text(label)
                    .font(AppFont.labelLarge)
                    .lineLimit(1)
            }
            .foregroundColor(selected ? AppColors.onPrimary : AppColors.onSurfaceVariant)
            .padding(.horizontal, 12)
            .frame(height: 32)
            .background(selected ? AppColors.primary : .clear)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(selected ? .clear : AppColors.onSurfaceVariant.opacity(0.5))
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack {
        FilterChipView(label: "Alle", selected: true, onClick: {})
        FilterChipView(label: "Shisha-Bar", selected: false, onClick: {})
    }
}
