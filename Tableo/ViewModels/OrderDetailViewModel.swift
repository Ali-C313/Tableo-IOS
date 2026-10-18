//
//  OrderDetailViewModel.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseFirestore

/// Eine Bestellung live, damit Status und Fahrer sich sofort ändern
@MainActor
class OrderDetailViewModel: ObservableObject {

    @Published var order: FireOrder?
    @Published var isLoading = true
    @Published var errorMessage: String?
    @Published var cancelError: String?

    private let database = FirebaseManager.shared.database
    private var listener: ListenerRegistration?

    func fetchOrder(orderId: String) {
        // alten Listener entfernen, sonst laufen zwei gleichzeitig
        listener?.remove()
        listener = database.collection("orders").document(orderId)
            .addSnapshotListener { documentSnapshot, error in
                self.isLoading = false
                if let error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                guard let documentSnapshot, documentSnapshot.exists else {
                    self.errorMessage = String(localized: "Bestellung nicht gefunden", bundle: .appLanguage)
                    return
                }
                self.order = try? documentSnapshot.data(as: FireOrder.self)
                self.errorMessage = nil
            }
    }

    func removeListener() {
        listener?.remove()
        listener = nil
    }

    /// Kunde storniert, nur solange offen
    func cancelOrder() {
        guard let order else { return }
        Task {
            do {
                try await database.cancelOrder(orderId: order.id, byRestaurant: false)
            } catch {
                cancelError = error.localizedDescription
            }
        }
    }
}
