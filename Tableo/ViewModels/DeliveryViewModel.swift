//
//  DeliveryViewModel.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Abholung oder Lieferung und die Lieferadresse. Wird gespeichert und ist nach dem Neustart wieder da
@MainActor
class DeliveryViewModel: ObservableObject {

    @Published var deliveryMode: DeliveryMode {
        didSet { UserDefaults.standard.set(deliveryMode.rawValue, forKey: "delivery_mode") }
    }

    @Published var address: DeliveryAddress?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let defaults = UserDefaults.standard

    init() {
        let defaults = UserDefaults.standard
        deliveryMode = DeliveryMode(rawValue: defaults.string(forKey: "delivery_mode") ?? "") ?? .abholung

        // Adresse vom letzten Mal
        if let text = defaults.string(forKey: "delivery_address_text") {
            let coordinates = Coordinates(
                latitude: defaults.double(forKey: "delivery_address_lat"),
                longitude: defaults.double(forKey: "delivery_address_lng")
            )
            address = DeliveryAddress(text: text, coordinates: coordinates)
        }
    }

    /// Fragt nach der Freigabe und macht aus dem Standort die Lieferadresse
    func useCurrentLocation(onDone: @escaping () -> Void) {
        isLoading = true
        errorMessage = nil

        LocationManager.shared.requestPermission { allowed in
            guard allowed else {
                self.isLoading = false
                self.errorMessage = String(localized: "Ohne Standort-Freigabe bitte die Adresse eintippen", bundle: .appLanguage)
                return
            }
            LocationManager.shared.currentAddress { address in
                self.isLoading = false
                guard let address else {
                    self.errorMessage = String(localized: "Standort nicht verfügbar", bundle: .appLanguage)
                    return
                }
                self.saveAddress(address)
                onDone()
            }
        }
    }

    /// Sucht die eingetippte Adresse
    func searchAddress(_ query: String, onDone: @escaping () -> Void) {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        isLoading = true
        errorMessage = nil

        LocationManager.shared.searchAddress(trimmed) { address in
            self.isLoading = false
            guard let address else {
                self.errorMessage = String(localized: "Adresse nicht gefunden", bundle: .appLanguage)
                return
            }
            self.saveAddress(address)
            onDone()
        }
    }

    private func saveAddress(_ newAddress: DeliveryAddress) {
        address = newAddress
        defaults.set(newAddress.text, forKey: "delivery_address_text")
        defaults.set(newAddress.coordinates.latitude, forKey: "delivery_address_lat")
        defaults.set(newAddress.coordinates.longitude, forKey: "delivery_address_lng")
    }
}
