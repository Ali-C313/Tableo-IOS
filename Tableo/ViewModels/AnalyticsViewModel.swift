//
//  AnalyticsViewModel.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseFirestore

/// Umsatz und Anzahl der Bestellungen für den gewählten Zeitraum
@MainActor
class AnalyticsViewModel: ObservableObject {

    @Published var period: AnalyticsPeriod = .last24h {
        didSet { calculate() }
    }
    @Published var buckets: [ChartBucket] = []
    @Published var totalRevenue: Double = 0
    @Published var totalOrders = 0
    @Published var isLoading = true
    @Published var errorMessage: String?

    private let database = FirebaseManager.shared.database
    private var listener: ListenerRegistration?

    // alle abgeschlossenen Bestellungen, beim Wechsel vom Zeitraum wird nur neu gerechnet
    private var completedOrders: [FireOrder] = []

    func fetchOrders(restaurantId: String) {
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
                // stornierte bringen keinen Umsatz
                self.completedOrders = orders.filter { $0.status != .storniert }
                self.calculate()
            }
    }

    func removeListener() {
        listener?.remove()
        listener = nil
    }

    private func calculate() {
        let now = currentMillis()
        let start = now - period.millis
        let relevant = completedOrders.filter { $0.createdAt >= start && $0.createdAt <= now }
        let bucketSize = period.millis / Int64(period.bucketCount)

        let formatter = DateFormatter()
        formatter.dateFormat = period.labelFormat
        let languageCode = UserDefaults.standard.string(forKey: "app_language") ?? ""
        formatter.locale = languageCode.isEmpty ? .current : Locale(identifier: languageCode)

        buckets = (0..<period.bucketCount).map { index in
            let bucketStart = start + Int64(index) * bucketSize
            let bucketEnd = bucketStart + bucketSize
            let bucketOrders = relevant.filter { $0.createdAt >= bucketStart && $0.createdAt < bucketEnd }
            return ChartBucket(
                label: formatter.string(from: Date(timeIntervalSince1970: Double(bucketStart) / 1000)),
                revenue: bucketOrders.reduce(0) { $0 + $1.totalPrice },
                orderCount: bucketOrders.count
            )
        }
        totalRevenue = relevant.reduce(0) { $0 + $1.totalPrice }
        totalOrders = relevant.count
    }
}
