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
            Tab("Start", systemImage: "house.fill", value: AppTab.home) {
                NavigationStack(path: $navigationViewModel.homePath) {
                    HomeView()
                        .navigationDestination(for: Route.self) { route in
                            RouteView(route: route)
                        }
                }
            }

            Tab("Bestellungen", systemImage: "list.bullet", value: AppTab.orders) {
                NavigationStack(path: $navigationViewModel.ordersPath) {
                    MyOrdersView()
                        .navigationDestination(for: Route.self) { route in
                            RouteView(route: route)
                        }
                }
            }

            Tab("Konto", systemImage: "person.crop.circle.fill", value: AppTab.settings) {
                NavigationStack(path: $navigationViewModel.settingsPath) {
                    SettingsView()
                        .navigationDestination(for: Route.self) { route in
                            RouteView(route: route)
                        }
                }
            }
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
