//
//  SettingsView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Konto-Seite: oben die Begrüßung mit Profilbild, darunter Konto, Personal, Einstellungen und Rechtliches
struct SettingsView: View {

    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var navigationViewModel: NavigationViewModel

    @State private var showLinkSheet = false
    @State private var showDeleteSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Begrüßung links, Profilbild rechts
                HStack {
                    Group {
                        if userViewModel.isLoggedIn && !userViewModel.displayName.isEmpty {
                            // für die Begrüßung reicht der Vorname
                            Text("Hallo, \(userViewModel.displayName.firstName)!")
                        } else {
                            Text("Hallo!")
                        }
                    }
                    .font(AppFont.headlineSmall)

                    Spacer()

                    NavigationLink(value: userViewModel.isLoggedIn ? Route.account : Route.login) {
                        ProfileImageView(
                            photoUrl: userViewModel.photoUrl,
                            name: userViewModel.user?.displayName ?? "",
                            email: userViewModel.email,
                            size: 64
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 36)
                .padding(.bottom, 8)

                if userViewModel.isLoggedIn {
                    accountSection
                    staffSection
                } else {
                    loginCard
                }

                SectionTitleView(text: "Einstellungen")
                SettingsGroupView {
                    PickerRowView(icon: "moon.fill", title: "Erscheinungsbild") {
                        DropdownView(
                            selected: settingsViewModel.themeMode,
                            options: ThemeMode.allCases,
                            placeholder: String(localized: "Auswählen", bundle: .appLanguage),
                            optionLabel: { $0.title }
                        ) { mode in
                            settingsViewModel.themeMode = mode
                        }
                    }
                    GroupDividerView()
                    PickerRowView(icon: "globe", title: "Sprache") {
                        // jede Sprache steht in ihrer eigenen Sprache da
                        DropdownView(
                            selected: settingsViewModel.language,
                            options: AppLanguage.allCases,
                            placeholder: String(localized: "Auswählen", bundle: .appLanguage),
                            optionLabel: { $0.title }
                        ) { language in
                            settingsViewModel.language = language
                        }
                    }
                }

                SectionTitleView(text: "Rechtliches")
                SettingsGroupView {
                    SettingsRowView(icon: "info.circle.fill", title: "Impressum") {
                        navigationViewModel.push(.legal(.impressum))
                    }
                    GroupDividerView()
                    SettingsRowView(icon: "hand.raised.fill", title: "Datenschutz") {
                        navigationViewModel.push(.legal(.datenschutz))
                    }
                    GroupDividerView()
                    SettingsRowView(icon: "doc.text.fill", title: "AGB") {
                        navigationViewModel.push(.legal(.agb))
                    }
                }

                if userViewModel.isLoggedIn {
                    SettingsGroupView {
                        SettingsRowView(
                            icon: "rectangle.portrait.and.arrow.right",
                            title: "Abmelden",
                            showChevron: false,
                            tint: AppColors.error
                        ) {
                            userViewModel.logout()
                            navigationViewModel.switchTab(.home)
                        }
                        GroupDividerView()
                        SettingsRowView(
                            icon: "trash.fill",
                            title: "Konto löschen",
                            subtitle: "Wird nach 30 Tagen endgültig gelöscht",
                            showChevron: false,
                            tint: AppColors.error
                        ) {
                            showDeleteSheet = true
                        }
                    }
                    .padding(.top, 24)
                }

                Text("Tableo · Version \(settingsViewModel.appVersion)")
                    .font(AppFont.labelSmall)
                    .foregroundColor(AppColors.onSurfaceVariant)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
            }
            .padding(.horizontal, 20)
        }
        .screenBackground()
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            userViewModel.loadStaffAccess()
        }
        .sheet(isPresented: $showLinkSheet) {
            LinkRestaurantSheet()
        }
        .sheet(isPresented: $showDeleteSheet) {
            DeleteAccountSheet()
        }
    }

    private var loginCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Noch nicht angemeldet")
                .font(AppFont.titleMedium)
            Text("Mit Konto siehst du deine Bestellungen und ihren Status")
                .font(AppFont.bodySmall)
                .foregroundColor(AppColors.onSurfaceVariant)

            NavigationLink(value: Route.login) {
                Text("Anmelden oder registrieren")
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.top, 12)
        }
        .padding(20)
        .cardStyle(shadow: false)
        .padding(.top, 16)
    }

    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionTitleView(text: "Dein Konto")
            SettingsGroupView {
                SettingsRowView(icon: "person.fill", title: "Persönliche Daten", subtitle: "Profilbild, Name, E-Mail und Passwort") {
                    navigationViewModel.push(.account)
                }
                GroupDividerView()
                SettingsRowView(icon: "list.bullet", title: "Meine Bestellungen") {
                    navigationViewModel.switchTab(.orders)
                }
            }
        }
    }

    /// Mitarbeiter und Fahrer erkennt die App am Konto
    private var staffSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            SectionTitleView(text: "Personal")
            SettingsGroupView {
                if let access = userViewModel.staffAccess {
                    if access.canOpenDashboard {
                        SettingsRowView(
                            icon: "storefront.fill",
                            title: "Mein Restaurant",
                            subtitle: "\(access.restaurant.name) · Bestellungen, Menü, Team"
                        ) {
                            navigationViewModel.push(access.dashboardRoute)
                        }
                    }
                    if access.canOpenDashboard && access.canOpenDriverArea {
                        GroupDividerView()
                    }
                    // Lieferanten und die Leitung
                    if access.canOpenDriverArea {
                        SettingsRowView(
                            icon: "bicycle",
                            title: "Fahrer-Bereich",
                            subtitle: "\(access.restaurant.name) · Lieferungen annehmen und Standort teilen"
                        ) {
                            navigationViewModel.push(access.driverRoute)
                        }
                    }
                } else {
                    // für Konten, die vor der Mitarbeiter-Registrierung angelegt wurden
                    SettingsRowView(
                        icon: "storefront.fill",
                        title: "Ich arbeite in einem Restaurant",
                        subtitle: "Konto mit der Restaurant-ID verknüpfen, im Team oder als Fahrer"
                    ) {
                        showLinkSheet = true
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environmentObject(UserViewModel())
    .environmentObject(SettingsViewModel())
    .environmentObject(NavigationViewModel())
}
