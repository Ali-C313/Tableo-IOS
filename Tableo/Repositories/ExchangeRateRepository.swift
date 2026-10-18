//
//  ExchangeRateRepository.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Wechselkurse von der frankfurter.app
class ExchangeRateRepository: ExchangeRateRepositoryProtocol {

    func fetchRates(currencies: [String]) async throws -> [String: Double] {
        let urlString = "https://api.frankfurter.app/latest?from=EUR&to=\(currencies.joined(separator: ","))"

        guard let url = URL(string: urlString) else {
            throw HTTPError.invalidURL
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(ExchangeRateResponse.self, from: data)
        return response.rates
    }
}
