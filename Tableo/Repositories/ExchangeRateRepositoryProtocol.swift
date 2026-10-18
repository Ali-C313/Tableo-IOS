//
//  ExchangeRateRepositoryProtocol.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

protocol ExchangeRateRepositoryProtocol {
    func fetchRates(currencies: [String]) async throws -> [String: Double]
}
