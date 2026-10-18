//
//  MyOrderCardView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Eine Bestellung in "Meine Bestellungen"
struct MyOrderCardView: View {
    let order: FireOrder
    var onReorder: () -> Void = {}
    var onTrack: () -> Void = {}
    var onCancel: () -> Void = {}
    var onOpen: () -> Void = {}

    @State private var showCancelAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Button(action: onOpen) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(order.restaurantName)
                            .font(AppFont.titleMedium)
                            .foregroundColor(AppColors.onSurface)
                        Spacer()
                        StatusBadgeView(status: order.status, doneLabel: "Abgeschlossen")
                    }
                    Text("\(order.orderNumber) · \(order.createdAt.dateTimeText)")
                        .font(AppFont.labelSmall)
                        .foregroundColor(AppColors.onSurfaceVariant)
                    Text(order.orderTypeText)
                        .font(AppFont.bodySmall)
                        .foregroundColor(AppColors.primary)
                    Text(order.itemsText)
                        .font(AppFont.bodySmall)
                        .foregroundColor(AppColors.onSurfaceVariant)
                    Text(order.totalPrice.euro)
                        .font(AppFont.titleMedium)
                        .foregroundColor(AppColors.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            // Live-Tracking nur bei laufenden Lieferungen
            if order.orderType == .delivery && !order.status.isDone {
                Button("Live verfolgen", action: onTrack)
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.top, 6)
            }

            Button("Erneut bestellen", action: onReorder)
                .buttonStyle(OutlineButtonStyle())
                .padding(.top, 6)

            // nur solange das Restaurant noch nicht angefangen hat
            if order.status == .offen {
                Button("Bestellung stornieren") {
                    showCancelAlert = true
                }
                .font(AppFont.labelLarge)
                .foregroundColor(AppColors.error)
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
            }
        }
        .padding(16)
        .cardStyle()
        .cancelOrderAlert(
            isPresented: $showCancelAlert,
            message: Text("Das geht nur, solange \(order.restaurantName) noch nicht mit der Zubereitung angefangen hat."),
            onConfirm: onCancel
        )
    }
}

#Preview {
    MyOrderCardView(order: FireOrder(
        restaurantId: "1", restaurantName: "Shisha Lounge", userId: "u1", customerName: "Ali",
        orderType: .delivery, tableNumber: nil, pickupTime: nil, deliveryAddress: "Hauptstraße 1", deliveryLocation: nil,
        paymentMethod: .paypal, items: [OrderItem(menuItemId: "1", name: "Doppelapfel", pricePerItem: 13.5, quantity: 1)]
    ))
    .padding()
}
