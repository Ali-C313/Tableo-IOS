//
//  StaffOrderCardView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Eine Bestellung im Dashboard: Kunde, Art, Positionen, Summe und Status-Buttons.
/// Liegt eine Lieferung schon beim Fahrer, gibt es keine Buttons mehr, nur den Stand
struct StaffOrderCardView: View {
    let order: FireOrder
    let onAdvance: () -> Void
    // ins Archiv, bei Lieferung an die Fahrer
    let onDone: () -> Void
    let onCancel: () -> Void

    @State private var showCancelAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(order.orderTypeText)
                    .font(AppFont.titleMedium)
                Spacer()
                StatusBadgeView(status: order.status)
            }

            Text("\(order.orderNumber) · \(order.customerDisplayName) · \(order.createdAt.dateTimeText)")
                .font(AppFont.labelMedium)
                .foregroundColor(AppColors.onSurfaceVariant)

            if order.orderType == .delivery, let address = order.deliveryAddress, !address.isEmpty {
                Text(address)
                    .font(AppFont.bodyMedium)
            }

            Text(order.itemsText)
                .font(AppFont.bodyMedium)
                .foregroundColor(AppColors.onSurfaceVariant)

            HStack {
                Text(order.totalPrice.euro)
                    .font(AppFont.titleMedium)
                    .foregroundColor(AppColors.primary)
                Spacer()
                Text(order.paymentMethod.title)
                    .font(AppFont.labelMedium)
                    .foregroundColor(AppColors.onSurfaceVariant)
            }

            if order.status.isWithDriver {
                // das Personal sieht nur noch den Stand
                driverText
                    .font(AppFont.bodyMedium)
                    .foregroundColor(AppColors.tertiary)
                    .padding(.top, 4)
            } else {
                HStack(spacing: 10) {
                    if order.status == .offen || order.status == .inZubereitung {
                        Button(action: onAdvance) {
                            if order.status == .offen {
                                Text("Zubereitung starten")
                            } else {
                                Text("Zubereitung fertig")
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle())

                        Button("Erledigt", action: onDone)
                            .buttonStyle(OutlineButtonStyle())
                    } else {
                        // fertig, jetzt nur noch abschließen
                        Button(action: onDone) {
                            if order.orderType == .delivery {
                                Text("Erledigt, an Fahrer geben")
                            } else {
                                Text("Erledigt")
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                }
                .padding(.top, 4)
            }

            // geht nur, bis die Bestellung das Restaurant verlassen hat
            if order.status.canRestaurantCancel {
                Button("Stornieren") {
                    showCancelAlert = true
                }
                .font(AppFont.labelLarge)
                .foregroundColor(AppColors.error)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.top, 4)
            }
        }
        .padding(16)
        .cardStyle()
        .cancelOrderAlert(
            isPresented: $showCancelAlert,
            message: Text("Die Bestellung von \(order.customerDisplayName) wird storniert. Der Kunde bekommt eine Nachricht."),
            onConfirm: onCancel
        )
    }

    @ViewBuilder
    private var driverText: some View {
        switch order.status {
        case .angenommen:
            Text("\(order.driverName ?? "") holt die Bestellung ab")
        case .unterwegs:
            Text("\(order.driverName ?? "") ist unterwegs")
        default:
            Text("Wartet auf einen Fahrer")
        }
    }
}

#Preview {
    StaffOrderCardView(
        order: FireOrder(
            restaurantId: "1", restaurantName: "Shisha Lounge", userId: nil, customerName: "Ali",
            orderType: .dineIn, tableNumber: 7, pickupTime: nil, deliveryAddress: nil, deliveryLocation: nil,
            paymentMethod: .bar, items: [OrderItem(menuItemId: "1", name: "Doppelapfel", pricePerItem: 13.5, quantity: 1)]
        ),
        onAdvance: {}, onDone: {}, onCancel: {}
    )
    .padding()
}
