//
//  OrderDetailsView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Tisch, Abholung oder Lieferung, dazu Tischnummer, Abholzeit oder Adresse.
/// Wurde auf der Startseite "Lieferung" gewählt, ist Lieferung schon ausgewählt
struct OrderDetailsView: View {

    let restaurantId: String
    let restaurantName: String

    @EnvironmentObject var deliveryViewModel: DeliveryViewModel

    // nil = noch nichts angetippt, dann gilt der Schalter von der Startseite
    @State private var selectedType: OrderType?
    @State private var tableNumber: Int?
    @State private var pickupTime: String?
    @State private var showTimePicker = false
    @State private var showAddressSheet = false
    @State private var pickerDate = Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date()) ?? Date()

    private let tableNumbers = Array(1...30)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Wie möchtest du bestellen?")
                    .font(AppFont.headlineSmall)

                HStack(spacing: 10) {
                    FilterChipView(label: String(localized: "Am Tisch", bundle: .appLanguage), selected: orderType == .dineIn) {
                        selectedType = .dineIn
                    }
                    FilterChipView(label: String(localized: "Abholen", bundle: .appLanguage), selected: orderType == .pickup) {
                        selectedType = .pickup
                    }
                    FilterChipView(label: String(localized: "Lieferung", bundle: .appLanguage), selected: orderType == .delivery) {
                        selectedType = .delivery
                    }
                }
                .padding(.top, 20)

                switch orderType {
                case .dineIn:
                    question("An welchem Tisch sitzt du?")
                    DropdownView(
                        selected: tableNumber,
                        options: tableNumbers,
                        placeholder: String(localized: "Tischnummer wählen", bundle: .appLanguage),
                        fillWidth: true,
                        optionLabel: { String(localized: "Tisch \(String($0))", bundle: .appLanguage) }
                    ) { number in
                        tableNumber = number
                    }

                case .pickup:
                    question("Wann möchtest du abholen?")
                    Button {
                        showTimePicker = true
                    } label: {
                        if let pickupTime {
                            Text("\(pickupTime) Uhr")
                        } else {
                            Text("Uhrzeit wählen")
                        }
                    }
                    .buttonStyle(OutlineButtonStyle())

                case .delivery:
                    question("Wohin sollen wir liefern?")
                    Button {
                        showAddressSheet = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(AppColors.primary)

                            Group {
                                if let address = deliveryViewModel.address {
                                    Text(address.text)
                                } else {
                                    Text("Adresse eingeben oder Standort teilen")
                                }
                            }
                            .font(AppFont.bodyMedium)
                            .foregroundColor(AppColors.onSurface)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)

                            Text("Ändern")
                                .font(AppFont.labelLarge)
                                .foregroundColor(AppColors.primary)
                        }
                        .padding(16)
                        .cardStyle(radius: 12, shadow: false)
                    }
                    .buttonStyle(.plain)
                }

                NavigationLink(value: Route.cart(
                    restaurantId: restaurantId,
                    restaurantName: restaurantName,
                    orderType: orderType,
                    tableNumber: orderType == .dineIn ? tableNumber : nil,
                    pickupTime: orderType == .pickup ? pickupTime : nil
                )) {
                    Text("Weiter")
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(!canContinue)
                .padding(.top, 32)
            }
            .padding(24)
        }
        .screenBackground()
        .navigationTitle(restaurantName)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showTimePicker) {
            timePickerSheet
        }
        .sheet(isPresented: $showAddressSheet) {
            AddressSheetView()
        }
    }

    private var orderType: OrderType {
        selectedType ?? (deliveryViewModel.deliveryMode == .lieferung ? .delivery : .dineIn)
    }

    /// Je nach Art muss Tisch, Uhrzeit oder Adresse gewählt sein
    private var canContinue: Bool {
        switch orderType {
        case .dineIn: return tableNumber != nil
        case .pickup: return pickupTime != nil
        case .delivery: return deliveryViewModel.address != nil
        }
    }

    private func question(_ text: LocalizedStringKey) -> some View {
        Text(text)
            .font(AppFont.bodyMedium)
            .padding(.top, 28)
            .padding(.bottom, 8)
    }

    private var timePickerSheet: some View {
        NavigationStack {
            DatePicker("", selection: $pickerDate, displayedComponents: .hourAndMinute)
                .datePickerStyle(.wheel)
                .labelsHidden()
                // 24-Stunden-Format
                .environment(\.locale, Locale(identifier: "de_DE"))
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Abbrechen") {
                            showTimePicker = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Übernehmen") {
                            let parts = Calendar.current.dateComponents([.hour, .minute], from: pickerDate)
                            pickupTime = String(format: "%02d:%02d", parts.hour ?? 0, parts.minute ?? 0)
                            showTimePicker = false
                        }
                    }
                }
        }
        .presentationDetents([.height(300)])
    }
}

#Preview {
    NavigationStack {
        OrderDetailsView(restaurantId: "1", restaurantName: "Shisha Lounge")
    }
    .environmentObject(DeliveryViewModel())
}
