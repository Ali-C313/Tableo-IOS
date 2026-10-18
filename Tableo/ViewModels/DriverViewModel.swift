//
//  DriverViewModel.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseFirestore

/// Fahrer-Bereich: Lieferungen annehmen, Reihenfolge der Tour festlegen und losfahren.
/// Ab der ersten angenommenen Lieferung geht der Standort an alle Bestellungen der Tour
@MainActor
class DriverViewModel: ObservableObject {

    // warten auf einen Fahrer
    @Published var available: [FireOrder] = []
    // eigene Tour, nach Platz sortiert
    @Published var tour: [FireOrder] = []
    @Published var isLoading = true
    @Published var errorMessage: String?

    // true, solange der Standort gesendet wird
    @Published var isTracking = false
    @Published var trackingError: String?

    private let database = FirebaseManager.shared.database
    private var listener: ListenerRegistration?
    private var driverName = ""

    // nil = noch nichts geladen, damit beim Öffnen nicht für alle alten Lieferungen eine Nachricht kommt
    private var knownAvailableIds: Set<String>?
    private var notifiedIds = Set<String>()

    func fetchDeliveries(restaurantId: String, driverName: String) {
        self.driverName = driverName

        // alten Listener entfernen, sonst laufen zwei gleichzeitig

        listener?.remove()

        listener = database.collection("orders")
            .whereField("restaurantId", isEqualTo: restaurantId)
            .whereField("orderType", isEqualTo: OrderType.delivery.rawValue)
            .addSnapshotListener { querySnapshot, error in
                self.isLoading = false
                if let error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                guard let documents = querySnapshot?.documents else { return }
                let orders = documents.compactMap { try? $0.data(as: FireOrder.self) }

                let available = orders
                    .filter { $0.status == .abholbereit }
                    .sorted { $0.createdAt < $1.createdAt }

                self.tour = orders
                    .filter { $0.driverName == driverName }
                    .filter { $0.status == .angenommen || $0.status == .unterwegs }
                    .sorted { ($0.tourPosition ?? Int.max) < ($1.tourPosition ?? Int.max) }

                self.notifyAboutNewDeliveries(available)
                self.available = available
                self.errorMessage = nil
            }
    }

    /// Screen ist zu, Standort nicht weiter senden
    func removeListener() {
        listener?.remove()
        listener = nil
        stopTracking()
    }

    /// Lieferung kommt hinten an die Tour
    func accept(_ order: FireOrder) {
        let position = (tour.compactMap { $0.tourPosition }.max() ?? 0) + 1
        // läuft die Tour schon, ist die neue Lieferung direkt mit unterwegs
        let status: OrderStatus = tour.contains { $0.status == .unterwegs } ? .unterwegs : .angenommen

        Task {
            try? await database.collection("orders").document(order.id).updateData([
                "driverName": driverName,
                "tourPosition": position,
                "status": status.rawValue
            ])
        }
        startTracking()
    }

    /// Einen Platz nach vorne (-1) oder hinten (+1)
    func move(_ order: FireOrder, direction: Int) {
        var newTour = tour
        guard let index = newTour.firstIndex(where: { $0.id == order.id }) else { return }
        let newIndex = index + direction
        guard newTour.indices.contains(newIndex) else { return }
        newTour.remove(at: index)
        newTour.insert(order, at: newIndex)
        savePositions(newTour)
    }

    /// Alle angenommenen Lieferungen auf unterwegs, klappt auch zum Fortsetzen
    func startTour() {
        let waiting = tour.filter { $0.status == .angenommen }
        Task {
            for order in waiting {
                try? await database.collection("orders").document(order.id).updateData(["status": OrderStatus.unterwegs.rawValue])
            }
        }
        startTracking()
    }

    /// Lieferung ist angekommen, die nächste rückt auf Platz 1
    func finishDelivery(_ order: FireOrder) {
        let remaining = tour.filter { $0.id != order.id }
        Task {
            try? await database.collection("orders").document(order.id).updateData(["status": OrderStatus.erledigt.rawValue])
        }
        savePositions(remaining)
        if remaining.isEmpty {
            stopTracking()
        }
    }

    /// Schreibt die Plätze 1, 2, 3 ... in der Reihenfolge der Liste
    private func savePositions(_ newTour: [FireOrder]) {
        guard !newTour.isEmpty else { return }
        let batch = database.batch()
        for (index, order) in newTour.enumerated() {
            batch.updateData(["tourPosition": index + 1], forDocument: database.collection("orders").document(order.id))
        }
        Task {
            try? await batch.commit()
        }
    }

    // MARK: - Standort

    private func startTracking() {
        guard !isTracking else { return }

        LocationManager.shared.requestPermission { allowed in
            guard allowed else {
                self.trackingError = String(localized: "Ohne Standort-Freigabe können die Kunden dich nicht verfolgen", bundle: .appLanguage)
                return
            }
            self.trackingError = nil
            self.isTracking = true

            LocationManager.shared.startUpdating { coordinates in
                self.sendLocation(coordinates)
            }
        }
    }

    private func stopTracking() {
        LocationManager.shared.stopUpdating()
        isTracking = false
    }

    /// Standort geht an alle Lieferungen der Tour, auch an die noch nicht gestarteten
    private func sendLocation(_ coordinates: Coordinates) {
        guard !tour.isEmpty else { return }
        let location = ["latitude": coordinates.latitude, "longitude": coordinates.longitude]
        let batch = database.batch()
        for order in tour {
            batch.updateData(["driverLocation": location], forDocument: database.collection("orders").document(order.id))
        }
        Task {
            do {
                try await batch.commit()
            } catch {
                trackingError = String(localized: "Standort konnte nicht gesendet werden", bundle: .appLanguage)
            }
        }
    }

    // MARK: - Benachrichtigungen

    private func notifyAboutNewDeliveries(_ available: [FireOrder]) {
        let ids = Set(available.map { $0.id })
        let known = knownAvailableIds
        knownAvailableIds = ids
        guard let known else { return }

        for order in available where !known.contains(order.id) && notifiedIds.insert(order.id).inserted {
            NotificationManager.shared.show(
                id: order.id,
                title: String(localized: "Neue Lieferung abholbereit", bundle: .appLanguage),
                text: "\(order.customerDisplayName) · \(order.deliveryAddress ?? "")"
            )
        }
    }
}
