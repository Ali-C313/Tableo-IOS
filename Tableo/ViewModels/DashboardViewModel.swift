//
//  DashboardViewModel.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseFirestore

/// Offene Bestellungen eines Restaurants fürs Personal
@MainActor
class DashboardViewModel: ObservableObject {

    @Published var orders: [FireOrder] = []
    @Published var isLoading = true
    @Published var errorMessage: String?

    private let database = FirebaseManager.shared.database
    private var listener: ListenerRegistration?

    func fetchActiveOrders(restaurantId: String) {
        let doneStatuses = [OrderStatus.erledigt.rawValue, OrderStatus.bezahlt.rawValue, OrderStatus.storniert.rawValue]

        // alten Listener entfernen, sonst laufen zwei gleichzeitig

        listener?.remove()

        listener = database.collection("orders")
            .whereField("restaurantId", isEqualTo: restaurantId)
            .whereField("status", notIn: doneStatuses)
            .addSnapshotListener { querySnapshot, error in
                self.isLoading = false
                if let error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                guard let documents = querySnapshot?.documents else { return }
                let orders = documents.compactMap { try? $0.data(as: FireOrder.self) }

                // was noch in der Küche ist zuerst, Lieferungen bei den Fahrern ans Ende
                self.orders = orders.sorted {
                    if $0.status.isWithDriver != $1.status.isWithDriver {
                        return !$0.status.isWithDriver
                    }
                    return $0.createdAt < $1.createdAt
                }
                self.errorMessage = nil
            }
    }

    func removeListener() {
        listener?.remove()
        listener = nil
    }

    /// Offen -> In Zubereitung -> Fertig
    func advanceStatus(_ order: FireOrder) {
        let nextStatus: OrderStatus
        switch order.status {
        case .offen: nextStatus = .inZubereitung
        case .inZubereitung: nextStatus = .fertig
        default: return
        }
        updateStatus(order, status: nextStatus)
    }

    /// Lieferungen gehen an die Fahrer, alles andere ins Archiv
    func markAsDone(_ order: FireOrder) {
        updateStatus(order, status: order.orderType == .delivery ? .abholbereit : .erledigt)
    }

    func cancelOrder(_ order: FireOrder) {
        Task {
            do {
                try await database.cancelOrder(orderId: order.id, byRestaurant: true)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func updateStatus(_ order: FireOrder, status: OrderStatus) {
        Task {
            do {
                try await database.collection("orders").document(order.id).updateData(["status": status.rawValue])
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
