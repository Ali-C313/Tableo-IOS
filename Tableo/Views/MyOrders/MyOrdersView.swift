//
//  MyOrdersView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Bestellungen des eingeloggten Kunden mit Live-Status
struct MyOrdersView: View {

    @StateObject private var myOrdersViewModel = MyOrdersViewModel()
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var navigationViewModel: NavigationViewModel

    var body: some View {
        Group {
            if myOrdersViewModel.isLoading {
                LoadingView()
            } else if let errorMessage = myOrdersViewModel.errorMessage {
                ErrorView(message: errorMessage)
            } else if myOrdersViewModel.orders.isEmpty {
                EmptyStateView(text: "Noch keine Bestellungen.")
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(myOrdersViewModel.orders) { order in
                            MyOrderCardView(
                                order: order,
                                onReorder: {
                                    cartViewModel.reorder(order.items)
                                    navigationViewModel.push(.menu(restaurantId: order.restaurantId, restaurantName: order.restaurantName))
                                },
                                onTrack: { navigationViewModel.push(.tracking(orderId: order.id)) },
                                onCancel: { myOrdersViewModel.cancelOrder(order) },
                                onOpen: { navigationViewModel.push(.orderDetail(orderId: order.id)) }
                            )
                        }
                    }
                    .padding(16)
                }
            }
        }
        .screenBackground()
        .navigationTitle("Meine Bestellungen")
        .onAppear {
            myOrdersViewModel.fetchOrders()
        }
        .onDisappear {
            myOrdersViewModel.removeListener()
        }
        // nach Login oder Logout neu laden
        .onChange(of: userViewModel.userId) {
            myOrdersViewModel.removeListener()
            myOrdersViewModel.fetchOrders()
        }
        // z.B. "wird schon zubereitet"
        .alert(myOrdersViewModel.cancelError ?? "", isPresented: Binding(
            get: { myOrdersViewModel.cancelError != nil },
            set: { if !$0 { myOrdersViewModel.cancelError = nil } }
        )) {
            Button("OK") {}
        }
    }
}

#Preview {
    NavigationStack {
        MyOrdersView()
    }
    .environmentObject(UserViewModel())
    .environmentObject(CartViewModel())
    .environmentObject(NavigationViewModel())
}
