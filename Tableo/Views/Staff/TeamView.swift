//
//  TeamView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Team eines Restaurants mit Bild, Rolle und wer gerade im Dienst ist.
/// Antippen zeigt Details, Rolle und Entfernen
struct TeamView: View {

    let restaurantId: String
    let restaurantName: String

    @StateObject private var teamViewModel = TeamViewModel()

    // nur die ID merken, damit das Sheet neue Rollen direkt aus der Liste zeigt
    @State private var selectedId: String?

    var body: some View {
        VStack(spacing: 0) {
            restaurantIdCard

            if teamViewModel.isLoading {
                LoadingView()
            } else if teamViewModel.staff.isEmpty {
                EmptyStateView(text: "Noch kein Team registriert.")
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(teamViewModel.staff) { profile in
                            StaffRowView(profile: profile, isMe: profile.userId == teamViewModel.currentUserId) {
                                selectedId = profile.id
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
        }
        .screenBackground()
        .navigationTitle("Team · \(restaurantName)")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            teamViewModel.fetchTeam(restaurantId: restaurantId)
        }
        .onDisappear {
            teamViewModel.removeListener()
        }
        .sheet(isPresented: Binding(
            get: { selectedId != nil },
            set: { if !$0 { selectedId = nil } }
        )) {
            if let profile = teamViewModel.staff.first(where: { $0.id == selectedId }) {
                StaffDetailSheet(profile: profile, teamViewModel: teamViewModel) {
                    selectedId = nil
                }
            }
        }
    }

    /// Die ID gibt der Chef neuen Mitarbeitern zum Registrieren
    private var restaurantIdCard: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Restaurant-ID für neue Mitarbeiter")
                .font(AppFont.labelMedium)
            Text(restaurantId)
                .font(AppFont.titleMedium)
                .foregroundColor(AppColors.primary)
                .textSelection(.enabled)
            Text("Beim Registrieren \"Ich arbeite in einem Restaurant\" einschalten und diese ID eintragen.")
                .font(AppFont.bodySmall)
                .foregroundColor(AppColors.onSurfaceVariant)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle(radius: 14, shadow: false)
        .padding(16)
    }
}

#Preview {
    NavigationStack {
        TeamView(restaurantId: "abc123", restaurantName: "Shisha Lounge")
    }
}
