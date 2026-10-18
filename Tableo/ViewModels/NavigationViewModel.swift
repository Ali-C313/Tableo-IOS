//
//  NavigationViewModel.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Merkt sich den Tab und für jeden Tab seinen eigenen NavigationStack
@MainActor
class NavigationViewModel: ObservableObject {

    @Published var selectedTab: AppTab = .home
    @Published var homePath: [Route] = []
    @Published var ordersPath: [Route] = []
    @Published var settingsPath: [Route] = []

    /// Öffnet einen Screen im aktuellen Tab
    func push(_ route: Route) {
        switch selectedTab {
        case .home: homePath.append(route)
        case .orders: ordersPath.append(route)
        case .settings: settingsPath.append(route)
        }
    }

    /// Einen Screen zurück
    func pop() {
        switch selectedTab {
        case .home: _ = homePath.popLast()
        case .orders: _ = ordersPath.popLast()
        case .settings: _ = settingsPath.popLast()
        }
    }

    /// Ersetzt alle Screens im aktuellen Tab, z.B. nach dem Bestellen oder Login
    func replaceStack(_ routes: [Route]) {
        switch selectedTab {
        case .home: homePath = routes
        case .orders: ordersPath = routes
        case .settings: settingsPath = routes
        }
    }

    /// Wechselt den Tab und geht dort auf die Startseite
    func switchTab(_ tab: AppTab) {
        selectedTab = tab
        replaceStack([])
    }
}
