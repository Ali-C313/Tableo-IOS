//
//  MenuView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Speisekarte eines Restaurants. Unten erscheint der Warenkorb, sobald etwas drin ist
struct MenuView: View {

    let restaurantId: String
    let restaurantName: String

    @StateObject private var menuViewModel = MenuViewModel()
    @EnvironmentObject var cartViewModel: CartViewModel

    @State private var selectedCategory: String?
    @State private var selectedCurrency = "EUR"

    private let currencies = ["EUR", "USD", "GBP", "TRY"]

    var body: some View {
        VStack(spacing: 0) {
            if !menuViewModel.categoryNames.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChipView(label: String(localized: "Alle", bundle: .appLanguage), selected: selectedCategory == nil) {
                            selectedCategory = nil
                        }
                        ForEach(menuViewModel.categoryNames, id: \.self) { category in
                            FilterChipView(label: category, selected: category == selectedCategory) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }

            HStack {
                Spacer()
                DropdownView(
                    selected: selectedCurrency,
                    options: currencies,
                    placeholder: String(localized: "Währung wählen", bundle: .appLanguage)
                ) { currency in
                    selectedCurrency = currency
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            if menuViewModel.isLoading {
                LoadingView()
            } else if let errorMessage = menuViewModel.errorMessage {
                ErrorView(message: errorMessage)
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(filteredItems) { item in
                            MenuItemRowView(
                                menuItem: item,
                                cartQuantity: cartViewModel.quantity(of: item.id),
                                convertedPrice: convertedPrice(item.price),
                                onAdd: { cartViewModel.addItem(item) }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                    .padding(.bottom, 16)
                }
            }
        }
        .screenBackground()
        .navigationTitle(restaurantName)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            if cartViewModel.itemCount > 0 {
                cartBar
            }
        }
        .onAppear {
            menuViewModel.fetchMenu(restaurantId: restaurantId)
            menuViewModel.fetchRates()
        }
        .onDisappear {
            menuViewModel.removeListener()
        }
    }

    private var filteredItems: [FireMenuItem] {
        menuViewModel.menuItems.filter { selectedCategory == nil || $0.category == selectedCategory }
    }

    /// nil bei Euro oder wenn die Kurse fehlen
    private func convertedPrice(_ price: Double) -> String? {
        guard selectedCurrency != "EUR", let rate = menuViewModel.rates[selectedCurrency] else { return nil }
        return (price * rate).foreignCurrency(selectedCurrency)
    }

    private var cartBar: some View {
        HStack {
            Image(systemName: "cart.fill")
                .foregroundColor(AppColors.primary)
                .padding(.trailing, 6)

            VStack(alignment: .leading, spacing: 0) {
                Text("\(cartViewModel.itemCount) Artikel")
                    .font(AppFont.labelLarge)
                Text(cartViewModel.totalPrice.euro)
                    .font(AppFont.titleMedium)
                    .foregroundColor(AppColors.primary)
            }
            Spacer()

            NavigationLink(value: Route.orderDetails(restaurantId: restaurantId, restaurantName: restaurantName)) {
                Text("Weiter")
            }
            .buttonStyle(PrimaryButtonStyle())
            .fixedSize()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            UnevenRoundedRectangle(topLeadingRadius: 28, topTrailingRadius: 28)
                .fill(AppColors.surfaceContainer)
                .shadow(color: .black.opacity(0.15), radius: 8, y: -2)
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

#Preview {
    NavigationStack {
        MenuView(restaurantId: "1", restaurantName: "Shisha Lounge")
    }
    .environmentObject(CartViewModel())
}
