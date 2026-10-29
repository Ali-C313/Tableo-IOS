//
//  OnboardingPageView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Eine Seite im Onboarding: Bild, Titel, Text und ein oder zwei Buttons
struct OnboardingPageView<Artwork: View>: View {

    let title: LocalizedStringKey
    let description: LocalizedStringKey
    let primaryButton: LocalizedStringKey
    let onPrimary: () -> Void
    var secondaryButton: LocalizedStringKey?
    var onSecondary: () -> Void = {}
    @ViewBuilder let artwork: () -> Artwork

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            artwork()

            Text(title)
                .font(AppFont.headlineSmall)
                .multilineTextAlignment(.center)
                .padding(.top, 32)

            Text(description)
                .font(AppFont.bodyMedium)
                .foregroundColor(AppColors.onSurfaceVariant)
                .multilineTextAlignment(.center)
                .padding(.top, 12)

            Button(primaryButton, action: onPrimary)
                .buttonStyle(PrimaryButtonStyle())
                .padding(.top, 32)

            if let secondaryButton {
                Button(secondaryButton, action: onSecondary)
                    .buttonStyle(OutlineButtonStyle())
                    .padding(.top, 12)
            }
            Spacer()
        }
        .padding(32)
    }
}

#Preview {
    OnboardingPageView(
        title: "Willkommen",
        description: "Bestelle bei deinen Lieblingsrestaurants – am Tisch oder zum Abholen.",
        primaryButton: "Los geht's",
        onPrimary: {}
    ) {
        Text("🍪").font(.system(size: 57))
    }
}
