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

#Preview {
    NavigationStack {
        StaffMenuView(restaurantId: "1", restaurantName: "Shisha Lounge")
    }
}
