//
//  TableoApp.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI
import FirebaseCore

@main
struct TableoApp: App {

    @StateObject private var userViewModel = UserViewModel()
    @StateObject private var settingsViewModel = SettingsViewModel()
    @StateObject private var navigationViewModel = NavigationViewModel()
    @StateObject private var cartViewModel = CartViewModel()
    @StateObject private var deliveryViewModel = DeliveryViewModel()
    @StateObject private var orderUpdatesViewModel = OrderUpdatesViewModel()
    @StateObject private var shiftViewModel = ShiftViewModel()

    init() {
        // liest die GoogleService-Info.plist, muss vor allem anderen passieren
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        NotificationManager.shared.requestPermission()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(userViewModel)
                .environmentObject(settingsViewModel)
                .environmentObject(navigationViewModel)
                .environmentObject(cartViewModel)
                .environmentObject(deliveryViewModel)
                .environmentObject(orderUpdatesViewModel)
                .environmentObject(shiftViewModel)
        }
    }
}
