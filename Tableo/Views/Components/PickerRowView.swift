//
//  PickerRowView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Zeile mit Icon und Titel links, Auswahl rechts
struct PickerRowView<Picker: View>: View {
    let icon: String
    let title: LocalizedStringKey
    @ViewBuilder let picker: () -> Picker

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(AppColors.onSurfaceVariant)
                .frame(width: 24)
                .padding(.trailing, 12)
            Text(title)
                .font(AppFont.bodyLarge)
            Spacer()
            picker()
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    PickerRowView(icon: "globe", title: "Sprache") {
        Text("Deutsch")
    }
    .padding()
}
