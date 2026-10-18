//
//  MainTabView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Die drei Tabs Start, Bestellungen und Konto, jeder mit eigenem NavigationStack
struct MainTabView: View {

    @EnvironmentObject var navigationViewModel: NavigationViewModel

    var body: some View {
        TabView(selection: $navigationViewModel.selectedTab) {
            NavigationStack(path: $navigationViewModel.homePath) {
                HomeView()
                    .navigationDestination(for: Route.self) { route in
                        RouteView(route: route)
                    }
            }
            .tabItem {
                Label("Start", systemImage: "house.fill")
            }
            .tag(AppTab.home)

            NavigationStack(path: $navigationViewModel.ordersPath) {
                MyOrdersView()
                    .navigationDestination(for: Route.self) { route in
                        RouteView(route: route)
                    }
            }
            .tabItem {
                Label("Bestellungen", systemImage: "list.bullet")
            }
            .tag(AppTab.orders)

            NavigationStack(path: $navigationViewModel.settingsPath) {
                SettingsView()
                    .navigationDestination(for: Route.self) { route in
                        RouteView(route: route)
                    }
            }
            .tabItem {
                Label("Konto", systemImage: "person.crop.circle.fill")
            }
            .tag(AppTab.settings)
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(UserViewModel())
        .environmentObject(SettingsViewModel())
        .environmentObject(NavigationViewModel())
        .environmentObject(CartViewModel())
        .environmentObject(DeliveryViewModel())
        .environmentObject(ShiftViewModel())
}
