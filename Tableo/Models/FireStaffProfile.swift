//
//  FireStaffProfile.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseFirestore

/// Mitarbeiter eines Restaurants aus "staffProfiles". Die Dokument-ID ist die User-ID
struct FireStaffProfile: Codable, Identifiable, Hashable {
    @DocumentID var documentId: String?

    var restaurantId: String = ""
    var userId: String = ""
    var name: String = ""
    var email: String = ""
    var photoUrl: String = ""
    var role: StaffRole = .ohne
    // seit wann im Team (Millisekunden), 0 bei alten Einträgen
    var joinedAt: Int64 = 0
    // im Dienst = bekommt Nachrichten zu neuen Bestellungen
    var onDuty: Bool = false

    var id: String { documentId ?? userId }

    enum CodingKeys: String, CodingKey {
        case documentId, restaurantId, userId, name, email, photoUrl, role, joinedAt, onDuty
    }

    init(restaurantId: String, userId: String, name: String, email: String, photoUrl: String = "",
         role: StaffRole, joinedAt: Int64) {
        self.restaurantId = restaurantId
        self.userId = userId
        self.name = name
        self.email = email
        self.photoUrl = photoUrl
        self.role = role
        self.joinedAt = joinedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _documentId = try container.decode(DocumentID<String>.self, forKey: .documentId)
        restaurantId = try container.decodeIfPresent(String.self, forKey: .restaurantId) ?? ""
        userId = try container.decodeIfPresent(String.self, forKey: .userId) ?? ""
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        email = try container.decodeIfPresent(String.self, forKey: .email) ?? ""
        photoUrl = try container.decodeIfPresent(String.self, forKey: .photoUrl) ?? ""
        role = try container.decodeIfPresent(StaffRole.self, forKey: .role) ?? .ohne
        joinedAt = try container.decodeIfPresent(Int64.self, forKey: .joinedAt) ?? 0
        onDuty = try container.decodeIfPresent(Bool.self, forKey: .onDuty) ?? false
    }
}
