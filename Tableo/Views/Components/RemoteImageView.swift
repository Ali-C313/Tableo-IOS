//
//  RemoteImageView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Bild aus dem Netz. Solange es lädt oder fehlt, steht ein Platzhalter da
struct RemoteImageView: View {
    let url: String
    var placeholderFontSize: CGFloat = 11

    var body: some View {
        AsyncImage(url: URL(string: url)) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .scaledToFill()
            } else if phase.error != nil {
                ImagePlaceholderView(fontSize: placeholderFontSize)
            } else {
                AppColors.surfaceVariant
            }
        }
    }
}

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
    VStack {
        RemoteImageView(url: "https://picsum.photos/300")
            .frame(width: 150, height: 150)
        ImagePlaceholderView()
            .frame(width: 150, height: 150)
    }
}
