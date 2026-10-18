//
//  StaffAccess.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Restaurant und Profil eines Mitarbeiters.
/// Lieferanten landen im Fahrer-Bereich, alle anderen im Dashboard, die Leitung darf beides
struct StaffAccess {
    let restaurant: FireRestaurant
    let profile: FireStaffProfile

    var isDriver: Bool { profile.role == .lieferant }

    var canOpenDashboard: Bool { !isDriver }

    var canOpenDriverArea: Bool { isDriver || profile.role == .leitung }

    var driverRoute: Route {
        .driver(restaurantId: restaurant.id, restaurantName: restaurant.name,
                driverName: profile.name.isEmpty ? "Fahrer" : profile.name)
    }

    var dashboardRoute: Route {
        .dashboard(restaurantId: restaurant.id, restaurantName: restaurant.name)
    }
}
