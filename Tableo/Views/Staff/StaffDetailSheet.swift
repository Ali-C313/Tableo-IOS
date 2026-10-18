//
//  StaffDetailSheet.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Details zu einem Mitarbeiter mit Rolle und Entfernen.
/// Nur die Leitung darf ändern, und nie sich selbst
struct StaffDetailSheet: View {

    let profile: FireStaffProfile
    @ObservedObject var teamViewModel: TeamViewModel
    let onRemoved: () -> Void

    @State private var showRemoveAlert = false

    private var isMe: Bool {
        profile.userId == teamViewModel.currentUserId
    }

    private var canEdit: Bool {
        teamViewModel.canManage && !isMe
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ProfileImageView(photoUrl: profile.photoUrl, name: profile.name, email: profile.email, size: 96)

                Text(profile.name)
                    .font(AppFont.headlineSmall)
                    .padding(.top, 12)

                if !profile.email.isEmpty {
                    Text(profile.email)
                        .font(AppFont.bodyMedium)
                        .foregroundColor(AppColors.onSurfaceVariant)
                        .textSelection(.enabled)
                }

                VStack(spacing: 0) {
                    HStack {
                        Text("Status")
                            .foregroundColor(AppColors.onSurfaceVariant)
                        Spacer()
                        if profile.onDuty {
                            Text("Im Dienst")
                        } else {
                            Text("Nicht im Dienst")
                        }
                    }
                    .padding(.vertical, 4)

                    if profile.joinedAt > 0 {
                        HStack {
                            Text("Dabei seit")
                                .foregroundColor(AppColors.onSurfaceVariant)
                            Spacer()
                            Text(profile.joinedAt.dateTimeText)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .font(AppFont.bodyLarge)
                .padding(.top, 20)

                Text("Rolle")
                    .font(AppFont.labelLarge)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 16)
                    .padding(.bottom, 8)

                // die eigene Rolle bleibt, damit man sich nicht aussperrt
                if canEdit {
                    DropdownView(
                        selected: profile.role,
                        options: StaffRole.allCases,
                        placeholder: String(localized: "Rolle wählen", bundle: .appLanguage),
                        fillWidth: true,
                        optionLabel: { $0.title }
                    ) { role in
                        teamViewModel.updateRole(profile, role: role)
                    }
                } else {
                    Text(profile.role.title)
                        .font(AppFont.bodyLarge)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if let errorMessage = teamViewModel.errorMessage {
                    Text(errorMessage)
                        .font(AppFont.bodyMedium)
                        .foregroundColor(AppColors.error)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 12)
                }

                if canEdit {
                    Button("Aus dem Team entfernen") {
                        showRemoveAlert = true
                    }
                    .buttonStyle(OutlineButtonStyle(color: AppColors.error))
                    .padding(.top, 28)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .onDisappear {
            teamViewModel.errorMessage = nil
        }
        .alert("\(profile.name) entfernen?", isPresented: $showRemoveAlert) {
            Button("Entfernen", role: .destructive) {
                teamViewModel.removeStaff(profile, onDone: onRemoved)
            }
            Button("Abbrechen", role: .cancel) {}
        } message: {
            Text("Das Konto bleibt bestehen, hat aber keinen Zugriff mehr auf das Dashboard.")
        }
    }
}

#Preview {
    StaffDetailSheet(
        profile: FireStaffProfile(restaurantId: "1", userId: "u1", name: "Omar Haddad", email: "omar@test.de", role: .kellner, joinedAt: 0),
        teamViewModel: TeamViewModel(),
        onRemoved: {}
    )
}
