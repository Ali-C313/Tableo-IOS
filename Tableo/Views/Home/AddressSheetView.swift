//
//  AddressSheetView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Lieferadresse eintippen oder den eigenen Standort nehmen
struct AddressSheetView: View {

    @EnvironmentObject var deliveryViewModel: DeliveryViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var query = ""

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(AppColors.onSurfaceVariant)
                    TextField("Straße, Hausnummer, Ort", text: $query)
                        .textContentType(.fullStreetAddress)
                        .submitLabel(.search)
                        .onSubmit { search() }
                }
                .fieldStyle()

                Button {
                    deliveryViewModel.useCurrentLocation {
                        dismiss()
                    }
                } label: {
                    Label("Meinen Standort verwenden", systemImage: "location.fill")
                }
                .buttonStyle(OutlineButtonStyle())
                .disabled(deliveryViewModel.isLoading)

                if deliveryViewModel.isLoading {
                    HStack(spacing: 8) {
                        ProgressView()
                        Text("Adresse wird gesucht…")
                            .font(AppFont.bodySmall)
                    }
                }

                if let errorMessage = deliveryViewModel.errorMessage {
                    Text(errorMessage)
                        .font(AppFont.bodySmall)
                        .foregroundColor(AppColors.error)
                }
                Spacer()
            }
            .padding(20)
            .navigationTitle("Lieferadresse")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Übernehmen") {
                        search()
                    }
                    .disabled(query.trimmingCharacters(in: .whitespaces).isEmpty || deliveryViewModel.isLoading)
                }
            }
        }
        .presentationDetents([.medium])
        .onAppear {
            query = deliveryViewModel.address?.text ?? ""
            deliveryViewModel.errorMessage = nil
        }
    }

    private func search() {
        deliveryViewModel.searchAddress(query) {
            dismiss()
        }
    }
}

#Preview {
    AddressSheetView()
        .environmentObject(DeliveryViewModel())
}
