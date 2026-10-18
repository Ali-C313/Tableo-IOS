//
//  LinkRestaurantSheet.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Restaurant-ID eintragen, die der Chef unter Team sieht
struct LinkRestaurantSheet: View {

    @EnvironmentObject var userViewModel: UserViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var restaurantId = ""
    @State private var isDriver = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                Text("Die Restaurant-ID bekommst du von deinem Chef, sie steht im Dashboard unter Team.")
                    .font(AppFont.bodyMedium)

                LabeledFieldView(
                    label: "Restaurant-ID",
                    text: $restaurantId,
                    isError: userViewModel.linkError != nil,
                    keyboard: .asciiCapable
                )

                if let linkError = userViewModel.linkError {
                    Text(linkError)
                        .font(AppFont.bodySmall)
                        .foregroundColor(AppColors.error)
                }

                HStack(spacing: 8) {
                    FilterChipView(label: String(localized: "Im Team", bundle: .appLanguage), selected: !isDriver) {
                        isDriver = false
                    }
                    FilterChipView(label: String(localized: "Als Fahrer", bundle: .appLanguage), selected: isDriver) {
                        isDriver = true
                    }
                }
                Spacer()
            }
            .padding(20)
            .navigationTitle("Restaurant verknüpfen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Verknüpfen") {
                        userViewModel.linkRestaurant(restaurantId: restaurantId, asDriver: isDriver) {
                            dismiss()
                        }
                    }
                    .disabled(restaurantId.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
        .onDisappear {
            userViewModel.linkError = nil
        }
    }
}

#Preview {
    LinkRestaurantSheet()
        .environmentObject(UserViewModel())
}
