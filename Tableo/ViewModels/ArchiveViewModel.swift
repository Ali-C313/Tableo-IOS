//
//  ArchiveViewModel.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseFirestore

/// Abgeschlossene und stornierte Bestellungen, neueste zuerst
@MainActor
class ArchiveViewModel: ObservableObject {

    @Published var orders: [FireOrder] = []
    @Published var isLoading = true
    @Published var errorMessage: String?

    private let database = FirebaseManager.shared.database
    private var listener: ListenerRegistration?

    func fetchArchive(restaurantId: String) {
        let doneStatuses = [OrderStatus.erledigt.rawValue, OrderStatus.bezahlt.rawValue, OrderStatus.storniert.rawValue]

        // alten Listener entfernen, sonst laufen zwei gleichzeitig

        listener?.remove()

        listener = database.collection("orders")
            .whereField("restaurantId", isEqualTo: restaurantId)
            .whereField("status", in: doneStatuses)
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
}
