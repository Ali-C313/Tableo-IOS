//
//  ProfileImageView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Rundes Profilbild. Ohne Bild zwei Buchstaben aus dem Namen ("Ali Chehab" -> "AC"),
/// ohne Namen einer aus der E-Mail, ohne beides ein Personen-Icon
struct ProfileImageView: View {
    var photoUrl: String = ""
    var name: String = ""
    var email: String = ""
    var size: CGFloat = 40

    var body: some View {
        ZStack {
            AppColors.primary

            if !photoUrl.isEmpty {
                RemoteImageView(url: photoUrl)
                    .accessibilityLabel("Profilbild")
            } else if let initials {
                Text(initials)
                    .font(AppFont.display(size: size * 0.4, weight: 500))
                    .foregroundColor(AppColors.onPrimary)
            } else {
                Image(systemName: "person.fill")
                    .foregroundColor(AppColors.onPrimary)
                    .accessibilityLabel("Konto")
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    private var initials: String? {
        let words = name.split(separator: " ")
        if let first = words.first {
            let last = words.count > 1 ? String(words[words.count - 1].prefix(1)) : ""
            return (String(first.prefix(1)) + last).uppercased()
        }
        return email.isEmpty ? nil : email.prefix(1).uppercased()
    }
}

#Preview {
    HStack {
        ProfileImageView(name: "Ali Chehab")
        ProfileImageView(email: "ali@test.de", size: 64)
        ProfileImageView()
    }
}
