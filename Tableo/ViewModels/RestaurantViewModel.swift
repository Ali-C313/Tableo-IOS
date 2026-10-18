//
//  RestaurantViewModel.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseFirestore

/// Alle Restaurants für die Startseite, live aus Firestore
@MainActor
class RestaurantViewModel: ObservableObject {

    @Published var restaurants: [FireRestaurant] = []
    @Published var isLoading = true
    @Published var errorMessage: String?

    private let database = FirebaseManager.shared.database
    private var listener: ListenerRegistration?

    func fetchRestaurants() {
        // alten Listener entfernen, sonst laufen zwei gleichzeitig
        listener?.remove()
        listener = database.collection("restaurants")
            .addSnapshotListener { querySnapshot, error in
                self.isLoading = false
                if let error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                guard let documents = querySnapshot?.documents else { return }
                self.restaurants = documents.compactMap { try? $0.data(as: FireRestaurant.self) }
                self.errorMessage = nil
            }
    }

    func removeListener() {
        listener?.remove()
        listener = nil
    }
}
