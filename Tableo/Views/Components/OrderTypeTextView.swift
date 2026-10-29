//
//  OrderTypeTextView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

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
    OrderTypeTextView(order: FireOrder(
        restaurantId: "1", restaurantName: "Shisha Lounge", userId: nil, customerName: "Ali",
        orderType: .delivery, tableNumber: nil, pickupTime: nil, deliveryAddress: "Hauptstraße 1, 10115 Berlin", deliveryLocation: nil,
        paymentMethod: .bar, items: [OrderItem(menuItemId: "1", name: "Doppelapfel", pricePerItem: 13.5, quantity: 2)]
    ))
}
