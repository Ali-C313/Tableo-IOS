//
//  CategoryTileView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Kachel für die Küchen oben auf der Startseite, z.B. "Burger" mit passendem Bild.
/// Ohne Bild steht der Anfangsbuchstabe drin
struct CategoryTileView: View {
    let label: String
    let selected: Bool
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            VStack(spacing: 6) {
                ZStack {
                    if let imageName = label.cuisineImageName {
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                    } else {
                        Text(label.prefix(1).uppercased())
                            .font(AppFont.display(size: 22, weight: 700))
                            .foregroundColor(AppColors.primary)
                    }
                }
                .frame(width: 64, height: 64)
                .background(selected ? AppColors.primary.opacity(0.18) : AppColors.surfaceContainer)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(selected ? AppColors.primary : .clear, lineWidth: 2)
                )

                Text(label)
                    .font(AppFont.text(size: 12, weight: selected ? 600 : 400))
                    .foregroundColor(selected ? AppColors.primary : AppColors.onSurfaceVariant)
                    .lineLimit(1)
            }
            .padding(4)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack {
        CategoryTileView(label: "Burger", selected: true, onClick: {})
        CategoryTileView(label: "Vegan", selected: false, onClick: {})
    }
}
