//
//  OrderUpdatesViewModel.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseFirestore

/// Beobachtet die Bestellungen des Kunden und schickt eine Benachrichtigung,
/// wenn sich etwas Wichtiges ändert, z.B. "Deine Bestellung ist unterwegs"
@MainActor
class OrderUpdatesViewModel: ObservableObject {

    private let database = FirebaseManager.shared.database
    private var listener: ListenerRegistration?
    private var observedUserId: String?

    // letzter Schritt pro Bestellung. Der Fahrer-Standort ändert sich ständig,
    // deshalb nur bei einem neuen Schritt benachrichtigen
    private var lastStep: [String: String] = [:]

    /// Mehrfach aufrufen ist kein Problem
    func start(userId: String?) {
        if userId == observedUserId { return }
        stop()
        guard let userId else { return }
        observedUserId = userId

        // alten Listener entfernen, sonst laufen zwei gleichzeitig

        listener?.remove()

        listener = database.collection("orders")
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { querySnapshot, error in
                // nur ein Extra, Fehler zeigt die Bestellliste selbst
                guard let documents = querySnapshot?.documents else { return }
                let orders = documents.compactMap { try? $0.data(as: FireOrder.self) }
                for order in orders {
                    self.checkForUpdate(order)
                }
            }
    }

    func stop() {
        listener?.remove()
        listener = nil
        observedUserId = nil
        lastStep.removeAll()
    }

    private func checkForUpdate(_ order: FireOrder) {
        let step = stepOf(order)
        let before = lastStep.updateValue(step, forKey: order.id)
        // beim ersten Laden nur merken
        guard let before, before != step else { return }
        guard let message = messageFor(order, step: step) else { return }
        NotificationManager.shared.show(id: order.id, title: message.title, text: message.text)
    }

    /// z.B. "UNTERWEGS_NAECHSTER" oder "UNTERWEGS_PLATZ_3"
    private func stepOf(_ order: FireOrder) -> String {
        let position = order.tourPosition ?? 1
        if order.status == .unterwegs && position <= 1 { return "UNTERWEGS_NAECHSTER" }
        if order.status == .unterwegs { return "UNTERWEGS_PLATZ_\(position)" }
        return order.status.rawValue
    }

    private func messageFor(_ order: FireOrder, step: String) -> (title: String, text: String)? {
        // nur der Vorname
        let driver = order.driverName?.firstName ?? String(localized: "Der Fahrer", bundle: .appLanguage)
        let ordersBefore = (order.tourPosition ?? 1) - 1
        let restaurant = order.restaurantName

        if step == "UNTERWEGS_NAECHSTER" {
            return (String(localized: "Deine Bestellung ist unterwegs", bundle: .appLanguage),
                    String(localized: "\(driver) ist jetzt auf dem Weg zu dir. Verfolge ihn live in der App.", bundle: .appLanguage))
        }
        if step.hasPrefix("UNTERWEGS_PLATZ_") {
            return (String(localized: "Fahrer ist unterwegs", bundle: .appLanguage),
                    String(localized: "\(driver) liefert vorher noch \(ordersBefore) Bestellung(en), dann bist du dran.", bundle: .appLanguage))
        }

        switch (order.status, order.orderType) {
        case (.angenommen, _):
            return (String(localized: "Fahrer gefunden", bundle: .appLanguage),
                    String(localized: "\(driver) bringt dir gleich deine Bestellung von \(restaurant).", bundle: .appLanguage))
        case (.fertig, .pickup):
            return (String(localized: "Deine Bestellung ist fertig", bundle: .appLanguage),
                    String(localized: "Du kannst sie jetzt bei \(restaurant) abholen.", bundle: .appLanguage))
        case (.fertig, .dineIn):
            let table = order.tableNumber.map(String.init) ?? ""
            return (String(localized: "Deine Bestellung ist fertig", bundle: .appLanguage),
                    String(localized: "Sie kommt gleich an Tisch \(table).", bundle: .appLanguage))
        // selbst storniert braucht keine Nachricht
        case (.storniert, _) where order.cancelledByRestaurant:
            return (String(localized: "Bestellung storniert", bundle: .appLanguage),
                    String(localized: "\(restaurant) hat deine Bestellung storniert.", bundle: .appLanguage))
        case (.erledigt, .delivery):
            return (String(localized: "Zugestellt", bundle: .appLanguage),
                    String(localized: "Guten Appetit!", bundle: .appLanguage))
        default:
            return nil
        }
    }
}
