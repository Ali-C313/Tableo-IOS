//
//  OnboardingView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Beim allerersten Start: Willkommen, Cookies, Standort. Danach nie wieder
struct OnboardingView: View {

    @EnvironmentObject var settingsViewModel: SettingsViewModel

    @State private var page = 0

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $page) {
                OnboardingPageView(
                    title: "Willkommen",
                    description: "Bestelle bei deinen Lieblingsrestaurants – am Tisch oder zum Abholen.",
                    primaryButton: "Los geht's",
                    onPrimary: { withAnimation { page = 1 } }
                ) {
                    Image("splash_logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                }
                .tag(0)

                OnboardingPageView(
                    title: "Deine Cookie-Einstellungen",
                    description: "Wir nutzen Cookies, um dir die App bereitzustellen. Du kannst das jederzeit in den Einstellungen ändern.",
                    primaryButton: "Alle erlauben",
                    onPrimary: { withAnimation { page = 2 } },
                    secondaryButton: "Nur notwendig",
                    onSecondary: { withAnimation { page = 2 } }
                ) {
                    Text("🍪").font(.system(size: 57))
                }
                .tag(1)

                OnboardingPageView(
                    title: "Wo genau befindest du dich?",
                    description: "Teile deinen Standort, damit wir dir Restaurants in deiner Nähe zeigen können.",
                    primaryButton: "Standort teilen",
                    onPrimary: { settingsViewModel.finishOnboarding(askForLocation: true) },
                    secondaryButton: "Überspringen",
                    onSecondary: { settingsViewModel.finishOnboarding(askForLocation: false) }
                ) {
                    Text("📍").font(.system(size: 57))
                }
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            // Punkte unten
            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(page == index ? AppColors.primary : AppColors.outline)
                        .frame(width: page == index ? 10 : 8, height: page == index ? 10 : 8)
                }
            }
            .padding(.bottom, 24)
        }
        .screenBackground()
    }
}

#Preview {
    OnboardingView()
        .environmentObject(SettingsViewModel())
}
