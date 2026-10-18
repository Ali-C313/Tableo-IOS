//
//  EditMenuItemView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI
import PhotosUI

/// Artikel anlegen oder bearbeiten. Das Foto wird erst beim Speichern hochgeladen
struct EditMenuItemView: View {

    let restaurantId: String
    // nil = neuer Artikel
    let menuItemId: String?

    @StateObject private var staffMenuViewModel = StaffMenuViewModel()
    @EnvironmentObject var navigationViewModel: NavigationViewModel

    @State private var name = ""
    @State private var description = ""
    @State private var price = ""
    @State private var category = ""
    @State private var customCategory = ""
    @State private var existingImageUrl = ""
    @State private var pickedImage: Data?
    @State private var pickedItem: PhotosPickerItem?
    @State private var available = true
    @State private var formFilled = false

    // Merker für "eigene Kategorie", angezeigt wird der übersetzte Text
    private let otherCategory = "Andere"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Group {
                    if let pickedImage, let image = UIImage(data: pickedImage) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .accessibilityLabel("Ausgewähltes Foto")
                    } else if !existingImageUrl.isEmpty {
                        RemoteImageView(url: existingImageUrl)
                            .accessibilityLabel("Aktuelles Foto")
                    } else {
                        ImagePlaceholderView(fontSize: 13)
                    }
                }
                .frame(height: 160)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 14))

                PhotosPicker(selection: $pickedItem, matching: .images) {
                    Group {
                        if pickedImage != nil || !existingImageUrl.isEmpty {
                            Text("Anderes Foto wählen")
                        } else {
                            Text("Foto auswählen")
                        }
                    }
                    .font(AppFont.labelLarge)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.onSurfaceVariant.opacity(0.5)))
                }

                LabeledFieldView(label: "Name", text: $name)
                    .padding(.top, 6)
                LabeledFieldView(label: "Beschreibung", text: $description)
                LabeledFieldView(label: "Preis in Euro", text: $price, keyboard: .decimalPad)

                Text("Kategorie")
                    .font(AppFont.bodyMedium)
                    .padding(.top, 6)

                DropdownView(
                    selected: category.isEmpty ? nil : category,
                    options: staffMenuViewModel.categoryNames + [otherCategory],
                    placeholder: String(localized: "Kategorie wählen", bundle: .appLanguage),
                    fillWidth: true,
                    optionLabel: { $0 == otherCategory ? String(localized: "Andere", bundle: .appLanguage) : $0 }
                ) { option in
                    category = option
                }

                if category == otherCategory {
                    LabeledFieldView(label: "Neue Kategorie", text: $customCategory)
                }

                Toggle("Verfügbar (vorrätig)", isOn: $available)
                    .font(AppFont.bodyMedium)
                    .tint(AppColors.primary)
                    .padding(.top, 6)

                if let errorMessage = staffMenuViewModel.errorMessage {
                    Text("Fehler: \(errorMessage)")
                        .font(AppFont.bodyMedium)
                        .foregroundColor(AppColors.error)
                }

                Button {
                    save()
                } label: {
                    if staffMenuViewModel.isSaving {
                        Text("Wird gespeichert…")
                    } else {
                        Text("Speichern")
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || staffMenuViewModel.isSaving)
                .padding(.top, 10)
            }
            .padding(16)
        }
        .scrollDismissesKeyboard(.interactively)
        .screenBackground()
        .navigationTitle(menuItemId == nil ? LocalizedStringKey("Neuer Artikel") : LocalizedStringKey("Artikel bearbeiten"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            staffMenuViewModel.fetchMenu(restaurantId: restaurantId)
        }
        .onDisappear {
            staffMenuViewModel.removeListener()
        }
        // erst ausfüllen, wenn die Speisekarte geladen ist
        .onChange(of: staffMenuViewModel.isLoading) {
            fillForm()
        }
        .onChange(of: pickedItem) {
            guard let pickedItem else { return }
            Task {
                if let data = try? await pickedItem.loadTransferable(type: Data.self) {
                    pickedImage = UIImage(data: data)?.jpegData(compressionQuality: 0.8)
                }
            }
        }
    }

    /// Beim Bearbeiten die Felder füllen, bei neuen eine Kategorie vorwählen
    private func fillForm() {
        guard !formFilled, !staffMenuViewModel.isLoading else { return }
        formFilled = true
        let categories = staffMenuViewModel.categoryNames

        if let item = staffMenuViewModel.menuItem(id: menuItemId) {
            name = item.name
            description = item.description
            price = String(format: "%.2f", item.price)
            existingImageUrl = item.imageUrl
            available = item.available
            let known = categories.contains(item.category)
            category = known ? item.category : otherCategory
            customCategory = known ? "" : item.category
        } else {
            category = categories.first ?? otherCategory
        }
    }

    private func save() {
        let finalCategory = category == otherCategory ? customCategory : category
        // Komma oder Punkt, beides geht
        let parsedPrice = Double(price.replacingOccurrences(of: ",", with: ".")) ?? 0

        let item = FireMenuItem(
            documentId: menuItemId,
            restaurantId: restaurantId,
            name: name,
            description: description,
            price: parsedPrice,
            category: finalCategory,
            imageUrl: existingImageUrl,
            available: available
        )

        staffMenuViewModel.saveItem(item, newImageData: pickedImage) {
            navigationViewModel.pop()
        }
    }
}

#Preview {
    NavigationStack {
        EditMenuItemView(restaurantId: "1", menuItemId: nil)
    }
    .environmentObject(NavigationViewModel())
}
