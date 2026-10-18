//
//  ExchangeRateResponse.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Antwort der Wechselkurs-API (frankfurter.app)
struct ExchangeRateResponse: Codable {
    let amount: Double
    let base: String
    let date: String
    let rates: [String: Double]
}
