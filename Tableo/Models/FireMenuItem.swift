//
//  FireMenuItem.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseFirestore

/// Artikel der Speisekarte aus der Collection "menuItems"
struct FireMenuItem: Codable, Identifiable, Hashable {
    @DocumentID var documentId: String?

    var restaurantId: String = ""
    var name: String = ""
    var description: String = ""
    // Preis in Euro
    var price: Double = 0
    // freier Text, jedes Restaurant hat eigene Kategorien
    var category: String = ""
    // leer = kein Bild
    var imageUrl: String = ""
    var available: Bool = true

    var id: String { documentId ?? "" }

    enum CodingKeys: String, CodingKey {
        case documentId, restaurantId, name, description, price, category, imageUrl, available
    }

    init(documentId: String? = nil, restaurantId: String, name: String, description: String = "",
         price: Double, category: String, imageUrl: String = "", available: Bool = true) {
        self.documentId = documentId
        self.restaurantId = restaurantId
        self.name = name
        self.description = description
        self.price = price
        self.category = category
        self.imageUrl = imageUrl
        self.available = available
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _documentId = try container.decode(DocumentID<String>.self, forKey: .documentId)
        restaurantId = try container.decodeIfPresent(String.self, forKey: .restaurantId) ?? ""
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        description = try container.decodeIfPresent(String.self, forKey: .description) ?? ""
        price = try container.decodeIfPresent(Double.self, forKey: .price) ?? 0
        category = try container.decodeIfPresent(String.self, forKey: .category) ?? ""
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl) ?? ""
        available = try container.decodeIfPresent(Bool.self, forKey: .available) ?? true
    }
}
