//
//  StaffMenuViewModel.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

/// Speisekarte fürs Personal: anzeigen, ein-/ausblenden, löschen, anlegen und bearbeiten
@MainActor
class StaffMenuViewModel: ObservableObject {

    @Published var menuItems: [FireMenuItem] = []
    @Published var isLoading = true
    @Published var isSaving = false
    @Published var errorMessage: String?

    private let database = FirebaseManager.shared.database
    private let storage = FirebaseManager.shared.storage
    private var listener: ListenerRegistration?

    func fetchMenu(restaurantId: String) {
        // alten Listener entfernen, sonst laufen zwei gleichzeitig
        listener?.remove()
        listener = database.collection("menuItems")
            .whereField("restaurantId", isEqualTo: restaurantId)
            .addSnapshotListener { querySnapshot, error in
                self.isLoading = false
                if let error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                guard let documents = querySnapshot?.documents else { return }
                self.menuItems = documents.compactMap { try? $0.data(as: FireMenuItem.self) }
                self.errorMessage = nil
            }
    }

    func removeListener() {
        listener?.remove()
        listener = nil
    }

    /// Kategorien, die es schon gibt, als Vorschlag beim Bearbeiten
    var categoryNames: [String] {
        Array(Set(menuItems.map { $0.category }.filter { !$0.isEmpty })).sorted()
    }

    func menuItem(id: String?) -> FireMenuItem? {
        guard let id else { return nil }
        return menuItems.first { $0.id == id }
    }

    /// z.B. wenn etwas ausverkauft ist
    func setAvailability(_ menuItem: FireMenuItem, available: Bool) {
        Task {
            try? await database.collection("menuItems").document(menuItem.id).updateData(["available": available])
        }
    }

    func deleteItem(_ menuItem: FireMenuItem) {
        Task {
            try? await database.collection("menuItems").document(menuItem.id).delete()
        }
    }

    /// Gibt es ein neues Foto, wird es zuerst hochgeladen und die neue URL gespeichert
    func saveItem(_ menuItem: FireMenuItem, newImageData: Data?, onSaved: @escaping () -> Void) {
        isSaving = true
        errorMessage = nil

        Task {
            var item = menuItem

            if let newImageData {
                do {
                    let fileName = "\(currentMillis())-\(Int.random(in: 0..<100_000)).jpg"
                    let reference = storage.reference().child("menuItems/\(item.restaurantId)/\(fileName)")
                    let metadata = StorageMetadata()
                    metadata.contentType = "image/jpeg"
                    _ = try await reference.putDataAsync(newImageData, metadata: metadata)
                    item.imageUrl = try await reference.downloadURL().absoluteString
                } catch {
                    errorMessage = String(localized: "Bild-Upload fehlgeschlagen", bundle: .appLanguage)
                    isSaving = false
                    return
                }
            }

            do {
                if item.id.isEmpty {
                    _ = try database.collection("menuItems").addDocument(from: item)
                } else {
                    try database.collection("menuItems").document(item.id).setData(from: item)
                }
                isSaving = false
                onSaved()
            } catch {
                errorMessage = String(localized: "Speichern fehlgeschlagen", bundle: .appLanguage)
                isSaving = false
            }
        }
    }
}
