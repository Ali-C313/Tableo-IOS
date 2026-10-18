//
//  DeleteAccountSheet.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Sicherheitsabfrage mit Passwort, bevor das Konto zum Löschen vorgemerkt wird
struct DeleteAccountSheet: View {

    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var navigationViewModel: NavigationViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var password = ""

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                Text("Dein Konto wird abgemeldet und in 30 Tagen endgültig gelöscht, samt Team-Zugang und Profilbild. Meldest du dich vorher wieder an, bleibt es bestehen.")
                    .font(AppFont.bodyMedium)

                Text("Passwort zur Bestätigung")
                    .font(AppFont.labelMedium)
                    .foregroundColor(AppColors.onSurfaceVariant)

                PasswordFieldView(password: $password, isError: userViewModel.deleteError != nil) {
                    if !password.isEmpty && !userViewModel.isDeleting {
                        deleteAccount()
                    }
                }

                if let deleteError = userViewModel.deleteError {
                    Text(deleteError)
                        .font(AppFont.bodySmall)
                        .foregroundColor(AppColors.error)
                }

                Button {
                    deleteAccount()
                } label: {
                    if userViewModel.isDeleting {
                        Text("Wird gelöscht…")
                    } else {
                        Text("Konto löschen")
                    }
                }
                .buttonStyle(OutlineButtonStyle(color: AppColors.error))
                .disabled(password.isEmpty || userViewModel.isDeleting)
                .padding(.top, 8)

                Spacer()
            }
            .padding(20)
            .navigationTitle("Konto löschen?")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                    .disabled(userViewModel.isDeleting)
                }
            }
        }
        .presentationDetents([.medium])
        .interactiveDismissDisabled(userViewModel.isDeleting)
        .onDisappear {
            userViewModel.deleteError = nil
        }
    }

    private func deleteAccount() {
        userViewModel.deleteAccount(currentPassword: password) {
            dismiss()
            navigationViewModel.switchTab(.home)
        }
    }
}

#Preview {
    DeleteAccountSheet()
        .environmentObject(UserViewModel())
        .environmentObject(NavigationViewModel())
}
