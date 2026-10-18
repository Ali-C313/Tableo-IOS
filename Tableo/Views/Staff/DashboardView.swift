//
//  DashboardView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Offene Bestellungen fürs Personal. Oben der Dienst-Schalter,
/// oben rechts Speisekarte, Team, Statistik und Archiv
struct DashboardView: View {

    let restaurantId: String
    let restaurantName: String

    @StateObject private var dashboardViewModel = DashboardViewModel()
    @EnvironmentObject var shiftViewModel: ShiftViewModel
    @EnvironmentObject var navigationViewModel: NavigationViewModel

    var body: some View {
        VStack(spacing: 0) {
            // nur bei Mitarbeitern mit eigenem Profil
            if let profile = shiftViewModel.profile {
                dutyToggle(onDuty: profile.onDuty)
            }

            if dashboardViewModel.isLoading {
                LoadingView()
            } else if let errorMessage = dashboardViewModel.errorMessage {
                ErrorView(message: errorMessage)
            } else if dashboardViewModel.orders.isEmpty {
                EmptyStateView(text: "Aktuell keine offenen Bestellungen.")
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(dashboardViewModel.orders) { order in
                            StaffOrderCardView(
                                order: order,
                                onAdvance: { dashboardViewModel.advanceStatus(order) },
                                onDone: { dashboardViewModel.markAsDone(order) },
                                onCancel: { dashboardViewModel.cancelOrder(order) }
                            )
                        }
                    }
                    .padding(16)
                }
            }
        }
        .screenBackground()
        .navigationTitle(restaurantName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Menü") {
                        navigationViewModel.push(.staffMenu(restaurantId: restaurantId, restaurantName: restaurantName))
                    }
                    Button("Team") {
                        navigationViewModel.push(.team(restaurantId: restaurantId, restaurantName: restaurantName))
                    }
                    Button("Statistik") {
                        navigationViewModel.push(.analytics(restaurantId: restaurantId, restaurantName: restaurantName))
                    }
                    Button("Archiv") {
                        navigationViewModel.push(.archive(restaurantId: restaurantId, restaurantName: restaurantName))
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .accessibilityLabel("Mehr")
                }
            }
        }
        .onAppear {
            dashboardViewModel.fetchActiveOrders(restaurantId: restaurantId)
        }
        .onDisappear {
            dashboardViewModel.removeListener()
        }
    }

    /// An = Nachricht bei jeder neuen Bestellung, aus = Ruhe
    private func dutyToggle(onDuty: Bool) -> some View {
        Toggle(isOn: Binding(
            get: { onDuty },
            set: { shiftViewModel.setOnDuty($0) }
        )) {
            VStack(alignment: .leading, spacing: 2) {
                Group {
                    if onDuty {
                        Text("Im Dienst")
                    } else {
                        Text("Nicht im Dienst")
                    }
                }
                .font(AppFont.titleMedium)

                Group {
                    if onDuty {
                        Text("Du bekommst eine Nachricht bei neuen Bestellungen")
                    } else {
                        Text("Keine Nachrichten zu neuen Bestellungen")
                    }
                }
                .font(AppFont.bodySmall)
                .foregroundColor(AppColors.onSurfaceVariant)
            }
        }
        .tint(AppColors.primary)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .cardStyle(color: onDuty ? AppColors.primary.opacity(0.18) : AppColors.surfaceContainer, shadow: false)
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        DashboardView(restaurantId: "1", restaurantName: "Shisha Lounge")
    }
    .environmentObject(ShiftViewModel())
    .environmentObject(NavigationViewModel())
}
