//
//  DriverView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Fahrer-Bereich: oben die eigene Tour in Lieferreihenfolge, darunter alle abholbereiten Lieferungen.
/// Der Standort wird gesendet, solange dieser Screen offen ist
struct DriverView: View {

    let restaurantId: String
    let restaurantName: String
    let driverName: String

    @StateObject private var driverViewModel = DriverViewModel()
    @Environment(\.openURL) private var openURL

    var body: some View {
        Group {
            if driverViewModel.isLoading {
                LoadingView()
            } else if let errorMessage = driverViewModel.errorMessage {
                ErrorView(message: errorMessage)
            } else {
                deliveryList
            }
        }
        .screenBackground()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 0) {
                    Text(driverName)
                        .font(AppFont.titleMedium)
                        .lineLimit(1)
                    Text(restaurantName)
                        .font(AppFont.bodySmall)
                        .foregroundColor(AppColors.onSurfaceVariant)
                }
            }
        }
        .onAppear {
            driverViewModel.fetchDeliveries(restaurantId: restaurantId, driverName: driverName)
        }
        .onDisappear {
            driverViewModel.removeListener()
        }
    }

    private var deliveryList: some View {
        let tour = driverViewModel.tour
        let tourRunning = tour.contains { $0.status == .unterwegs }
        let hasWaiting = tour.contains { $0.status == .angenommen }

        return ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Meine Tour (\(tour.count))")
                        .font(AppFont.titleLarge)

                    if let trackingError = driverViewModel.trackingError {
                        Text(trackingError)
                            .font(AppFont.bodySmall)
                            .foregroundColor(AppColors.error)
                    }

                    if driverViewModel.isTracking {
                        Text("Live-Standort wird gesendet")
                            .font(AppFont.bodySmall)
                            .foregroundColor(AppColors.tertiary)
                    }

                    // losfahren, oder nach einem Neustart das Senden wieder aufnehmen
                    if hasWaiting || (tourRunning && !driverViewModel.isTracking) {
                        Button {
                            driverViewModel.startTour()
                        } label: {
                            if hasWaiting {
                                Text("Tour starten")
                            } else {
                                Text("Standort wieder senden")
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .padding(.top, 4)
                    }

                    if tour.isEmpty {
                        Text("Nimm unten Lieferungen an, um deine Tour zu planen.")
                            .font(AppFont.bodyMedium)
                            .foregroundColor(AppColors.onSurfaceVariant)
                    }
                }

                ForEach(Array(tour.enumerated()), id: \.element.id) { index, order in
                    DriverOrderCardView(order: order, position: index + 1) {
                        if index == 0 && order.status == .unterwegs {
                            Button("Zugestellt") {
                                driverViewModel.finishDelivery(order)
                            }
                            .buttonStyle(PrimaryButtonStyle())
                        }

                        Button("Navigation") {
                            openNavigation(order)
                        }
                        .buttonStyle(OutlineButtonStyle())

                        Button {
                            driverViewModel.move(order, direction: -1)
                        } label: {
                            Image(systemName: "chevron.up")
                        }
                        .disabled(index == 0)
                        .accessibilityLabel("Früher liefern")

                        Button {
                            driverViewModel.move(order, direction: 1)
                        } label: {
                            Image(systemName: "chevron.down")
                        }
                        .disabled(index == tour.count - 1)
                        .accessibilityLabel("Später liefern")
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Abholbereit (\(driverViewModel.available.count))")
                        .font(AppFont.titleLarge)

                    if driverViewModel.available.isEmpty {
                        Text("Gerade wartet keine Lieferung.")
                            .font(AppFont.bodyMedium)
                            .foregroundColor(AppColors.onSurfaceVariant)
                    }
                }
                .padding(.top, 12)

                ForEach(driverViewModel.available) { order in
                    DriverOrderCardView(order: order) {
                        Button("Annehmen") {
                            driverViewModel.accept(order)
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                }
            }
            .padding(16)
        }
    }

    /// Apple Karten mit Route zur Lieferadresse
    private func openNavigation(_ order: FireOrder) {
        let destination = order.deliveryLocation.map { "\($0.latitude),\($0.longitude)" } ?? order.deliveryAddress ?? ""
        var components = URLComponents(string: "https://maps.apple.com/")
        components?.queryItems = [
            URLQueryItem(name: "daddr", value: destination),
            URLQueryItem(name: "dirflg", value: "d")
        ]
        if let url = components?.url {
            openURL(url)
        }
    }
}

/// Eine Lieferung im Fahrer-Bereich. Die Buttons kommen von außen,
/// weil sie bei "Abholbereit" und "Meine Tour" verschieden sind
struct DriverOrderCardView<Actions: View>: View {
    let order: FireOrder
    // Platz in der Tour, nil = keine Nummer
    var position: Int?
    @ViewBuilder let actions: () -> Actions

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                if let position {
                    Text("\(position)")
                        .font(AppFont.labelLarge)
                        .foregroundColor(AppColors.onPrimary)
                        .frame(width: 28, height: 28)
                        .background(AppColors.primary)
                        .clipShape(Circle())
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(order.customerDisplayName)
                        .font(AppFont.titleMedium)
                    Group {
                        if let address = order.deliveryAddress {
                            Text(address)
                        } else {
                            Text("Keine Adresse")
                        }
                    }
                    .font(AppFont.bodyMedium)
                    .foregroundColor(AppColors.onSurfaceVariant)
                }
                .padding(.leading, position != nil ? 10 : 0)
                .frame(maxWidth: .infinity, alignment: .leading)

                StatusBadgeView(status: order.status)
                    .padding(.leading, 8)
            }

            Text(order.itemsText)
                .font(AppFont.bodySmall)
                .foregroundColor(AppColors.onSurfaceVariant)

            // wichtig für den Fahrer: muss er noch kassieren?
            Text("\(order.totalPrice.euro) · \(order.paymentMethod.title)")
                .font(AppFont.titleSmall)
                .foregroundColor(AppColors.primary)

            HStack(spacing: 8) {
                actions()
            }
            .padding(.top, 6)
        }
        .padding(16)
        .cardStyle()
    }
}

#Preview {
    NavigationStack {
        DriverView(restaurantId: "1", restaurantName: "Shisha Lounge", driverName: "Omar")
    }
}
