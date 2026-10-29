//
//  EmptyStateView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

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
    EmptyStateView(text: "Noch keine Bestellungen.")
}
