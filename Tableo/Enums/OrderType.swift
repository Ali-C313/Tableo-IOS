//
//  OrderType.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

enum OrderType: String, Codable, CaseIterable {
    case dineIn = "DINE_IN"
    case pickup = "PICKUP"
    case delivery = "DELIVERY"
}
