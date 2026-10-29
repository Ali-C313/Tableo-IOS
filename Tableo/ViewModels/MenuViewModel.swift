//
//  MenuViewModel.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseFirestore

/// Speisekarte eines Restaurants und die Wechselkurse für die Preise
@MainActor
class MenuViewModel: ObservableObject {

    @Published var menuItems: [FireMenuItem] = []
    @Published var isLoading = true
    @Published var errorMessage: String?

    // Kurs von 1 Euro, z.B. ["USD": 1.08]
    @Published var rates: [String: Double] = [:]

    private let database = FirebaseManager.shared.database
    private var listener: ListenerRegistration?
    private let exchangeRateRepository: ExchangeRateRepositoryProtocol

    init(exchangeRateRepository: ExchangeRateRepositoryProtocol = ExchangeRateRepository()) {
        self.exchangeRateRepository = exchangeRateRepository
    }

    func fetchMenu(restaurantId: String) {
        // alten Listener entfernen, sonst laufen zwei gleichzeitig
        listener?.remove()
        listener = database.collection("menuItems")
            .whereField("restaurantId", isEqualTo: restaurantId)
            .addSnapshotListener { querySnapshot, error in
                self.isLoading = false
                if let error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                guard let documents = querySnapshot?.documents else { return }
                self.menuItems = documents.compactMap { try? $0.data(as: FireMenuItem.self) }
                self.errorMessage = nil
            }
    }

    func removeListener() {
        listener?.remove()
        listener = nil
    }

    func fetchRates() {
        // nur einmal laden
        guard rates.isEmpty else { return }
        Task {
            do {
                rates = try await exchangeRateRepository.fetchRates(currencies: ["USD", "GBP", "TRY"])
            } catch {
                // ohne Kurse bleiben die Preise in Euro
                print("Wechselkurse nicht geladen: \(error.localizedDescription)")
            }
        }
    }

    /// Kategorien aus den geladenen Artikeln, nicht fest im Code
    var categoryNames: [String] {
        Array(Set(menuItems.map { $0.category }.filter { !$0.isEmpty })).sorted()
    }
}
