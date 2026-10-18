//
//  UserViewModel.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

/// Anmelden, Registrieren und alles rund ums Konto.
/// Kunden und Mitarbeiter nutzen dasselbe Konto, Mitarbeiter haben zusätzlich ein Profil in "staffProfiles"
@MainActor
class UserViewModel: ObservableObject {

    @Published var user: User?
    // Restaurant und Profil, wenn das Konto dort arbeitet
    @Published var staffAccess: StaffAccess?
    @Published var photoUrl = ""

    @Published var isLoading = false
    @Published var isUploadingPhoto = false
    @Published var errorMessage: String?
    // z.B. "Gespeichert." oder "Link wurde gesendet"
    @Published var infoMessage: String?

    // Konto war zum Löschen vorgemerkt und wurde durch den Login gerettet
    @Published var accountRestored = false
    private var restoredAccess: StaffAccess?

    @Published var isDeleting = false
    @Published var deleteError: String?
    @Published var linkError: String?

    private let auth = FirebaseManager.shared.auth
    private let database = FirebaseManager.shared.database
    private let storage = FirebaseManager.shared.storage

    // so lange kann man sich nach "Konto löschen" noch umentscheiden
    private let deletionGraceMillis: Int64 = 30 * 24 * 60 * 60 * 1000

    init() {
        checkAuth()
    }

    /// Anonyme Gäste zählen nicht als eingeloggt
    var isLoggedIn: Bool {
        guard let user else { return false }
        return !user.isAnonymous
    }

    var userId: String? {
        isLoggedIn ? user?.uid : nil
    }

    var email: String {
        user?.email ?? ""
    }

    /// Anzeigename, sonst die E-Mail vor dem @
    var displayName: String {
        if let name = user?.displayName, !name.isEmpty {
            return name
        }
        return email.components(separatedBy: "@").first ?? ""
    }

    func checkAuth() {
        user = auth.currentUser
        photoUrl = user?.photoURL?.absoluteString ?? ""
    }

    /// Ohne Anmeldung lassen die Firestore-Regeln keine Bestellung zu, deshalb anonym als Gast
    func ensureSignedIn() async {
        if auth.currentUser == nil {
            _ = try? await auth.signInAnonymously()
        }
        checkAuth()
    }

    // MARK: - Login und Registrierung

    /// Mit Restaurant-ID wird zusätzlich ein Mitarbeiter-Profil angelegt, als Fahrer mit der Rolle Lieferant
    func register(name: String, email: String, password: String, restaurantId: String, asDriver: Bool,
                  onSuccess: @escaping (StaffAccess?) -> Void) {
        isLoading = true
        errorMessage = nil

        Task {
            // erst prüfen, ob es das Restaurant gibt, bevor ein Konto angelegt wird
            var restaurant: FireRestaurant?
            let trimmedId = restaurantId.trimmingCharacters(in: .whitespaces)
            if !trimmedId.isEmpty {
                restaurant = await fetchRestaurant(id: trimmedId)
                if restaurant == nil {
                    errorMessage = String(localized: "Restaurant-ID nicht gefunden", bundle: .appLanguage)
                    isLoading = false
                    return
                }
            }

            do {
                _ = try await auth.createUser(withEmail: email.trimmingCharacters(in: .whitespaces), password: password)
            } catch {
                errorMessage = authErrorText(error)
                isLoading = false
                return
            }

            // Name ist optional, klappt das nicht, gibt es das Konto trotzdem
            let request = auth.currentUser?.createProfileChangeRequest()
            request?.displayName = name
            try? await request?.commitChanges()
            checkAuth()

            var access: StaffAccess?
            if let restaurant, let userId {
                let profile = FireStaffProfile(
                    restaurantId: restaurant.id,
                    userId: userId,
                    name: name,
                    email: email.trimmingCharacters(in: .whitespaces),
                    role: asDriver ? .lieferant : .ohne,
                    joinedAt: currentMillis()
                )
                try? database.collection("staffProfiles").document(userId).setData(from: profile)
                access = StaffAccess(restaurant: restaurant, profile: profile)
                staffAccess = access
            }

            isLoading = false
            onSuccess(access)
        }
    }

    /// Meldet an und schaut, ob das Konto zum Löschen vorgemerkt war
    func login(email: String, password: String, onSuccess: @escaping (StaffAccess?) -> Void) {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                _ = try await auth.signIn(withEmail: email.trimmingCharacters(in: .whitespaces), password: password)
            } catch {
                errorMessage = authErrorText(error)
                isLoading = false
                return
            }
            checkAuth()
            guard let userId else { return }

