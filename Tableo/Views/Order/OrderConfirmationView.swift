//
//  OrderConfirmationView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Bestätigung nach dem Absenden. Die Bestellung kommt aus cartViewModel.lastOrder,
/// weil der Warenkorb dann schon leer ist
struct OrderConfirmationView: View {

    let restaurantName: String

    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var navigationViewModel: NavigationViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Text("✓")
                    .font(AppFont.headlineLarge)
                    .foregroundColor(AppColors.onPrimary)
                    .frame(width: 72, height: 72)
                    .background(AppColors.primary)
                    .clipShape(Circle())
                    .padding(.top, 24)

                Text("Bestellung gesendet!")
                    .font(AppFont.headlineSmall)
                    .padding(.top, 20)

                Text("Danke für deine Bestellung bei \(restaurantName). Das Personal wurde benachrichtigt.")
                    .font(AppFont.bodyMedium)
                    .foregroundColor(AppColors.onSurfaceVariant)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)

                if let order = cartViewModel.lastOrder {
                    OrderSummaryView(order: order)
                        .padding(.top, 24)

                    if order.orderType == .delivery && !order.id.isEmpty {
                        NavigationLink(value: Route.tracking(orderId: order.id)) {
                            Text("Lieferung live verfolgen")
                        }
                        .buttonStyle(OutlineButtonStyle())
                        .padding(.top, 24)
                    }
                }

                Button("Zur Restaurant-Übersicht") {
                    navigationViewModel.switchTab(.home)
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.top, 12)
            }
            .padding(24)
        }
        .screenBackground()
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    NavigationStack {
        OrderConfirmationView(restaurantName: "Shisha Lounge")
    }
    .environmentObject(CartViewModel())
    .environmentObject(NavigationViewModel())
}
