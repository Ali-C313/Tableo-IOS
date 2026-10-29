//
//  ImagePlaceholderView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Platzhalter für fehlende Bilder
struct ImagePlaceholderView: View {
    var fontSize: CGFloat = 11

    var body: some View {
        ZStack {
            AppColors.surfaceVariant
            Text("Kein Bild vorhanden")
                .font(AppFont.text(size: fontSize, weight: 400))
                .multilineTextAlignment(.center)
                .foregroundColor(AppColors.onSurfaceVariant)
                .padding(4)
        }
    }
}

#Preview {
    ImagePlaceholderView()
        .frame(width: 120, height: 120)
}
