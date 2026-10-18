//
//  Coordinates.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import CoreLocation

/// Punkt auf der Karte, z.B. Standort des Fahrers
struct Coordinates: Codable, Hashable {
    var latitude: Double
    var longitude: Double

    var clCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// Luftlinie in Kilometern
    func distanceInKm(to other: Coordinates) -> Double {
        let from = CLLocation(latitude: latitude, longitude: longitude)
        let to = CLLocation(latitude: other.latitude, longitude: other.longitude)
        return from.distance(from: to) / 1000
    }
}
