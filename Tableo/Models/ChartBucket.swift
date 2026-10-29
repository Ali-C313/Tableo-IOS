//
//  ChartBucket.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Ein Balken in der Statistik
struct ChartBucket: Identifiable {
    let id = UUID()
    let label: String
    let revenue: Double
}
