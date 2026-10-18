//
//  DeliveryHeaderView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Kopfzeile der Startseite: links die Adresse, rechts der Schalter Lieferung/Abholung
struct DeliveryHeaderView: View {

    @EnvironmentObject var deliveryViewModel: DeliveryViewModel
    let onAddressClick: () -> Void

    var body: some View {
        HStack {
            Button(action: onAddressClick) {
                HStack(spacing: 2) {
                    Group {
                        if let address = deliveryViewModel.address {
                            // nur Straße und Hausnummer
                            Text(address.text.components(separatedBy: ",").first ?? address.text)
                        } else {
                            Text("Adresse eingeben")
                        }
                    }
                    .font(AppFont.display(size: 18, weight: 700))
                    .foregroundColor(AppColors.onBackground)
                    .lineLimit(1)

                    Image(systemName: "chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(AppColors.onBackground)
                        .accessibilityLabel("Adresse ändern")
                }
                .padding(.vertical, 4)
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .leading)

            // Kapsel mit Lieferung links und Abholung rechts
            HStack(spacing: 0) {
                modeButton(.lieferung, icon: "bicycle")
                modeButton(.abholung, icon: "takeoutbag.and.cup.and.straw")
            }
            .padding(3)
            .frame(height: 36)
            .background(AppColors.surfaceVariant)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(AppColors.outline))
            .padding(.leading, 8)
        }
    }

    /// Gewählt = weiße Kapsel mit Text, sonst nur das Icon
    private func modeButton(_ mode: DeliveryMode, icon: String) -> some View {
        let isSelected = deliveryViewModel.deliveryMode == mode

        return Button {
            deliveryViewModel.deliveryMode = mode
        } label: {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isSelected ? AppColors.primary : AppColors.onSurfaceVariant)

                if isSelected {
                    // die Kapsel ist auch im Dunkelmodus weiß, deshalb immer dunkle Schrift
                    Text(mode.title)
                        .font(AppFont.labelMedium)
                        .foregroundColor(AppColors.espresso)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, isSelected ? 12 : 8)
            .frame(height: 30)
            .background(isSelected ? Color.white : .clear)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(isSelected ? 0.15 : 0), radius: 2, y: 1)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(mode.title)
        .animation(.easeInOut(duration: 0.25), value: isSelected)
    }
}

#Preview {
    DeliveryHeaderView(onAddressClick: {})
        .padding()
        .environmentObject(DeliveryViewModel())
}
