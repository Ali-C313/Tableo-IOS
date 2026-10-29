//
//  ErrorView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

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

#Preview {
    ErrorView(message: "Keine Verbindung")
}
