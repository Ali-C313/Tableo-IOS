//
//  StaffMenuItemRowView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Zeile mit Foto, Verfügbarkeit und Löschen
struct StaffMenuItemRowView: View {
    let item: FireMenuItem
    @ObservedObject var staffMenuViewModel: StaffMenuViewModel

    @State private var showDeleteAlert = false

    var body: some View {
        HStack(spacing: 12) {
            Group {
                if item.imageUrl.isEmpty {
                    ImagePlaceholderView(fontSize: 9)
                } else {
                    RemoteImageView(url: item.imageUrl)
                }
            }
            .frame(width: 48, height: 48)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            NavigationLink(value: Route.editMenuItem(restaurantId: item.restaurantId, menuItemId: item.id)) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name)
                        .font(AppFont.titleMedium)
                        .foregroundColor(AppColors.onSurface)
                    Text("\(item.category) · \(item.price.euro)")
                        .font(AppFont.bodySmall)
                        .foregroundColor(AppColors.onSurfaceVariant)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Toggle("", isOn: Binding(
                get: { item.available },
                set: { staffMenuViewModel.setAvailability(item, available: $0) }
            ))
            .labelsHidden()

            Button {
                showDeleteAlert = true
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(AppColors.error)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Artikel löschen")
        }
        .padding(14)
        .cardStyle()
        .alert("Artikel löschen?", isPresented: $showDeleteAlert) {
            Button("Löschen", role: .destructive) {
                staffMenuViewModel.deleteItem(item)
            }
            Button("Abbrechen", role: .cancel) {}
        } message: {
            Text("\"\(item.name)\" wird endgültig aus der Speisekarte entfernt.")
        }
    }
}

#Preview {
    NavigationStack {
        StaffMenuItemRowView(
            item: FireMenuItem(restaurantId: "1", name: "Doppelapfel", price: 13.5, category: "Shisha"),
            staffMenuViewModel: StaffMenuViewModel()
        )
        .padding()
    }
}