            let requestedAt = await deletionRequestedAt(userId: userId)

            if requestedAt > 0 && currentMillis() - requestedAt < deletionGraceMillis {
                // innerhalb der 30 Tage: Konto bleibt
                try? await database.collection("users").document(userId).delete()
                restoredAccess = await fetchStaffAccess()
                staffAccess = restoredAccess
                isLoading = false
                accountRestored = true
            } else if requestedAt > 0 {
                await deleteForGood(userId: userId)
                errorMessage = String(localized: "Dieses Konto wurde nach 30 Tagen endgültig gelöscht.", bundle: .appLanguage)
                isLoading = false
            } else {
                let access = await fetchStaffAccess()
                staffAccess = access
                isLoading = false
                onSuccess(access)
            }
        }
    }

    /// Nach dem Hinweis "Konto wiederhergestellt" normal weitermachen
    func finishRestore() -> StaffAccess? {
        accountRestored = false
        let access = restoredAccess
        restoredAccess = nil
        return access
    }

    func sendPasswordReset(email: String) {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                try await auth.sendPasswordReset(withEmail: email.trimmingCharacters(in: .whitespaces))
                infoMessage = String(localized: "Link zum Zurücksetzen wurde an \(email) gesendet.", bundle: .appLanguage)
            } catch {
                errorMessage = authErrorText(error)
            }
            isLoading = false
        }
    }

    func logout() {
        Task {
            // wer noch im Dienst war, wird ausgetragen
            if let userId {
                try? await database.collection("staffProfiles").document(userId).updateData(["onDuty": false])
            }
            try? auth.signOut()
            staffAccess = nil
            photoUrl = ""
            await ensureSignedIn()
        }
    }

    // MARK: - Konto löschen

    /// Merkt das Konto zum Löschen vor und meldet ab. Firebase will dafür einen frischen Login
    func deleteAccount(currentPassword: String, onDone: @escaping () -> Void) {
        guard let userId else { return }
        isDeleting = true
        deleteError = nil

        Task {
            do {
                try await reauthenticate(currentPassword: currentPassword)
                try await database.collection("users").document(userId).setData(["deletionRequestedAt": currentMillis()])
                try? await database.collection("staffProfiles").document(userId).updateData(["onDuty": false])

                try? auth.signOut()
                staffAccess = nil
                photoUrl = ""
                await ensureSignedIn()

                isDeleting = false
                onDone()
            } catch {
                deleteError = authErrorText(error)
                isDeleting = false
            }
        }
    }

    /// Nach 30 Tagen: Team-Eintrag, Profilbild, Vormerkung und zuletzt das Konto selbst
    private func deleteForGood(userId: String) async {
        try? await database.collection("staffProfiles").document(userId).delete()
        if let old = try? await database.collection("staffProfiles").whereField("userId", isEqualTo: userId).getDocuments() {
            for document in old.documents {
                try? await document.reference.delete()
            }
        }
        // ohne Bild ist das kein Fehler
        try? await storage.reference().child("profilePhotos/\(userId).jpg").delete()
        try? await database.collection("users").document(userId).delete()
        try? await auth.currentUser?.delete()
        await ensureSignedIn()
    }

    private func deletionRequestedAt(userId: String) async -> Int64 {
        let snapshot = try? await database.collection("users").document(userId).getDocument()
        let value = snapshot?.data()?["deletionRequestedAt"] as? NSNumber
        return value?.int64Value ?? 0
    }

    // MARK: - Restaurant

    /// Schaut nach, ob das Konto zu einem Restaurant gehört
    func loadStaffAccess() {
        Task {
            staffAccess = await fetchStaffAccess()
        }
    }

    /// Bestehendes Konto nachträglich mit einem Restaurant verknüpfen
    func linkRestaurant(restaurantId: String, asDriver: Bool, onDone: @escaping () -> Void) {
        guard let userId else { return }
        linkError = nil

        Task {
            guard let restaurant = await fetchRestaurant(id: restaurantId.trimmingCharacters(in: .whitespaces)) else {
                linkError = String(localized: "Restaurant-ID nicht gefunden", bundle: .appLanguage)
                return
            }

            let profile = FireStaffProfile(
                restaurantId: restaurant.id,
                userId: userId,
                name: displayName,
                email: email,
                photoUrl: photoUrl,
                role: asDriver ? .lieferant : .ohne,
                joinedAt: currentMillis()
            )

            do {
                try database.collection("staffProfiles").document(userId).setData(from: profile)
                staffAccess = StaffAccess(restaurant: restaurant, profile: profile)
                onDone()
            } catch {
                linkError = String(localized: "Verknüpfen hat nicht geklappt", bundle: .appLanguage)
            }
        }
    }

    private func fetchRestaurant(id: String) async -> FireRestaurant? {
        guard !id.isEmpty else { return nil }
        let snapshot = try? await database.collection("restaurants").document(id).getDocument()
        guard let snapshot, snapshot.exists else { return nil }
        return try? snapshot.data(as: FireRestaurant.self)
    }

    /// Restaurant und Profil des Kontos, nil bei Kunden
    private func fetchStaffAccess() async -> StaffAccess? {
        guard let userId, let profile = await fetchStaffProfile(userId: userId) else { return nil }
        guard let restaurant = await fetchRestaurant(id: profile.restaurantId) else { return nil }
        return StaffAccess(restaurant: restaurant, profile: profile)
    }

    /// Profil liegt unter der User-ID. Alte Einträge mit zufälliger ID werden dorthin umgezogen
    private func fetchStaffProfile(userId: String) async -> FireStaffProfile? {
        let collection = database.collection("staffProfiles")

        if let snapshot = try? await collection.document(userId).getDocument(), snapshot.exists {
            return try? snapshot.data(as: FireStaffProfile.self)
        }

        let query = try? await collection.whereField("userId", isEqualTo: userId).limit(to: 1).getDocuments()
        guard let document = query?.documents.first, let old = try? document.data(as: FireStaffProfile.self) else {
            return nil
        }

        do {
            try collection.document(userId).setData(from: old)
            try await document.reference.delete()
        } catch {
            print("Umzug vom Profil hat nicht geklappt: \(error.localizedDescription)")
        }
        return old
    }

    // MARK: - Kontodaten

    /// Bild hochladen, ans Konto hängen und ins Team-Profil, damit der Chef es sieht
    func uploadProfilePhoto(_ imageData: Data) {
        guard let userId else { return }
        isUploadingPhoto = true

        Task {
            do {
                let reference = storage.reference().child("profilePhotos/\(userId).jpg")
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                _ = try await reference.putDataAsync(imageData, metadata: metadata)
                let url = try await reference.downloadURL()

                let request = auth.currentUser?.createProfileChangeRequest()
                request?.photoURL = url
                try? await request?.commitChanges()
                try? await database.collection("staffProfiles").document(userId).updateData(["photoUrl": url.absoluteString])

                photoUrl = url.absoluteString
            } catch {
                errorMessage = String(localized: "Bild konnte nicht hochgeladen werden", bundle: .appLanguage)
            }
            isUploadingPhoto = false
        }
    }

    /// Speichert nur, was sich geändert hat. Für E-Mail und Passwort braucht Firebase das aktuelle Passwort
    func saveAccountInfo(name: String, email newEmail: String, currentPassword: String, newPassword: String) {
        isLoading = true
        errorMessage = nil
        infoMessage = nil

        Task {
            let emailChanged = newEmail != email
            do {
                if name != (user?.displayName ?? "") {
                    let request = auth.currentUser?.createProfileChangeRequest()
                    request?.displayName = name
                    try await request?.commitChanges()
                }
                if emailChanged || !newPassword.isEmpty {
                    try await reauthenticate(currentPassword: currentPassword)
                    if emailChanged {
                        // neue E-Mail gilt erst nach dem Klick auf den Link
                        try await auth.currentUser?.sendEmailVerification(beforeUpdatingEmail: newEmail)
                    }
                    if !newPassword.isEmpty {
                        try await auth.currentUser?.updatePassword(to: newPassword)
                    }
                }
                checkAuth()
                infoMessage = emailChanged
                    ? String(localized: "Gespeichert. Bitte bestätige die neue E-Mail über den Link in deinem Postfach.", bundle: .appLanguage)
                    : String(localized: "Gespeichert.", bundle: .appLanguage)
            } catch {
                errorMessage = authErrorText(error)
            }
            isLoading = false
        }
    }

    private func reauthenticate(currentPassword: String) async throws {
        guard let user = auth.currentUser, let email = user.email else { return }
        let credential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        _ = try await user.reauthenticate(with: credential)
    }
}
