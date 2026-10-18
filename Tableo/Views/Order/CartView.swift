//
//  CartView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Warenkorb: Menge anpassen, Bezahlart wählen und die Bestellung abschicken
struct CartView: View {

    let restaurantId: String
    let restaurantName: String
    let orderType: OrderType
    let tableNumber: Int?
    let pickupTime: String?

    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var deliveryViewModel: DeliveryViewModel
    @EnvironmentObject var navigationViewModel: NavigationViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(restaurantName)
                .font(AppFont.titleLarge)
                .padding(.top, 8)

            orderTypeText
                .font(AppFont.bodyMedium)
                .foregroundColor(AppColors.primary)
                .padding(.top, 4)
                .padding(.bottom, 16)

            if cartViewModel.items.isEmpty {
                EmptyStateView(text: "Dein Warenkorb ist leer.")
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(cartViewModel.items, id: \.menuItemId) { item in
                            CartItemRowView(
                                orderItem: item,
                                onIncrease: { cartViewModel.increaseQuantity(item.menuItemId) },
                                onDecrease: { cartViewModel.removeItem(item.menuItemId) }
                            )
                        }
                    }
                    .padding(.vertical, 4)
                }

                HStack {
                    Text("Bezahlart")
                        .font(AppFont.titleMedium)
                    Spacer()
                    DropdownView(
                        selected: cartViewModel.paymentMethod,
                        options: PaymentMethod.allCases,
                        placeholder: String(localized: "Auswählen", bundle: .appLanguage),
                        optionLabel: { $0.title }
                    ) { method in
                        cartViewModel.selectPaymentMethod(method)
                    }
                }
                .padding(.top, 16)

                HStack {
                    Text("Gesamt")
                        .font(AppFont.titleMedium)
                    Spacer()
                    Text(cartViewModel.totalPrice.euro)
                        .font(AppFont.titleMedium)
                        .foregroundColor(AppColors.primary)
                }
                .padding(.vertical, 16)

                if let errorMessage = cartViewModel.errorMessage {
                    Text("Fehler: \(errorMessage)")
                        .font(AppFont.bodyMedium)
                        .foregroundColor(AppColors.error)
                        .padding(.bottom, 8)
                }

                Button {
                    placeOrder()
                } label: {
                    HStack(spacing: 8) {
                        if cartViewModel.isLoading {
                            ProgressView()
                                .tint(AppColors.onPrimary)
                        }
                        Text("Bestellung senden")
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(cartViewModel.isLoading || cartViewModel.paymentMethod == nil)
                .padding(.bottom, 16)
            }
        }
        .padding(.horizontal, 16)
        .screenBackground()
        .navigationTitle("Warenkorb")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var orderTypeText: some View {
        switch orderType {
        case .dineIn:
            Text("Tisch \(tableNumber.map(String.init) ?? "")")
        case .pickup:
            Text("Abholung um \(pickupTime ?? "") Uhr")
        case .delivery:
            Text("Lieferung an \(deliveryViewModel.address?.text ?? "")")
        }
    }

    private func placeOrder() {
        cartViewModel.placeOrder(
            restaurantId: restaurantId,
            restaurantName: restaurantName,
            orderType: orderType,
            tableNumber: tableNumber,
            pickupTime: pickupTime,
            deliveryAddress: deliveryViewModel.address
        ) {
            // Speisekarte, Details und Warenkorb fliegen raus, zurück geht es dann zum Start
            navigationViewModel.replaceStack([.orderConfirmation(restaurantName: restaurantName)])
        }
    }
}

#Preview {
    NavigationStack {
        CartView(restaurantId: "1", restaurantName: "Shisha Lounge", orderType: .dineIn, tableNumber: 7, pickupTime: nil)
    }
    .environmentObject(CartViewModel())
    .environmentObject(DeliveryViewModel())
    .environmentObject(NavigationViewModel())
}
