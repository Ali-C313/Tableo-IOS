//
//  StateViews.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Ladekreis in der Mitte
struct LoadingView: View {
    var body: some View {
        ProgressView()
            .tint(AppColors.primary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Fehlertext in der Mitte
struct ErrorView: View {
    let message: String

    var body: some View {
        Text("Fehler: \(message)")
            .font(AppFont.bodyMedium)
            .foregroundColor(AppColors.error)
            .multilineTextAlignment(.center)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Hinweis, wenn eine Liste leer ist
struct EmptyStateView: View {
    let text: LocalizedStringKey

    var body: some View {
        Text(text)
            .font(AppFont.bodyMedium)
            .foregroundColor(AppColors.onSurfaceVariant)
            .multilineTextAlignment(.center)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    VStack {
        LoadingView()
        ErrorView(message: "Keine Verbindung")
        EmptyStateView(text: "Noch keine Bestellungen.")
    }
}
