//
//  TeamViewModel.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseFirestore

/// Team eines Restaurants. Rollen vergeben und Mitarbeiter entfernen darf nur die Leitung
@MainActor
class TeamViewModel: ObservableObject {

    @Published var staff: [FireStaffProfile] = []
    @Published var isLoading = true
    @Published var errorMessage: String?

    private let database = FirebaseManager.shared.database
    private var listener: ListenerRegistration?

    var currentUserId: String? {
        FirebaseManager.shared.userId
    }

    /// Das eigene Konto hat in diesem Team die Leitung
    var canManage: Bool {
        staff.contains { $0.userId == currentUserId && $0.role == .leitung }
    }

    func fetchTeam(restaurantId: String) {
        Task {
            // alte Einträge mit zufälliger ID umziehen, die Firestore-Regeln brauchen die User-ID
            await migrateOldProfiles(restaurantId: restaurantId)

            // alten Listener entfernen, sonst laufen zwei gleichzeitig

            listener?.remove()

            listener = database.collection("staffProfiles")
                .whereField("restaurantId", isEqualTo: restaurantId)
                .addSnapshotListener { querySnapshot, error in
                    self.isLoading = false
                    if let error {
                        self.errorMessage = error.localizedDescription
                        return
                    }
                    guard let documents = querySnapshot?.documents else { return }
                    let staff = documents.compactMap { try? $0.data(as: FireStaffProfile.self) }
                    self.staff = staff.sorted(by: self.sortByRole)
                    self.errorMessage = nil
                }
        }
    }

    func removeListener() {
        listener?.remove()
        listener = nil
    }

    func updateRole(_ profile: FireStaffProfile, role: StaffRole) {
        guard profile.role != role else { return }
        Task {
            do {
                try await database.collection("staffProfiles").document(profile.id).updateData(["role": role.rawValue])
            } catch {
                errorMessage = String(localized: "Rolle konnte nicht geändert werden", bundle: .appLanguage)
            }
        }
    }

    /// Wirft den Mitarbeiter aus dem Team, sein Konto bleibt
    func removeStaff(_ profile: FireStaffProfile, onDone: @escaping () -> Void) {
        Task {
            do {
                try await database.collection("staffProfiles").document(profile.id).delete()
                onDone()
            } catch {
                errorMessage = String(localized: "Mitarbeiter konnte nicht entfernt werden", bundle: .appLanguage)
            }
        }
    }

    /// Nach Rolle sortiert, ohne Rolle ganz unten
    private func sortByRole(_ left: FireStaffProfile, _ right: FireStaffProfile) -> Bool {
        let leftIndex = left.role == .ohne ? Int.max : StaffRole.allCases.firstIndex(of: left.role) ?? 0
        let rightIndex = right.role == .ohne ? Int.max : StaffRole.allCases.firstIndex(of: right.role) ?? 0
        if leftIndex != rightIndex {
            return leftIndex < rightIndex
        }
        return left.name < right.name
    }

    private func migrateOldProfiles(restaurantId: String) async {
        let collection = database.collection("staffProfiles")
        guard let snapshot = try? await collection.whereField("restaurantId", isEqualTo: restaurantId).getDocuments() else { return }

        for document in snapshot.documents {
            guard let profile = try? document.data(as: FireStaffProfile.self) else { continue }
            if profile.userId.isEmpty || document.documentID == profile.userId { continue }
            do {
                try collection.document(profile.userId).setData(from: profile)
                try await document.reference.delete()
            } catch {
                print("Umzug von \(profile.name) hat nicht geklappt: \(error.localizedDescription)")
            }
        }
    }
}
