//
//  LocationManager.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import CoreLocation

/// Standort über CoreLocation, Adressen über den CLGeocoder
class LocationManager: NSObject, CLLocationManagerDelegate {

    static let shared = LocationManager()

    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()

    // wird bei jedem neuen Standort aufgerufen
    private var onLocation: ((CLLocation) -> Void)?
    private var onPermission: ((Bool) -> Void)?
    // nur für die Abfrage der Adresse, danach wieder aus
    private var singleRequest = false

    override private init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        // für den Fahrer nur alle 10 Meter
        manager.distanceFilter = 10
    }

    var isAllowed: Bool {
        manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways
    }

    /// Fragt nach "Beim Verwenden der App". Ist schon entschieden, kommt die Antwort sofort
    func requestPermission(completion: @escaping (Bool) -> Void) {
        if manager.authorizationStatus == .notDetermined {
            onPermission = completion
            manager.requestWhenInUseAuthorization()
        } else {
            completion(isAllowed)
        }
    }

    /// Einmal den Standort holen und daraus eine Adresse machen
    func currentAddress(completion: @escaping (DeliveryAddress?) -> Void) {
        singleRequest = true
        onLocation = { [weak self] location in
            self?.address(for: location, completion: completion)
        }
        manager.requestLocation()
    }

    /// Eingetippte Adresse suchen
    func searchAddress(_ query: String, completion: @escaping (DeliveryAddress?) -> Void) {
        geocoder.geocodeAddressString(query) { [weak self] placemarks, error in
            guard let placemark = placemarks?.first, let location = placemark.location else {
                completion(nil)
                return
            }
            let text = self?.format(placemark) ?? ""
            completion(DeliveryAddress(
                text: text.isEmpty ? query : text,
                coordinates: Coordinates(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            ))
        }
    }

    /// Laufende Updates für den Fahrer
    func startUpdating(onChange: @escaping (Coordinates) -> Void) {
        singleRequest = false
        onLocation = { location in
            onChange(Coordinates(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
        }
        manager.startUpdatingLocation()
    }

    func stopUpdating() {
        manager.stopUpdatingLocation()
        onLocation = nil
    }

    private func address(for location: CLLocation, completion: @escaping (DeliveryAddress?) -> Void) {
        let coordinates = Coordinates(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, _ in
            // klappt die Adresse nicht, stehen die Koordinaten da
            let text = placemarks?.first.map { self?.format($0) ?? "" } ?? ""
            completion(DeliveryAddress(
                text: text.isEmpty ? "\(coordinates.latitude), \(coordinates.longitude)" : text,
                coordinates: coordinates
            ))
        }
    }

    /// "Straße Nr, PLZ Ort"
    private func format(_ placemark: CLPlacemark) -> String {
        let street = [placemark.thoroughfare, placemark.subThoroughfare].compactMap { $0 }.joined(separator: " ")
        let city = [placemark.postalCode, placemark.locality].compactMap { $0 }.joined(separator: " ")
        return [street, city].filter { !$0.isEmpty }.joined(separator: ", ")
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard manager.authorizationStatus != .notDetermined else { return }
        onPermission?(isAllowed)
        onPermission = nil
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        onLocation?(location)
        if singleRequest {
            singleRequest = false
            onLocation = nil
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Standort-Fehler: \(error.localizedDescription)")
    }
}
