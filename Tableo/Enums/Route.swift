//
//  Route.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Alle Screens, die man im NavigationStack öffnen kann
enum Route: Hashable {
    case menu(restaurantId: String, restaurantName: String)
    case orderDetails(restaurantId: String, restaurantName: String)
    case cart(restaurantId: String, restaurantName: String, orderType: OrderType, tableNumber: Int?, pickupTime: String?)
    case orderConfirmation(restaurantName: String)
    case orderDetail(orderId: String)
    case tracking(orderId: String)

    case dashboard(restaurantId: String, restaurantName: String)
    case archive(restaurantId: String, restaurantName: String)
    case staffMenu(restaurantId: String, restaurantName: String)
    // ohne menuItemId wird ein neuer Artikel angelegt
    case editMenuItem(restaurantId: String, menuItemId: String?)
    case team(restaurantId: String, restaurantName: String)
    case analytics(restaurantId: String, restaurantName: String)
    case driver(restaurantId: String, restaurantName: String, driverName: String)

    case login
    case account
    case legal(LegalPage)
}
