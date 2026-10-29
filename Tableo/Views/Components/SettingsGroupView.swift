//
//  SettingsGroupView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Mehrere Zeilen in einer abgerundeten Karte, wie in den iPhone-Einstellungen
struct SettingsGroupView<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            content()
        }
        .padding(.horizontal, 16)
        .cardStyle(shadow: false)
    }
}

#Preview {
    SettingsGroupView {
        SettingsRowView(icon: "person.fill", title: "Persönliche Daten") {}
        GroupDividerView()
        SettingsRowView(icon: "list.bullet", title: "Meine Bestellungen") {}
    }
    .padding()
}
