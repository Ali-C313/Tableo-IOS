//
//  LegalView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Impressum, Datenschutz oder AGB als Textseite.
/// Die langen Texte stehen über Schlüssel im String Catalog, z.B. "legal_imprint_info_text"
struct LegalView: View {

    let page: LegalPage

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(sections, id: \.self) { section in
                    Text(LocalizedStringKey("legal_\(section)_heading"))
                        .font(AppFont.titleMedium)
                        .padding(.top, 20)
                        .padding(.bottom, 6)
                    Text(LocalizedStringKey("legal_\(section)_text"))
                        .font(AppFont.bodyMedium)
                        .foregroundColor(AppColors.onSurfaceVariant)
                }

                Text("Stand: Oktober 2026")
                    .font(AppFont.labelSmall)
                    .foregroundColor(AppColors.onSurfaceVariant)
                    .padding(.top, 28)
                    .padding(.bottom, 24)
            }
            .textSelection(.enabled)
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
        .screenBackground()
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var title: LocalizedStringKey {
        switch page {
        case .impressum: return "Impressum"
        case .datenschutz: return "Datenschutz"
        case .agb: return "AGB"
        }
    }

    /// Abschnitte der Seite, Platzhalter in [eckigen Klammern] vor der Veröffentlichung füllen
    private var sections: [String] {
        switch page {
        case .impressum:
            return ["imprint_info", "imprint_contact", "imprint_responsible", "imprint_note", "imprint_dispute"]
        case .datenschutz:
            return ["privacy_controller", "privacy_data", "privacy_location", "privacy_staff", "privacy_services",
                    "privacy_device", "privacy_notifications", "privacy_deletion", "privacy_rights"]
        case .agb:
            return ["terms_scope", "terms_parties", "terms_order", "terms_prices",
                    "terms_delivery", "terms_account", "terms_liability", "terms_final"]
        }
    }
}

#Preview {
    NavigationStack {
        LegalView(page: .impressum)
    }
}
