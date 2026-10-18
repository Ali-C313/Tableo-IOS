//
//  HomeView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Startseite: alle Restaurants und Shisha-Bars.
/// Oben stehen Adresse, Begrüßung und Suche fest, Kategorien, Filter und Liste scrollen
struct HomeView: View {

    @StateObject private var restaurantViewModel = RestaurantViewModel()
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var deliveryViewModel: DeliveryViewModel

    @State private var searchText = ""
    @State private var selectedType: String?
    @State private var selectedCuisine: String?
    @State private var showAddressSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // bleibt fest oben
            VStack(alignment: .leading, spacing: 2) {
                DeliveryHeaderView(onAddressClick: { showAddressSheet = true })
                    .padding(.bottom, 8)

                Text("Restaurants entdecken")
                    .font(AppFont.headlineSmall)

                Group {
                    if userViewModel.isLoggedIn {
                        Text("Hallo, \(userViewModel.displayName)!")
                    } else {
                        Text("Worauf hast du heute Lust?")
                    }
                }
                .font(AppFont.bodyLarge)
                .foregroundColor(AppColors.primary)

                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(AppColors.onSurfaceVariant)
                    // gefiltert wird schon beim Tippen
                    TextField("Du suchst ein Restaurant?", text: $searchText)
                        .submitLabel(.search)
                        .autocorrectionDisabled()
                }
                .fieldStyle()
                .padding(.top, 14)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 8)

            if restaurantViewModel.isLoading {
                LoadingView()
            } else if let errorMessage = restaurantViewModel.errorMessage {
                ErrorView(message: errorMessage)
            } else {
                restaurantList
            }
        }
        .screenBackground()
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showAddressSheet) {
            AddressSheetView()
        }
        .onAppear {
            restaurantViewModel.fetchRestaurants()
        }
        .onDisappear {
            restaurantViewModel.removeListener()
        }
    }

    private var restaurantList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if !cuisines.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(cuisines, id: \.self) { cuisine in
                                CategoryTileView(label: cuisine, selected: cuisine == selectedCuisine) {
                                    selectedCuisine = selectedCuisine == cuisine ? nil : cuisine
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                    }
                }

                if !types.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChipView(label: String(localized: "Alle", bundle: .appLanguage), selected: selectedType == nil) {
                                selectedType = nil
                            }
                            ForEach(types, id: \.self) { type in
                                FilterChipView(label: type, selected: type == selectedType) {
                                    selectedType = type
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                    }
                }

                ForEach(filteredRestaurants) { restaurant in
                    NavigationLink(value: Route.menu(restaurantId: restaurant.id, restaurantName: restaurant.name)) {
                        RestaurantCardView(restaurant: restaurant)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 7)
                }
            }
            .padding(.bottom, 16)
        }
        .scrollDismissesKeyboard(.immediately)
    }

    /// Küchen ohne doppelte, Reihenfolge bleibt
    private var cuisines: [String] {
        var seen = Set<String>()
        return restaurantViewModel.restaurants
            .flatMap { $0.cuisineTypes }
            .filter { !$0.isEmpty && seen.insert($0).inserted }
    }

    private var types: [String] {
        var seen = Set<String>()
        return restaurantViewModel.restaurants
            .map { $0.type }
            .filter { !$0.isEmpty && seen.insert($0).inserted }
    }

    /// Suche über Name und Adresse, geöffnete zuerst
    private var filteredRestaurants: [FireRestaurant] {
        let query = searchText.trimmingCharacters(in: .whitespaces)

        let filtered = restaurantViewModel.restaurants
            // bei Lieferung nur Restaurants, die auch liefern
            .filter { deliveryViewModel.deliveryMode != .lieferung || $0.offersDelivery }
            .filter { selectedType == nil || $0.type == selectedType }
            .filter { selectedCuisine == nil || $0.cuisineTypes.contains(selectedCuisine ?? "") }
            .filter {
                query.isEmpty
                    || $0.name.localizedCaseInsensitiveContains(query)
                    || $0.address.localizedCaseInsensitiveContains(query)
            }

        return filtered.filter { $0.isOpenNow } + filtered.filter { !$0.isOpenNow }
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
    .environmentObject(UserViewModel())
    .environmentObject(DeliveryViewModel())
}
