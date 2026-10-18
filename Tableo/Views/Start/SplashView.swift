//
//  SplashView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Kurzer Ladebildschirm mit Logo. Meldet Gäste dabei anonym an
struct SplashView: View {

    @EnvironmentObject var userViewModel: UserViewModel
    @Binding var showSplash: Bool

    @State private var visible = false

    var body: some View {
        VStack(spacing: 12) {
            Image("splash_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .accessibilityLabel("App-Logo")

            Text("Tableo")
                .font(AppFont.headlineMedium)
                .foregroundColor(AppColors.primary)
        }
        .opacity(visible ? 1 : 0)
        .scaleEffect(visible ? 1 : 0.85)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .screenBackground()
        .task {
            withAnimation(.easeOut(duration: 0.6)) {
                visible = true
            }
            // Logo soll mindestens kurz zu sehen sein
            async let minimumTime: Void = Task.sleep(for: .milliseconds(1200))
            await userViewModel.ensureSignedIn()
            try? await minimumTime

            withAnimation {
                showSplash = false
            }
        }
    }
}

#Preview {
    SplashView(showSplash: .constant(true))
        .environmentObject(UserViewModel())
}
