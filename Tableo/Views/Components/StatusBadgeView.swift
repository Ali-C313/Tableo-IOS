//
//  StatusBadgeView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Farbige Kapsel mit dem Status einer Bestellung
struct StatusBadgeView: View {
    let status: OrderStatus
    // beim Personal "Erledigt", beim Kunden "Abgeschlossen"
    var doneLabel: LocalizedStringKey = "Erledigt"

    var body: some View {
        Text(label)
            .font(AppFont.labelMedium)
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.16))
            .clipShape(Capsule())
    }

    private var label: LocalizedStringKey {
        switch status {
        case .offen: return "Neu"
        case .inZubereitung: return "In Zubereitung"
        case .fertig: return "Fertig"
        case .abholbereit: return "Abholbereit"
        case .angenommen: return "Beim Fahrer"
        case .unterwegs: return "Unterwegs"
        case .erledigt, .bezahlt: return doneLabel
        case .storniert: return "Storniert"
        }
    }

    private var color: Color {
        switch status {
        case .offen, .inZubereitung: return AppColors.primary
        case .fertig, .erledigt, .bezahlt: return AppColors.secondary
        case .abholbereit, .angenommen, .unterwegs: return AppColors.tertiary
        case .storniert: return AppColors.error
        }
    }
}

#Preview {
    VStack {
        StatusBadgeView(status: .offen)
        StatusBadgeView(status: .unterwegs)
        StatusBadgeView(status: .erledigt, doneLabel: "Abgeschlossen")
        StatusBadgeView(status: .storniert)
    }
}
