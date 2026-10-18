//
//  CartViewModel.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseFirestore

/// Warenkorb für den ganzen Bestellvorgang, deshalb als EnvironmentObject
@MainActor
class CartViewModel: ObservableObject {

    @Published var items: [OrderItem] = []
    // nil, solange noch nichts gewählt ist
    @Published var paymentMethod: PaymentMethod?

    @Published var isLoading = false
    @Published var errorMessage: String?

    // zuletzt abgeschickte Bestellung, für die Bestätigung
    @Published var lastOrder: FireOrder?

    private let database = FirebaseManager.shared.database
    private let auth = FirebaseManager.shared.auth

    var itemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    var totalPrice: Double {
        items.reduce(0) { $0 + $1.subtotal }
    }

    func quantity(of menuItemId: String) -> Int {
        items.first { $0.menuItemId == menuItemId }?.quantity ?? 0
    }

    func selectPaymentMethod(_ method: PaymentMethod) {
        paymentMethod = method
        errorMessage = nil
    }

    /// Neuer Artikel oder Menge +1
    func addItem(_ menuItem: FireMenuItem) {
        if let index = items.firstIndex(where: { $0.menuItemId == menuItem.id }) {
            items[index].quantity += 1
        } else {
            items.append(OrderItem(menuItemId: menuItem.id, name: menuItem.name, pricePerItem: menuItem.price, quantity: 1))
        }
    }

    func increaseQuantity(_ menuItemId: String) {
        if let index = items.firstIndex(where: { $0.menuItemId == menuItemId }) {
            items[index].quantity += 1
        }
    }

    /// Menge -1, bei 0 fliegt der Artikel raus
    func removeItem(_ menuItemId: String) {
        guard let index = items.firstIndex(where: { $0.menuItemId == menuItemId }) else { return }
        if items[index].quantity > 1 {
            items[index].quantity -= 1
        } else {
            items.remove(at: index)
        }
    }

    /// "Erneut bestellen": alle Positionen einer alten Bestellung übernehmen
    func reorder(_ orderItems: [OrderItem]) {
        items = orderItems
    }

    /// Baut aus dem Warenkorb eine Bestellung und speichert sie in "orders"
    func placeOrder(restaurantId: String, restaurantName: String, orderType: OrderType, tableNumber: Int?,
                    pickupTime: String?, deliveryAddress: DeliveryAddress?, onSuccess: @escaping () -> Void) {
        guard let paymentMethod else {
            errorMessage = String(localized: "Bitte wähle eine Bezahlart", bundle: .appLanguage)
            return
        }
        let isDelivery = orderType == .delivery
        if isDelivery && deliveryAddress == nil {
            errorMessage = String(localized: "Bitte gib eine Lieferadresse ein", bundle: .appLanguage)
            return
        }

        let user = auth.currentUser
        let isGuest = user == nil || user?.isAnonymous == true

        // gleicher Name wie auf der Startseite
        var customerName = user?.displayName ?? ""
        if customerName.isEmpty {
            customerName = user?.email?.components(separatedBy: "@").first ?? ""
        }
        if customerName.isEmpty {
            customerName = String(localized: "Gast", bundle: .appLanguage)
        }

        var order = FireOrder(
            restaurantId: restaurantId,
            restaurantName: restaurantName,
            userId: isGuest ? nil : user?.uid,
            customerName: customerName,
            orderType: orderType,
            tableNumber: tableNumber,
            pickupTime: pickupTime,
            deliveryAddress: isDelivery ? deliveryAddress?.text : nil,
            deliveryLocation: isDelivery ? deliveryAddress?.coordinates : nil,
            paymentMethod: paymentMethod,
            items: items
        )

        isLoading = true
        errorMessage = nil

        do {
            let reference = try database.collection("orders").addDocument(from: order)
            // ID merken, damit man von der Bestätigung aus die Bestellung öffnen kann
            order.documentId = reference.documentID
            lastOrder = order
            items = []
            isLoading = false
            onSuccess()
        } catch {
            errorMessage = String(localized: "Bestellung konnte nicht gesendet werden", bundle: .appLanguage)
            isLoading = false
        }
    }
}
