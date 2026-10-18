//
//  LoginView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Anmelden und Registrieren für Kunden und Mitarbeiter, umschaltbar unten.
/// Beim Registrieren kann man eine Restaurant-ID angeben, im Team oder als Fahrer
struct LoginView: View {

    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var navigationViewModel: NavigationViewModel

    @State private var isRegisterMode = false
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isStaff = false
    @State private var isDriver = false
    @State private var restaurantId = ""

    private var isPasswordValid: Bool {
        password.count >= 6
    }

    private var canSubmit: Bool {
        let staffDataValid = !isRegisterMode || !isStaff || !restaurantId.trimmingCharacters(in: .whitespaces).isEmpty
        let nameValid = !isRegisterMode || !name.trimmingCharacters(in: .whitespaces).isEmpty
        return nameValid && email.isValidEmail && isPasswordValid && staffDataValid && !userViewModel.isLoading
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Group {
                    if isRegisterMode {
                        Text("Konto erstellen")
                    } else {
                        Text("Anmelden")
                    }
                }
                .font(AppFont.headlineSmall)

                Text("Damit du deine Bestellungen und ihren Status siehst")
                    .font(AppFont.bodyMedium)
                    .foregroundColor(AppColors.onSurfaceVariant)
                    .multilineTextAlignment(.center)
                    .padding(.top, 6)
                    .padding(.bottom, 24)

                VStack(alignment: .leading, spacing: 12) {
                    if isRegisterMode {
                        LabeledFieldView(label: "Name", text: $name, contentType: .name)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        LabeledFieldView(
                            label: "E-Mail",
                            text: $email,
                            isError: !email.isEmpty && !email.isValidEmail,
                            keyboard: .emailAddress,
                            contentType: .emailAddress
                        )
                        if !email.isEmpty && !email.isValidEmail {
                            errorHint("Bitte eine gültige E-Mail-Adresse eingeben.")
                        }
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Passwort")
                            .font(AppFont.labelMedium)
                            .foregroundColor(AppColors.onSurfaceVariant)
                        // Enter meldet an bzw. registriert, wenn alles stimmt
                        PasswordFieldView(password: $password, isError: !password.isEmpty && !isPasswordValid) {
                            if canSubmit {
                                submit()
                            }
                        }
                        if !password.isEmpty && !isPasswordValid {
                            errorHint("Mindestens 6 Zeichen.")
                        }
                    }

                    // nur beim Registrieren: Mitarbeiter geben die ID ihres Restaurants an
                    if isRegisterMode {
                        Toggle("Ich arbeite in einem Restaurant", isOn: $isStaff)
                            .font(AppFont.bodyLarge)
                            .tint(AppColors.primary)
                            .padding(.top, 4)

                        if isStaff {
                            // Fahrer landen später im Fahrer-Bereich, alle anderen im Dashboard
                            HStack(spacing: 8) {
                                FilterChipView(label: String(localized: "Im Team", bundle: .appLanguage), selected: !isDriver) {
                                    isDriver = false
                                }
                                FilterChipView(label: String(localized: "Als Fahrer", bundle: .appLanguage), selected: isDriver) {
                                    isDriver = true
                                }
                            }
                            LabeledFieldView(
                                label: "Restaurant-ID",
                                text: $restaurantId,
                                hint: "Bekommst du von deinem Chef, steht im Personalbereich unter Team",
                                keyboard: .asciiCapable
                            )
                        }
                    }
                }

                if let errorMessage = userViewModel.errorMessage {
                    Text(errorMessage)
                        .font(AppFont.bodyMedium)
                        .foregroundColor(AppColors.error)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }

                if let infoMessage = userViewModel.infoMessage {
                    Text(infoMessage)
                        .font(AppFont.bodyMedium)
                        .foregroundColor(AppColors.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }

                Button {
                    submit()
                } label: {
                    HStack(spacing: 8) {
                        if userViewModel.isLoading {
                            ProgressView()
                                .tint(AppColors.onPrimary)
                        }
                        if isRegisterMode {
                            Text("Registrieren")
                        } else {
                            Text("Anmelden")
                        }
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(!canSubmit)
                .padding(.top, 20)

                if !isRegisterMode {
                    Button("Passwort vergessen?") {
                        userViewModel.sendPasswordReset(email: email)
                    }
                    .font(AppFont.labelLarge)
                    .disabled(!email.isValidEmail || userViewModel.isLoading)
                    .padding(.top, 12)
                }

                Button {
                    isRegisterMode.toggle()
                    userViewModel.errorMessage = nil
                    userViewModel.infoMessage = nil
                } label: {
                    if isRegisterMode {
                        Text("Ich habe schon ein Konto")
                    } else {
                        Text("Neu hier? Konto erstellen")
                    }
                }
                .font(AppFont.labelLarge)
                .padding(.top, 12)
            }
            .padding(24)
        }
        .scrollDismissesKeyboard(.interactively)
        .screenBackground()
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            userViewModel.errorMessage = nil
            userViewModel.infoMessage = nil
        }
        .alert("Willkommen zurück!", isPresented: $userViewModel.accountRestored) {
            Button("Weiter") {
                finish(userViewModel.finishRestore())
            }
        } message: {
            Text("Dein Konto war zum Löschen vorgemerkt. Weil du dich angemeldet hast, bleibt es bestehen.")
        }
    }

    private func submit() {
        if isRegisterMode {
            userViewModel.register(
                name: name,
                email: email,
                password: password,
                restaurantId: isStaff ? restaurantId : "",
                asDriver: isStaff && isDriver
            ) { access in
                finish(access)
            }
        } else {
            userViewModel.login(email: email, password: password) { access in
                finish(access)
            }
        }
    }

    /// Fahrer in den Fahrer-Bereich, Mitarbeiter ins Dashboard, Kunden zu ihren Bestellungen
    private func finish(_ access: StaffAccess?) {
        if let access {
            navigationViewModel.replaceStack([access.isDriver ? access.driverRoute : access.dashboardRoute])
        } else {
            navigationViewModel.switchTab(.orders)
        }
    }

    private func errorHint(_ text: LocalizedStringKey) -> some View {
        Text(text)
            .font(AppFont.labelSmall)
            .foregroundColor(AppColors.error)
    }
}

#Preview {
    NavigationStack {
        LoginView()
    }
    .environmentObject(UserViewModel())
    .environmentObject(NavigationViewModel())
}
