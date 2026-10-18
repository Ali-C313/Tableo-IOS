//
//  TrackingViewModel.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseFirestore

/// Lieferung live verfolgen. Hört auf alle Lieferungen des Restaurants,
/// damit man sieht, wie viele der Fahrer vorher noch ausliefert
@MainActor
class TrackingViewModel: ObservableObject {

    @Published var order: FireOrder?
    // Adressen, die der Fahrer vor dieser Bestellung noch anfährt
    @Published var stopsBefore: [Coordinates] = []
    @Published var isLoading = true
    @Published var errorMessage: String?

    private let database = FirebaseManager.shared.database
    private var listener: ListenerRegistration?

    // grob 25 km/h in der Stadt und 3 Minuten pro Übergabe
    private let averageSpeedKmh = 25.0
    private let minutesPerStop = 3

    func fetchTracking(orderId: String) {
        Task {
            // einmal laden, um das Restaurant zu kennen
            let snapshot = try? await database.collection("orders").document(orderId).getDocument()
            guard let snapshot, snapshot.exists, let firstOrder = try? snapshot.data(as: FireOrder.self) else {
                isLoading = false
                errorMessage = String(localized: "Bestellung nicht gefunden", bundle: .appLanguage)
                return
            }
            order = firstOrder
            listenToDeliveries(orderId: orderId, restaurantId: firstOrder.restaurantId)
        }
    }

    /// Eine Abfrage für alles, die eigene Bestellung ist bei den Lieferungen dabei
    private func listenToDeliveries(orderId: String, restaurantId: String) {
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
                let deliveries = documents.compactMap { try? $0.data(as: FireOrder.self) }

                if let order = deliveries.first(where: { $0.id == orderId }) {
                    self.order = order
                }
                if let order = self.order {
                    self.stopsBefore = self.findStopsBefore(order, deliveries: deliveries)
                }
            }
    }

    func removeListener() {
        listener?.remove()
        listener = nil
    }

    private func findStopsBefore(_ order: FireOrder, deliveries: [FireOrder]) -> [Coordinates] {
        guard let position = order.tourPosition else { return [] }
        return deliveries
            .filter { $0.driverName == order.driverName && $0.id != order.id }
            .filter { $0.status == .angenommen || $0.status == .unterwegs }
            .filter { ($0.tourPosition ?? Int.max) < position }
            .sorted { ($0.tourPosition ?? 0) < ($1.tourPosition ?? 0) }
            .compactMap { $0.deliveryLocation }
    }

    /// Nur der Vorname, wegen Datenschutz
    var driverName: String {
        order?.driverName?.firstName ?? String(localized: "Der Fahrer", bundle: .appLanguage)
    }

    /// Luftlinie vom Fahrer zum Kunden
    var directKm: Double? {
        guard let driver = order?.driverLocation, let destination = order?.deliveryLocation else { return nil }
        return driver.distanceInKm(to: destination)
    }

    /// Fahrzeit über alle Stopps vorher bis zum Kunden
    var etaMinutes: Int? {
        guard let driver = order?.driverLocation, let destination = order?.deliveryLocation else { return nil }
        var totalKm = 0.0
        var from = driver
        for stop in stopsBefore + [destination] {
            totalKm += from.distanceInKm(to: stop)
            from = stop
        }
        let driveMinutes = max(Int(ceil(totalKm / averageSpeedKmh * 60)), 1)
        return driveMinutes + stopsBefore.count * minutesPerStop
    }

    var headline: String {
        guard let order else { return "" }
        switch order.status {
        case .offen, .inZubereitung:
            return String(localized: "Dein Essen wird zubereitet", bundle: .appLanguage)
        case .fertig, .abholbereit:
            return String(localized: "Wartet auf einen Fahrer", bundle: .appLanguage)
        case .angenommen, .unterwegs:
            if let etaMinutes {
                return String(localized: "In ca. \(etaMinutes) Min. bei dir", bundle: .appLanguage)
            }
            return String(localized: "\(driverName) hat deine Bestellung", bundle: .appLanguage)
        case .erledigt, .bezahlt:
            return String(localized: "Zugestellt. Guten Appetit!", bundle: .appLanguage)
        case .storniert:
            return String(localized: "Bestellung storniert", bundle: .appLanguage)
        }
    }

    var subline: String? {
        guard let order else { return nil }
        switch order.status {
        case .angenommen:
            return String(localized: "\(driverName) holt deine Bestellung gerade ab", bundle: .appLanguage)
        case .unterwegs:
            if !stopsBefore.isEmpty {
                return String(localized: "\(driverName) ist unterwegs und liefert vorher noch \(stopsBefore.count) Bestellung(en)", bundle: .appLanguage)
            }
            if let directKm {
                return String(localized: "\(driverName) ist auf dem Weg zu dir, noch \(distanceText(directKm))", bundle: .appLanguage)
            }
            return String(localized: "\(driverName) ist auf dem Weg zu dir", bundle: .appLanguage)
        default:
            return nil
        }
    }

    /// "1,4 km" oder "350 m"
    private func distanceText(_ km: Double) -> String {
        if km < 1 {
            return "\(Int(km * 1000)) m"
        }
        return String(format: "%.1f km", km).replacingOccurrences(of: ".", with: ",")
    }
}
