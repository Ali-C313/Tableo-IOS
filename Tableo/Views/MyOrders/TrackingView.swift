//
//  TrackingView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI
import MapKit

/// Lieferung live verfolgen. Sobald ein Fahrer die Bestellung hat, zeigt die Karte Fahrer und Adresse,
/// darunter die geschätzte Ankunft inklusive Umwege
struct TrackingView: View {

    let orderId: String

    @StateObject private var trackingViewModel = TrackingViewModel()
    @State private var position: MapCameraPosition = .automatic

    var body: some View {
        Group {
            if trackingViewModel.isLoading {
                LoadingView()
            } else if let order = trackingViewModel.order {
                VStack(spacing: 0) {
                    if isDriverOnTheWay(order), let driver = order.driverLocation {
                        map(driver: driver, destination: order.deliveryLocation)
                    } else {
                        Group {
                            if isDriverOnTheWay(order) {
                                Text("Warte auf den Standort des Fahrers…")
                            } else {
                                Text("Sobald ein Fahrer deine Bestellung hat, siehst du ihn hier live auf der Karte.")
                            }
                        }
                        .font(AppFont.bodyLarge)
                        .foregroundColor(AppColors.onSurfaceVariant)
                        .multilineTextAlignment(.center)
                        .padding(32)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }

                    infoCard(order)
                }
            } else if let errorMessage = trackingViewModel.errorMessage {
                ErrorView(message: errorMessage)
            }
        }
        .screenBackground()
        .navigationTitle("Lieferung verfolgen")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            trackingViewModel.fetchTracking(orderId: orderId)
        }
        .onDisappear {
            trackingViewModel.removeListener()
        }
    }

    private func isDriverOnTheWay(_ order: FireOrder) -> Bool {
        order.status == .angenommen || order.status == .unterwegs
    }

    /// Fahrer orange, Lieferadresse blau, beide immer im Bild
    private func map(driver: Coordinates, destination: Coordinates?) -> some View {
        Map(position: $position) {
            Marker("Fahrer", systemImage: "bicycle", coordinate: driver.clCoordinate)
                .tint(.orange)
            if let destination {
                Marker("Lieferadresse", systemImage: "house.fill", coordinate: destination.clCoordinate)
                    .tint(.blue)
            }
        }
        // Ausschnitt neu wählen, sobald sich der Fahrer bewegt
        .onChange(of: driver) {
            withAnimation {
                position = .automatic
            }
        }
    }

    /// Status, Ankunft und wie viele Lieferungen der Fahrer vorher noch hat
    private func infoCard(_ order: FireOrder) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            StatusBadgeView(status: order.status, doneLabel: "Zugestellt")

            Text(trackingViewModel.headline)
                .font(AppFont.headlineSmall)
                .foregroundColor(AppColors.primary)
                .padding(.top, 10)

            if let subline = trackingViewModel.subline {
                Text(subline)
                    .font(AppFont.bodyMedium)
                    .foregroundColor(AppColors.onSurfaceVariant)
                    .padding(.top, 4)
            }

            Text("\(order.restaurantName) · \(order.deliveryAddress ?? "")")
                .font(AppFont.bodySmall)
                .foregroundColor(AppColors.onSurfaceVariant)
                .padding(.top, 8)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle(shadow: false)
        .padding(16)
    }
}

#Preview {
    NavigationStack {
        TrackingView(orderId: "abc")
    }
}
