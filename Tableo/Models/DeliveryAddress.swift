//
//  DeliveryAddress.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Lieferadresse, eingetippt oder über den Standort
struct DeliveryAddress: Equatable {
    var text: String
    var coordinates: Coordinates
}
