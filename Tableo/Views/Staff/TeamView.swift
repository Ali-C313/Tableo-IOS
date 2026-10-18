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

/// Eine Zeile in der Team-Liste
struct StaffRowView: View {
    let profile: FireStaffProfile
    let isMe: Bool
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            HStack(spacing: 14) {
                ProfileImageView(photoUrl: profile.photoUrl, name: profile.name, email: profile.email, size: 48)

                VStack(alignment: .leading, spacing: 2) {
                    Group {
                        if isMe {
                            Text("\(profile.name) (Du)")
                        } else {
                            Text(profile.name)
                        }
                    }
                    .font(AppFont.titleMedium)
                    .foregroundColor(AppColors.onSurface)
                    .lineLimit(1)

                    HStack(spacing: 10) {
                        Text(profile.role.title)
                            .font(AppFont.bodyMedium)
                            .foregroundColor(profile.role == .ohne ? AppColors.onSurfaceVariant : AppColors.primary)

                        if profile.onDuty {
                            // grüner Punkt
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(AppColors.onDutyGreen)
                                    .frame(width: 8, height: 8)
                                Text("Im Dienst")
                                    .font(AppFont.labelMedium)
                                    .foregroundColor(AppColors.onDutyGreen)
                            }
                        }
                    }
                }
                Spacer()

                Image(systemName: "chevron.forward")
                    .foregroundColor(AppColors.onSurfaceVariant)
                    .accessibilityLabel("Details")
            }
            .padding(12)
            .cardStyle(color: AppColors.surface, radius: 14, shadow: false)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        TeamView(restaurantId: "abc123", restaurantName: "Shisha Lounge")
    }
}
