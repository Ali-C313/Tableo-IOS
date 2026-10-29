//
//  RouteView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Baut zu jeder Route den passenden Screen
struct RouteView: View {

    let route: Route

    var body: some View {
        switch route {
        case .menu(let restaurantId, let restaurantName):
            MenuView(restaurantId: restaurantId, restaurantName: restaurantName)

        case .orderDetails(let restaurantId, let restaurantName):
            OrderDetailsView(restaurantId: restaurantId, restaurantName: restaurantName)

        case .cart(let restaurantId, let restaurantName, let orderType, let tableNumber, let pickupTime):
            CartView(
                restaurantId: restaurantId,
                restaurantName: restaurantName,
                orderType: orderType,
                tableNumber: tableNumber,
                pickupTime: pickupTime
            )

        case .orderConfirmation(let restaurantName):
            OrderConfirmationView(restaurantName: restaurantName)

        case .orderDetail(let orderId):
            OrderDetailView(orderId: orderId)

        case .tracking(let orderId):
            TrackingView(orderId: orderId)

        case .dashboard(let restaurantId, let restaurantName):
            DashboardView(restaurantId: restaurantId, restaurantName: restaurantName)

        case .archive(let restaurantId, let restaurantName):
            ArchiveView(restaurantId: restaurantId, restaurantName: restaurantName)

        case .staffMenu(let restaurantId, let restaurantName):
            StaffMenuView(restaurantId: restaurantId, restaurantName: restaurantName)

        case .editMenuItem(let restaurantId, let menuItemId):
            EditMenuItemView(restaurantId: restaurantId, menuItemId: menuItemId)

        case .team(let restaurantId, let restaurantName):
            TeamView(restaurantId: restaurantId, restaurantName: restaurantName)

        case .analytics(let restaurantId, let restaurantName):
            AnalyticsView(restaurantId: restaurantId, restaurantName: restaurantName)

        case .driver(let restaurantId, let restaurantName, let driverName):
            DriverView(restaurantId: restaurantId, restaurantName: restaurantName, driverName: driverName)

        case .login:
            LoginView()

        case .account:
            AccountView()

        case .legal(let page):
            LegalView(page: page)
        }
    }
}

#Preview {
    NavigationStack {
        RouteView(route: .legal(.impressum))
    }
}
