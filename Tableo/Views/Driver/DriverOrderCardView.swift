//
//  DriverOrderCardView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Eine Lieferung im Fahrer-Bereich. Die Buttons kommen von außen,
/// weil sie bei "Abholbereit" und "Meine Tour" verschieden sind
struct DriverOrderCardView<Actions: View>: View {
    let order: FireOrder
    // Platz in der Tour, nil = keine Nummer
    var position: Int?
    @ViewBuilder let actions: () -> Actions

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                if let position {
                    Text("\(position)")
                        .font(AppFont.labelLarge)
                        .foregroundColor(AppColors.onPrimary)
                        .frame(width: 28, height: 28)
                        .background(AppColors.primary)
                        .clipShape(Circle())
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(order.customerDisplayName)
                        .font(AppFont.titleMedium)
                    Group {
                        if let address = order.deliveryAddress {
                            Text(address)
                        } else {
                            Text("Keine Adresse")
                        }
                    }
                    .font(AppFont.bodyMedium)
                    .foregroundColor(AppColors.onSurfaceVariant)
                }
                .padding(.leading, position != nil ? 10 : 0)
                .frame(maxWidth: .infinity, alignment: .leading)

                StatusBadgeView(status: order.status)
                    .padding(.leading, 8)
            }

            Text(order.itemsText)
                .font(AppFont.bodySmall)
                .foregroundColor(AppColors.onSurfaceVariant)

            // wichtig für den Fahrer: muss er noch kassieren?
            Text("\(order.totalPrice.euro) · \(order.paymentMethod.title)")
                .font(AppFont.titleSmall)
                .foregroundColor(AppColors.primary)

            HStack(spacing: 8) {
                actions()
            }
            .padding(.top, 6)
        }
        .padding(16)
        .cardStyle()
    }
}

#Preview {
    DriverOrderCardView(order: FireOrder(
        restaurantId: "1", restaurantName: "Shisha Lounge", userId: nil, customerName: "Ali",
        orderType: .delivery, tableNumber: nil, pickupTime: nil, deliveryAddress: "Hauptstraße 1, 10115 Berlin", deliveryLocation: nil,
        paymentMethod: .bar, items: [OrderItem(menuItemId: "1", name: "Doppelapfel", pricePerItem: 13.5, quantity: 2)]
    ), position: 1) {
        Button("Annehmen") {}
            .buttonStyle(PrimaryButtonStyle())
    }
    .padding()
}
