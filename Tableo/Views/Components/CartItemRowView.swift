//
//  CartItemRowView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Eine Zeile im Warenkorb mit Mengensteller
struct CartItemRowView: View {
    let orderItem: OrderItem
    let onIncrease: () -> Void
    let onDecrease: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(orderItem.name)
                    .font(AppFont.titleMedium)
                Text("\(orderItem.pricePerItem.euro) je Stück")
                    .font(AppFont.bodySmall)
                    .foregroundColor(AppColors.onSurfaceVariant)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 0) {
                stepperButton("−", action: onDecrease)
                Text("\(orderItem.quantity)")
                    .font(AppFont.titleMedium)
                    .frame(width: 28)
                stepperButton("+", action: onIncrease)
            }

            Text(orderItem.subtotal.euro)
                .font(AppFont.titleMedium)
                .foregroundColor(AppColors.primary)
                .frame(width: 72, alignment: .trailing)
                .padding(.leading, 12)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .padding(14)
        .cardStyle()
    }

    private func stepperButton(_ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(AppFont.titleMedium)
                .foregroundColor(AppColors.onSurface)
                .frame(width: 28, height: 28)
                .background(AppColors.surfaceVariant)
                .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CartItemRowView(
        orderItem: OrderItem(menuItemId: "1", name: "Doppelapfel", pricePerItem: 13.5, quantity: 2),
        onIncrease: {},
        onDecrease: {}
    )
    .padding()
}
