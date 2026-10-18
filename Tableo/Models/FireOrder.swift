//
//  FireOrder.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseFirestore

/// Bestellung aus der Collection "orders", am Tisch, zum Abholen oder als Lieferung
struct FireOrder: Codable, Identifiable, Hashable {
    @DocumentID var documentId: String?

    var restaurantId: String = ""
    // Name beim Bestellen, für die Historie
    var restaurantName: String = ""
    // nil bei Gästen ohne Konto
    var userId: String?
    var customerName: String = ""
    var orderType: OrderType = .dineIn
    var tableNumber: Int?
    // z.B. "19:30"
    var pickupTime: String?
    var deliveryAddress: String?
    var deliveryLocation: Coordinates?
    var driverLocation: Coordinates?
    var driverName: String?
    // 1 = wird als Nächstes geliefert
    var tourPosition: Int?
    var paymentMethod: PaymentMethod = .bar
    var items: [OrderItem] = []
    var status: OrderStatus = .offen
    // true = Restaurant hat storniert, false = Kunde
    var cancelledByRestaurant: Bool = false
    // Millisekunden seit 1970, wie in der Android-App
    var createdAt: Int64 = Int64(Date().timeIntervalSince1970 * 1000)

    var id: String { documentId ?? "" }

    enum CodingKeys: String, CodingKey {
        case documentId, restaurantId, restaurantName, userId, customerName, orderType, tableNumber, pickupTime
        case deliveryAddress, deliveryLocation, driverLocation, driverName, tourPosition, paymentMethod
        case items, status, cancelledByRestaurant, createdAt
    }

    init(restaurantId: String, restaurantName: String, userId: String?, customerName: String,
         orderType: OrderType, tableNumber: Int?, pickupTime: String?, deliveryAddress: String?,
         deliveryLocation: Coordinates?, paymentMethod: PaymentMethod, items: [OrderItem]) {
        self.restaurantId = restaurantId
        self.restaurantName = restaurantName
        self.userId = userId
        self.customerName = customerName
        self.orderType = orderType
        self.tableNumber = tableNumber
        self.pickupTime = pickupTime
        self.deliveryAddress = deliveryAddress
        self.deliveryLocation = deliveryLocation
        self.paymentMethod = paymentMethod
        self.items = items
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _documentId = try container.decode(DocumentID<String>.self, forKey: .documentId)
        restaurantId = try container.decodeIfPresent(String.self, forKey: .restaurantId) ?? ""
        restaurantName = try container.decodeIfPresent(String.self, forKey: .restaurantName) ?? ""
        userId = try container.decodeIfPresent(String.self, forKey: .userId)
        customerName = try container.decodeIfPresent(String.self, forKey: .customerName) ?? ""
        orderType = try container.decodeIfPresent(OrderType.self, forKey: .orderType) ?? .dineIn
        tableNumber = try container.decodeIfPresent(Int.self, forKey: .tableNumber)
        pickupTime = try container.decodeIfPresent(String.self, forKey: .pickupTime)
        deliveryAddress = try container.decodeIfPresent(String.self, forKey: .deliveryAddress)
        deliveryLocation = try container.decodeIfPresent(Coordinates.self, forKey: .deliveryLocation)
        driverLocation = try container.decodeIfPresent(Coordinates.self, forKey: .driverLocation)
        driverName = try container.decodeIfPresent(String.self, forKey: .driverName)
        tourPosition = try container.decodeIfPresent(Int.self, forKey: .tourPosition)
        paymentMethod = try container.decodeIfPresent(PaymentMethod.self, forKey: .paymentMethod) ?? .bar
        items = try container.decodeIfPresent([OrderItem].self, forKey: .items) ?? []
        status = try container.decodeIfPresent(OrderStatus.self, forKey: .status) ?? .offen
        cancelledByRestaurant = try container.decodeIfPresent(Bool.self, forKey: .cancelledByRestaurant) ?? false
        createdAt = try container.decodeIfPresent(Int64.self, forKey: .createdAt) ?? 0
    }

    var totalPrice: Double {
        items.reduce(0) { $0 + $1.subtotal }
    }

    /// "#A1B2C3"
    var orderNumber: String {
        "#" + id.prefix(6).uppercased()
    }

    var customerDisplayName: String {
        customerName.isEmpty ? String(localized: "Gast", bundle: .appLanguage) : customerName
    }

    /// "2× Doppelapfel, 1× Minztee"
    var itemsText: String {
        items.map { "\($0.quantity)× \($0.name)" }.joined(separator: ", ")
    }

    /// "Tisch 7", "Abholung um 19:30 Uhr" oder "Lieferung"
    var orderTypeText: String {
        switch orderType {
        case .dineIn:
            return String(localized: "Tisch \(tableNumber.map(String.init) ?? "")", bundle: .appLanguage)
        case .pickup:
            return String(localized: "Abholung um \(pickupTime ?? "") Uhr", bundle: .appLanguage)
        case .delivery:
            return String(localized: "Lieferung", bundle: .appLanguage)
        }
    }

    /// Wann das Essen ungefähr da ist. Zubereitung 20 Min, bei Lieferung 20 Min mehr
    var estimatedTimeText: String {
        if orderType == .pickup, let pickupTime {
            return String(localized: "\(pickupTime) Uhr", bundle: .appLanguage)
        }
        let minutes = orderType == .delivery ? 40 : 20
        let readyAt = Date(timeIntervalSince1970: Double(createdAt) / 1000).addingTimeInterval(Double(minutes * 60))
        return String(localized: "ca. \(readyAt.formatted(date: .omitted, time: .shortened)) Uhr", bundle: .appLanguage)
    }

    var estimatedHint: String {
        switch orderType {
        case .pickup: return String(localized: "Zu deiner gewählten Abholzeit", bundle: .appLanguage)
        case .delivery: return String(localized: "Du kannst den Fahrer live verfolgen, sobald er losfährt", bundle: .appLanguage)
        case .dineIn: return String(localized: "In etwa \(20) Minuten an deinem Tisch", bundle: .appLanguage)
        }
    }
}
