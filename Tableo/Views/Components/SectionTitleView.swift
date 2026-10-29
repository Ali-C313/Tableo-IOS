//
//  SectionTitleView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Überschrift für einen Bereich
struct SectionTitleView: View {
    let text: LocalizedStringKey

    var body: some View {
        Text(text)
            .font(AppFont.titleMedium)
            .foregroundColor(AppColors.onSurfaceVariant)
            .padding(.leading, 4)
            .padding(.top, 24)
            .padding(.bottom, 8)
    }
}

#Preview {
    SectionTitleView(text: "Dein Konto")
}
