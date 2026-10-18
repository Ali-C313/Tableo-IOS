//
//  OrderSummaryView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Bestellübersicht: geschätzte Zeit oben, darunter Art, Artikel und Summe
struct OrderSummaryView: View {
    let order: FireOrder

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Voraussichtlich fertig")
                .font(AppFont.labelMedium)
                .foregroundColor(AppColors.onSurfaceVariant)
            Text(order.estimatedTimeText)
                .font(AppFont.headlineMedium)
                .foregroundColor(AppColors.primary)
            Text(order.estimatedHint)
                .font(AppFont.bodySmall)
                .foregroundColor(AppColors.onSurfaceVariant)

            Divider().padding(.vertical, 16)

            OrderTypeTextView(order: order)
                .font(AppFont.titleMedium)
            Text("Bezahlart: \(order.paymentMethod.title)")
                .font(AppFont.bodySmall)
                .foregroundColor(AppColors.onSurfaceVariant)
                .padding(.top, 2)

            ForEach(order.items, id: \.menuItemId) { item in
                HStack(alignment: .top) {
                    Text("\(item.quantity)× \(item.name)")
                        .font(AppFont.bodyMedium)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(item.subtotal.euro)
                        .font(AppFont.bodyMedium)
                }
                .padding(.top, 8)
            }

            Divider().padding(.vertical, 16)

            HStack {
                Text("Gesamt")
                    .font(AppFont.titleMedium)
                Spacer()
                Text(order.totalPrice.euro)
                    .font(AppFont.titleMedium)
                    .foregroundColor(AppColors.primary)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle(color: AppColors.surface, shadow: false)
    }
}

/// "Tisch 7", "Abholung um 19:30 Uhr" oder "Lieferung an ..."
struct OrderTypeTextView: View {
    let order: FireOrder

    var body: some View {
        switch order.orderType {
        case .dineIn:
            Text("Tisch \(order.tableNumber.map(String.init) ?? "")")
        case .pickup:
            Text("Abholung um \(order.pickupTime ?? "") Uhr")
        case .delivery:
            Text("Lieferung an \(order.deliveryAddress ?? "")")
        }
    }
}

#Preview {
    OrderSummaryView(order: FireOrder(
        restaurantId: "1", restaurantName: "Shisha Lounge", userId: nil, customerName: "Ali",
        orderType: .dineIn, tableNumber: 7, pickupTime: nil, deliveryAddress: nil, deliveryLocation: nil,
        paymentMethod: .bar, items: [OrderItem(menuItemId: "1", name: "Doppelapfel", pricePerItem: 13.5, quantity: 2)]
    ))
    .padding()
}
