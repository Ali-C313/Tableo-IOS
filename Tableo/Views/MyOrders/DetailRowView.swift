//
//  DetailRowView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Eine Zeile "Bezeichnung ... Wert"
struct DetailRowView: View {
    let label: LocalizedStringKey
    let value: String

    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .foregroundColor(AppColors.onSurfaceVariant)
            Spacer(minLength: 16)
            Text(value)
                .multilineTextAlignment(.trailing)
        }
        .font(AppFont.bodyMedium)
        .padding(.vertical, 4)
    }
}

#Preview {
    DetailRowView(label: "Bezahlart", value: "Barzahlung")
        .padding()
}
