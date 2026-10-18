//
//  FireRestaurant.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseFirestore

/// Restaurant oder Shisha-Bar aus der Collection "restaurants"
struct FireRestaurant: Codable, Identifiable, Hashable {
    // Android speichert zusätzlich ein Feld "id", deshalb heißt die Dokument-ID hier anders
    @DocumentID var documentId: String?

    var name: String = ""
    // z.B. "Restaurant", "Shisha-Bar", "Café"
    var type: String = ""
    var address: String = ""
    // z.B. ["Burger", "Pizza"]
    var cuisineTypes: [String] = []
    var imageUrl: String = ""
    // Format "HH:mm"
    var openingTime: String = "00:00"
    var closingTime: String = "23:59"
    // false = nur Abholung und vor Ort
    var offersDelivery: Bool = true

    var id: String { documentId ?? "" }

    enum CodingKeys: String, CodingKey {
        case documentId, name, type, address, cuisineTypes, imageUrl, openingTime, closingTime, offersDelivery
    }

    init(documentId: String? = nil, name: String, type: String = "", address: String = "",
         cuisineTypes: [String] = [], imageUrl: String = "", openingTime: String = "00:00",
         closingTime: String = "23:59", offersDelivery: Bool = true) {
        self.documentId = documentId
        self.name = name
        self.type = type
        self.address = address
        self.cuisineTypes = cuisineTypes
        self.imageUrl = imageUrl
        self.openingTime = openingTime
        self.closingTime = closingTime
        self.offersDelivery = offersDelivery
    }

    // fehlende Felder bekommen Standardwerte, z.B. bei Restaurants aus der Firebase Console
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _documentId = try container.decode(DocumentID<String>.self, forKey: .documentId)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        type = try container.decodeIfPresent(String.self, forKey: .type) ?? ""
        address = try container.decodeIfPresent(String.self, forKey: .address) ?? ""
        cuisineTypes = try container.decodeIfPresent([String].self, forKey: .cuisineTypes) ?? []
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl) ?? ""
        openingTime = try container.decodeIfPresent(String.self, forKey: .openingTime) ?? "00:00"
        closingTime = try container.decodeIfPresent(String.self, forKey: .closingTime) ?? "23:59"
        offersDelivery = try container.decodeIfPresent(Bool.self, forKey: .offersDelivery) ?? true
    }

    /// Hat gerade geöffnet, klappt auch über Mitternacht (z.B. 18:00 - 02:00)
    var isOpenNow: Bool {
        let open = minutes(openingTime)
        let close = minutes(closingTime)
        // ungültiges Format -> lieber offen anzeigen
        guard let open, let close else { return true }
        let components = Calendar.current.dateComponents([.hour, .minute], from: Date())
        let now = (components.hour ?? 0) * 60 + (components.minute ?? 0)
        if close > open {
            return now >= open && now < close
        }
        return now >= open || now < close
    }

    /// "14:30" -> 870
    private func minutes(_ time: String) -> Int? {
        let parts = time.split(separator: ":")
        guard parts.count == 2, let hours = Int(parts[0]), let minutes = Int(parts[1]) else { return nil }
        return hours * 60 + minutes
    }
}
