//
//  MenuItemRowView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Eine Zeile in der Speisekarte. Hier wird nur hinzugefügt, die Menge stellt man im Warenkorb ein
struct MenuItemRowView: View {
    let menuItem: FireMenuItem
    // nur zur Anzeige
    var cartQuantity = 0
    // Preis in Fremdwährung, z.B. "$14.07"
    var convertedPrice: String?
    var onAdd: () -> Void = {}

    var body: some View {
        HStack(spacing: 12) {
            Group {
                if menuItem.imageUrl.isEmpty {
                    ImagePlaceholderView()
                } else {
                    RemoteImageView(url: menuItem.imageUrl)
                }
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 2) {
                Text(menuItem.name)
                    .font(AppFont.titleMedium)
                Text(menuItem.description)
                    .font(AppFont.bodySmall)
                    .foregroundColor(AppColors.onSurfaceVariant)

                if !menuItem.available {
                    Text("Nicht verfügbar")
                        .font(AppFont.labelMedium)
                        .foregroundColor(AppColors.error)
                        .padding(.top, 6)
                } else {
                    HStack(spacing: 6) {
                        Text(menuItem.price.euro)
                            .font(AppFont.titleMedium)
                            .foregroundColor(AppColors.primary)

                        if let convertedPrice {
                            Text("· ≈ \(convertedPrice)")
                                .font(AppFont.labelMedium)
                                .foregroundColor(AppColors.onSurfaceVariant)
                        } else if cartQuantity > 0 {
                            (Text(verbatim: "· ") + Text("\(cartQuantity) im Warenkorb"))
                                .font(AppFont.labelMedium)
                                .foregroundColor(AppColors.secondary)
                        }
                    }
                    .padding(.top, 6)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: onAdd) {
                Image(systemName: "cart.fill")
                    .font(.system(size: 15))
                    .foregroundColor(menuItem.available ? AppColors.onPrimary : AppColors.onSurfaceVariant)
                    .frame(width: 38, height: 38)
                    .background(menuItem.available ? AppColors.primary : AppColors.surfaceVariant)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .disabled(!menuItem.available)
            .accessibilityLabel("Zum Warenkorb hinzufügen")
        }
        .padding(12)
        .cardStyle()
        .opacity(menuItem.available ? 1 : 0.5)
    }
}

#Preview {
    MenuItemRowView(
        menuItem: FireMenuItem(restaurantId: "1", name: "Doppelapfel", description: "Klassiker", price: 13.5, category: "Shisha"),
        cartQuantity: 2
    )
    .padding()
}
