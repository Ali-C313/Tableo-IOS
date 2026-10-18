//
//  OrderDetailView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Alle Details einer Bestellung für den Kunden. Von hier aus verfolgen, erneut bestellen oder stornieren
struct OrderDetailView: View {

    let orderId: String

    @StateObject private var orderDetailViewModel = OrderDetailViewModel()
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var navigationViewModel: NavigationViewModel

    @State private var showCancelAlert = false

    var body: some View {
        Group {
            if orderDetailViewModel.isLoading {
                LoadingView()
            } else if let order = orderDetailViewModel.order {
                ScrollView {
                    VStack(spacing: 12) {
                        headerCard(order)
                        detailsCard(order)
                        itemsCard(order)

                        if order.orderType == .delivery && !order.status.isDone {
                            NavigationLink(value: Route.tracking(orderId: order.id)) {
                                Text("Live verfolgen")
                            }
                            .buttonStyle(PrimaryButtonStyle())
                            .padding(.top, 4)
                        }

                        Button("Erneut bestellen") {
                            cartViewModel.reorder(order.items)
                            navigationViewModel.push(.menu(restaurantId: order.restaurantId, restaurantName: order.restaurantName))
                        }
                        .buttonStyle(OutlineButtonStyle())

                        if order.status == .offen {
                            Button("Bestellung stornieren") {
                                showCancelAlert = true
                            }
                            .font(AppFont.labelLarge)
                            .foregroundColor(AppColors.error)
                            .padding(.top, 4)
                        }
                    }
                    .padding(16)
                }
                .cancelOrderAlert(
                    isPresented: $showCancelAlert,
                    message: Text("Das geht nur, solange \(order.restaurantName) noch nicht mit der Zubereitung angefangen hat."),
                    onConfirm: { orderDetailViewModel.cancelOrder() }
                )
            } else if let errorMessage = orderDetailViewModel.errorMessage {
                ErrorView(message: errorMessage)
            }
        }
        .screenBackground()
        .navigationTitle("Bestelldetails")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            orderDetailViewModel.fetchOrder(orderId: orderId)
        }
        .onDisappear {
            orderDetailViewModel.removeListener()
        }
        .alert(orderDetailViewModel.cancelError ?? "", isPresented: Binding(
            get: { orderDetailViewModel.cancelError != nil },
            set: { if !$0 { orderDetailViewModel.cancelError = nil } }
        )) {
            Button("OK") {}
        }
    }

    /// Nummer, Status, Restaurant und Zeitpunkt
    private func headerCard(_ order: FireOrder) -> some View {
        DetailCardView {
            HStack {
                Text("Bestellung \(order.orderNumber)")
                    .font(AppFont.titleLarge)
                Spacer()
                StatusBadgeView(status: order.status, doneLabel: "Abgeschlossen")
            }
            Text(order.restaurantName)
                .font(AppFont.titleMedium)
                .foregroundColor(AppColors.primary)
                .padding(.top, 6)
            Text("Bestellt am \(order.createdAt.dateTimeText) Uhr")
                .font(AppFont.bodyMedium)
                .foregroundColor(AppColors.onSurfaceVariant)
            // lange drücken zum Kopieren, z.B. für Rückfragen beim Restaurant
            Text("Bestell-ID: \(order.id)")
                .font(AppFont.labelSmall)
                .foregroundColor(AppColors.onSurfaceVariant)
                .textSelection(.enabled)
                .padding(.top, 6)
        }
    }

    /// Art, Adresse oder Tisch, Bezahlart, Fahrer und Fertigzeit
    private func detailsCard(_ order: FireOrder) -> some View {
        DetailCardView {
            DetailRowView(label: "Bestellart", value: typeText(order))
            DetailRowView(
                label: order.orderType == .delivery ? "Lieferadresse" : "Wo / Wann",
                value: placeText(order)
            )
            DetailRowView(label: "Bezahlart", value: order.paymentMethod.title)
            DetailRowView(label: "Bestellt als", value: order.customerDisplayName)

            if let driver = order.driverName {
                DetailRowView(label: "Fahrer", value: driver.firstName)
            }
            if !order.status.isDone {
                DetailRowView(label: "Voraussichtlich", value: order.estimatedTimeText)
            }
            if order.status == .storniert {
                DetailRowView(
                    label: "Storniert von",
                    value: order.cancelledByRestaurant
                        ? String(localized: "Restaurant", bundle: .appLanguage)
                        : String(localized: "dir", bundle: .appLanguage)
                )
            }
        }
    }

    /// Alle Positionen und die Summe
    private func itemsCard(_ order: FireOrder) -> some View {
        DetailCardView {
            Text("Deine Bestellung")
                .font(AppFont.titleMedium)

            ForEach(order.items, id: \.menuItemId) { item in
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(item.quantity)× \(item.name)")
                            .font(AppFont.bodyLarge)
                        Text("je \(item.pricePerItem.euro)")
                            .font(AppFont.bodySmall)
                            .foregroundColor(AppColors.onSurfaceVariant)
                    }
                    Spacer()
                    Text(item.subtotal.euro)
                        .font(AppFont.bodyLarge)
                }
                .padding(.top, 10)
            }

            Divider().padding(.vertical, 12)

            HStack {
                Text("Gesamt")
                    .font(AppFont.titleMedium)
                Spacer()
                Text(order.totalPrice.euro)
                    .font(AppFont.titleMedium)
                    .foregroundColor(AppColors.primary)
            }
        }
    }

    private func typeText(_ order: FireOrder) -> String {
        switch order.orderType {
        case .dineIn: return String(localized: "Am Tisch", bundle: .appLanguage)
        case .pickup: return String(localized: "Abholung", bundle: .appLanguage)
        case .delivery: return String(localized: "Lieferung", bundle: .appLanguage)
        }
    }

    private func placeText(_ order: FireOrder) -> String {
        switch order.orderType {
        case .dineIn: return String(localized: "Tisch \(order.tableNumber.map(String.init) ?? "")", bundle: .appLanguage)
        case .pickup: return String(localized: "Abholung um \(order.pickupTime ?? "") Uhr", bundle: .appLanguage)
        case .delivery: return order.deliveryAddress ?? ""
        }
    }
}

/// Gleiche Karte für alle Abschnitte
struct DetailCardView<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle(shadow: false)
    }
}

/// Eine Zeile "Bezeichnung ... Wert"
struct DetailRowView: View {
    let label: LocalizedStringKey
    let value: String

    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .foregroundColor(AppColors.onSurfaceVariant)
            Spacer(minLength: 16)
            Text(value)
                .multilineTextAlignment(.trailing)
        }
        .font(AppFont.bodyMedium)
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        OrderDetailView(orderId: "abc")
    }
    .environmentObject(CartViewModel())
    .environmentObject(NavigationViewModel())
}
