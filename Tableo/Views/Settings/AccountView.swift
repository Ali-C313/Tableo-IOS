//
//  AccountView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI
import PhotosUI

/// Profilbild, Name, E-Mail und Passwort ändern.
/// Das aktuelle Passwort wird nur gebraucht, wenn sich E-Mail oder Passwort ändern
struct AccountView: View {

    @EnvironmentObject var userViewModel: UserViewModel

    @State private var name = ""
    @State private var email = ""
    @State private var newPassword = ""
    @State private var currentPassword = ""
    @State private var pickedPhoto: PhotosPickerItem?

    private var nameChanged: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && name != (userViewModel.user?.displayName ?? "")
    }

    private var emailChanged: Bool {
        email != userViewModel.email
    }

    private var needsCurrentPassword: Bool {
        emailChanged || !newPassword.isEmpty
    }

    private var passwordValid: Bool {
        newPassword.isEmpty || newPassword.count >= 6
    }

    private var canSave: Bool {
        (nameChanged || emailChanged || !newPassword.isEmpty)
            && email.isValidEmail && passwordValid
            && (!needsCurrentPassword || !currentPassword.isEmpty)
            && !userViewModel.isLoading
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Profilbild, das auch der Chef in der Team-Liste sieht
                VStack(spacing: 4) {
                    PhotosPicker(selection: $pickedPhoto, matching: .images) {
                        ZStack {
                            ProfileImageView(
                                photoUrl: userViewModel.photoUrl,
                                name: userViewModel.user?.displayName ?? "",
                                email: userViewModel.email,
                                size: 96
                            )
                            if userViewModel.isUploadingPhoto {
                                ProgressView()
                                    .frame(width: 96, height: 96)
                                    .background(Color.black.opacity(0.3))
                                    .clipShape(Circle())
                            }
                        }
                    }

                    PhotosPicker(selection: $pickedPhoto, matching: .images) {
                        Group {
                            if userViewModel.photoUrl.isEmpty {
                                Text("Profilbild hinzufügen")
                            } else {
                                Text("Profilbild ändern")
                            }
                        }
                        .font(AppFont.labelLarge)
                    }
                    .disabled(userViewModel.isUploadingPhoto)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 8)

                fieldLabel("Name")
                TextField("", text: $name)
                    .textContentType(.name)
                    .fieldStyle()

                fieldLabel("E-Mail-Adresse")
                TextField("", text: $email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .fieldStyle(isError: !email.isEmpty && !email.isValidEmail)

                fieldLabel("Neues Passwort")
                PasswordFieldView(password: $newPassword, placeholder: "Leer lassen, wenn es bleiben soll", isError: !passwordValid)
                if !passwordValid {
                    Text("Mindestens 6 Zeichen.")
                        .font(AppFont.labelSmall)
                        .foregroundColor(AppColors.error)
                        .padding(.top, 2)
                }

                if needsCurrentPassword {
                    fieldLabel("Aktuelles Passwort")
                    PasswordFieldView(password: $currentPassword)
                    Text("Zur Sicherheit nötig, wenn du E-Mail oder Passwort änderst.")
                        .font(AppFont.bodySmall)
                        .foregroundColor(AppColors.onSurfaceVariant)
                        .padding(.top, 4)
                }

                Button {
                    userViewModel.saveAccountInfo(name: name, email: email, currentPassword: currentPassword, newPassword: newPassword)
                } label: {
                    if userViewModel.isLoading {
                        Text("Wird gespeichert…")
                    } else {
                        Text("Änderungen speichern")
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(!canSave)
                .padding(.top, 32)

                if let errorMessage = userViewModel.errorMessage {
                    Text(errorMessage)
                        .font(AppFont.bodyMedium)
                        .foregroundColor(AppColors.error)
                        .padding(.top, 12)
                }

                if let infoMessage = userViewModel.infoMessage {
                    Text(infoMessage)
                        .font(AppFont.bodyMedium)
                        .foregroundColor(AppColors.secondary)
                        .padding(.top, 12)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .scrollDismissesKeyboard(.interactively)
        .screenBackground()
        .navigationTitle("Kontoinformationen")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            name = userViewModel.user?.displayName ?? ""
            email = userViewModel.email
            userViewModel.errorMessage = nil
            userViewModel.infoMessage = nil
        }
        // nach dem Speichern die Passwortfelder leeren
        .onChange(of: userViewModel.infoMessage) {
            if userViewModel.infoMessage != nil {
                newPassword = ""
                currentPassword = ""
            }
        }
        .onChange(of: pickedPhoto) {
            guard let pickedPhoto else { return }
            Task {
                // iPhone-Fotos sind oft HEIC, deshalb als JPEG hochladen
                if let data = try? await pickedPhoto.loadTransferable(type: Data.self),
                   let jpeg = UIImage(data: data)?.jpegData(compressionQuality: 0.8) {
                    userViewModel.uploadProfilePhoto(jpeg)
                }
                self.pickedPhoto = nil
            }
        }
    }

    private func fieldLabel(_ text: LocalizedStringKey) -> some View {
        Text(text)
            .font(AppFont.labelMedium)
            .foregroundColor(AppColors.onSurfaceVariant)
            .padding(.top, 16)
            .padding(.bottom, 4)
    }
}

#Preview {
    NavigationStack {
        AccountView()
    }
    .environmentObject(UserViewModel())
}
