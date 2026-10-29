//
//  SettingsRowView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Antippbare Zeile: Icon, Titel, optional Untertitel, Pfeil rechts
struct SettingsRowView: View {
    let icon: String
    let title: LocalizedStringKey
    var subtitle: LocalizedStringKey?
    var showChevron = true
    // z.B. rot für "Abmelden"
    var tint: Color?
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(tint ?? AppColors.onSurfaceVariant)
                    .frame(width: 24)
                    .padding(.trailing, 12)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(AppFont.bodyLarge)
                        .foregroundColor(tint ?? AppColors.onSurface)
                    if let subtitle {
                        Text(subtitle)
                            .font(AppFont.bodySmall)
                            .foregroundColor(AppColors.onSurfaceVariant)
                            .multilineTextAlignment(.leading)
                    }
                }
                Spacer()

                if showChevron {
                    Image(systemName: "chevron.forward")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.onSurfaceVariant)
                }
            }
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(alignment: .leading) {
        SectionTitleView(text: "Dein Konto")
        SettingsGroupView {
            SettingsRowView(icon: "person.fill", title: "Persönliche Daten", subtitle: "Profilbild, Name, E-Mail und Passwort") {}
            GroupDividerView()
            SettingsRowView(icon: "trash.fill", title: "Konto löschen", showChevron: false, tint: AppColors.error) {}
        }
    }
    .padding()
}
