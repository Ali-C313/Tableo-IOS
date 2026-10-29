//
//  RootView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Erst Splash, beim ersten Start das Onboarding, danach die Tabs.
/// Setzt Erscheinungsbild und Sprache, beim Sprachwechsel wird alles neu gezeichnet
struct RootView: View {

    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var orderUpdatesViewModel: OrderUpdatesViewModel
    @EnvironmentObject var shiftViewModel: ShiftViewModel

    @State private var showSplash = true

    var body: some View {
        ZStack {
            if showSplash {
                SplashView(showSplash: $showSplash)
                    .transition(.opacity)
            } else if !settingsViewModel.onboardingCompleted {
                OnboardingView()
                    .transition(.opacity)
            } else {
                MainTabView()
                    .transition(.opacity)
            }
        }
        .animation(.default, value: settingsViewModel.onboardingCompleted)
        .id(settingsViewModel.language)
        .font(AppFont.bodyLarge)
        .tint(AppColors.primary)
        .preferredColorScheme(settingsViewModel.themeMode.colorScheme)
        .environment(\.locale, settingsViewModel.language.locale)
        .environment(\.layoutDirection, settingsViewModel.language.isRightToLeft ? .rightToLeft : .leftToRight)
        .onChange(of: userViewModel.userId, initial: true) {
            // Kunden bekommen Nachrichten zu ihren Bestellungen, Personal im Dienst zu neuen Bestellungen
            orderUpdatesViewModel.start(userId: userViewModel.userId)
            shiftViewModel.start(userId: userViewModel.userId)
        }
    }
}

#Preview {
    RootView()
        .environmentObject(UserViewModel())
        .environmentObject(SettingsViewModel())
        .environmentObject(NavigationViewModel())
        .environmentObject(CartViewModel())
        .environmentObject(DeliveryViewModel())
        .environmentObject(OrderUpdatesViewModel())
        .environmentObject(ShiftViewModel())
}
