//
//  ArchiveView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Erledigte und stornierte Bestellungen eines Restaurants
struct ArchiveView: View {

    let restaurantId: String
    let restaurantName: String

    @StateObject private var archiveViewModel = ArchiveViewModel()

    var body: some View {
        Group {
            if archiveViewModel.isLoading {
                LoadingView()
            } else if let errorMessage = archiveViewModel.errorMessage {
                ErrorView(message: errorMessage)
            } else if archiveViewModel.orders.isEmpty {
                EmptyStateView(text: "Noch keine abgeschlossenen Bestellungen.")
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(archiveViewModel.orders) { order in
                            archiveCard(order)
                        }
                    }
                    .padding(16)
                }
            }
        }
        .screenBackground()
        .navigationTitle("Archiv · \(restaurantName)")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            archiveViewModel.fetchArchive(restaurantId: restaurantId)
        }
        .onDisappear {
            archiveViewModel.removeListener()
        }
    }

    private func archiveCard(_ order: FireOrder) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(order.orderTypeText)
                .font(AppFont.titleMedium)

            if order.status == .storniert {
                Group {
                    if order.cancelledByRestaurant {
                        Text("Storniert vom Restaurant")
                    } else {
                        Text("Storniert vom Kunden")
                    }
                }
                .font(AppFont.labelMedium)
                .foregroundColor(AppColors.error)
            }

            Text("\(order.orderNumber) · \(order.customerDisplayName) · \(order.createdAt.dateTimeText)")
                .font(AppFont.labelSmall)
                .foregroundColor(AppColors.onSurfaceVariant)

            Text(order.itemsText)
                .font(AppFont.bodySmall)
                .foregroundColor(AppColors.onSurfaceVariant)

            if let address = order.deliveryAddress, !address.isEmpty {
                Text(address)
                    .font(AppFont.bodySmall)
                    .foregroundColor(AppColors.onSurfaceVariant)
            }

            Text(order.totalPrice.euro)
                .font(AppFont.titleMedium)
                .foregroundColor(AppColors.primary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}

#Preview {
    NavigationStack {
        ArchiveView(restaurantId: "1", restaurantName: "Shisha Lounge")
    }
}
