//
//  ShiftViewModel.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseFirestore

/// Dienst-Schalter fürs Personal. Wer im Dienst ist, bekommt bei jeder neuen Bestellung eine Nachricht
@MainActor
class ShiftViewModel: ObservableObject {

    // eigenes Profil, nil bei Kunden
    @Published var profile: FireStaffProfile?

    private let database = FirebaseManager.shared.database
    private var profileListener: ListenerRegistration?
    private var ordersListener: ListenerRegistration?
    private var observedUserId: String?
    private var ordersRestaurantId: String?

    // schon gesehene Bestellungen, damit jede nur einmal gemeldet wird
    private var knownOrderIds = Set<String>()
    private var firstLoad = true

    /// Hört auf das eigene Profil. Mehrfach aufrufen ist kein Problem
    func start(userId: String?) {
        if userId == observedUserId { return }
        stop()
        guard let userId else { return }
        observedUserId = userId

        profileListener = database.collection("staffProfiles").document(userId)
            .addSnapshotListener { documentSnapshot, error in
                guard let documentSnapshot, documentSnapshot.exists else {
                    self.profile = nil
                    self.stopListeningToOrders()
                    return
                }
                let profile = try? documentSnapshot.data(as: FireStaffProfile.self)
                self.profile = profile

                if let profile, profile.onDuty {
                    self.listenToOrders(restaurantId: profile.restaurantId)
                } else {
                    self.stopListeningToOrders()
                }
            }
    }

    /// Beim Abmelden
    func stop() {
        profileListener?.remove()
        profileListener = nil
        observedUserId = nil
        profile = nil
        stopListeningToOrders()
    }

    func setOnDuty(_ onDuty: Bool) {
        guard let current = profile else { return }
        // Schalter sofort umlegen, Firestore meldet sich danach sowieso
        profile?.onDuty = onDuty

        Task {
            do {
                try await database.collection("staffProfiles").document(current.id).updateData(["onDuty": onDuty])
            } catch {
                profile = current
            }
        }
    }

    private func listenToOrders(restaurantId: String) {
        if ordersListener != nil && ordersRestaurantId == restaurantId { return }
        stopListeningToOrders()
        ordersRestaurantId = restaurantId
        firstLoad = true

        let doneStatuses = [OrderStatus.erledigt.rawValue, OrderStatus.bezahlt.rawValue, OrderStatus.storniert.rawValue]

        ordersListener = database.collection("orders")
            .whereField("restaurantId", isEqualTo: restaurantId)
            .whereField("status", notIn: doneStatuses)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else { return }
                let orders = documents.compactMap { try? $0.data(as: FireOrder.self) }

                for order in orders {
                    let isNew = self.knownOrderIds.insert(order.id).inserted
                    // beim ersten Laden nur merken, sonst klingelt es für alle offenen Bestellungen
                    if isNew && !self.firstLoad && order.status == .offen {
                        self.notifyNewOrder(order)
                    }
                }
                self.firstLoad = false
            }
    }

    private func stopListeningToOrders() {
        ordersListener?.remove()
        ordersListener = nil
        ordersRestaurantId = nil
        knownOrderIds.removeAll()
    }

    private func notifyNewOrder(_ order: FireOrder) {
        NotificationManager.shared.show(
            id: order.id,
            title: String(localized: "Neue Bestellung \(order.orderNumber)", bundle: .appLanguage),
            text: "\(order.orderTypeText) · \(order.customerDisplayName) · \(order.totalPrice.euro)"
        )
    }
}
