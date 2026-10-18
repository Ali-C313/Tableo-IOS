//
//  OrderItem.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Position einer Bestellung. Name und Preis werden beim Bestellen kopiert,
/// damit spätere Preisänderungen alte Bestellungen nicht verändern
struct OrderItem: Codable, Hashable {
    var menuItemId: String
    var name: String
    var pricePerItem: Double
    var quantity: Int

    var subtotal: Double {
        pricePerItem * Double(quantity)
    }
}
