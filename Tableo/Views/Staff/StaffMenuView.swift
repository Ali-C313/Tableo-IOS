//
//  StaffMenuView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Speisekarte verwalten: ansehen, bearbeiten, verfügbar oder ausverkauft schalten
struct StaffMenuView: View {

    let restaurantId: String
    let restaurantName: String

    @StateObject private var staffMenuViewModel = StaffMenuViewModel()

    var body: some View {
        Group {
            if staffMenuViewModel.isLoading {
                LoadingView()
            } else if let errorMessage = staffMenuViewModel.errorMessage {
                ErrorView(message: errorMessage)
            } else if staffMenuViewModel.menuItems.isEmpty {
                EmptyStateView(text: "Noch keine Artikel angelegt.")
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(staffMenuViewModel.menuItems) { item in
                            StaffMenuItemRowView(item: item, staffMenuViewModel: staffMenuViewModel)
                        }
                    }
                    .padding(16)
                }
            }
        }
        .screenBackground()
        .navigationTitle("Speisekarte · \(restaurantName)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(value: Route.editMenuItem(restaurantId: restaurantId, menuItemId: nil)) {
                    Text("+ Neu")
                }
            }
        }
        .onAppear {
            staffMenuViewModel.fetchMenu(restaurantId: restaurantId)
        }
        .onDisappear {
            staffMenuViewModel.removeListener()
        }
    }
}

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
        StaffMenuView(restaurantId: "1", restaurantName: "Shisha Lounge")
    }
}
