//
//  MyOrdersViewModel.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseFirestore

/// Bestellungen des eingeloggten Kunden, neueste zuerst
@MainActor
class MyOrdersViewModel: ObservableObject {

    @Published var orders: [FireOrder] = []
    @Published var isLoading = true
    @Published var errorMessage: String?
    // z.B. wenn schon zubereitet wird
    @Published var cancelError: String?

    private let database = FirebaseManager.shared.database
    private var listener: ListenerRegistration?

    func fetchOrders() {
        errorMessage = nil
        guard let userId = FirebaseManager.shared.userId else {
            isLoading = false
            orders = []
            errorMessage = String(localized: "Nicht eingeloggt", bundle: .appLanguage)
            return
        }

        // alten Listener entfernen, sonst laufen zwei gleichzeitig

        listener?.remove()

        listener = database.collection("orders")
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { querySnapshot, error in
                self.isLoading = false
                if let error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                guard let documents = querySnapshot?.documents else { return }
                let orders = documents.compactMap { try? $0.data(as: FireOrder.self) }
                self.orders = orders.sorted { $0.createdAt > $1.createdAt }
                self.errorMessage = nil
            }
    }

    func removeListener() {
        listener?.remove()
        listener = nil
    }

    /// Klappt nur, solange die Bestellung noch offen ist
    func cancelOrder(_ order: FireOrder) {
        Task {
            do {
                try await database.cancelOrder(orderId: order.id, byRestaurant: false)
            } catch {
                cancelError = error.localizedDescription
            }
        }
    }
}
