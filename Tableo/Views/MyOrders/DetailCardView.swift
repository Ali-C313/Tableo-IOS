//
//  DetailCardView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Gleiche Karte für alle Abschnitte
struct DetailCardView<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle(shadow: false)
    }
}

#Preview {
    DetailCardView {
        Text("Deine Bestellung")
        Text("2× Doppelapfel")
    }
    .padding()
}
