//
//  RestaurantCardView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Karte für ein Restaurant. Ist es gerade zu, wird sie blasser
struct RestaurantCardView: View {
    let restaurant: FireRestaurant

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                Group {
                    if restaurant.imageUrl.isEmpty {
                        ImagePlaceholderView()
                    } else {
                        RemoteImageView(url: restaurant.imageUrl)
                    }
                }
                .frame(height: 132)
                .frame(maxWidth: .infinity)
                .clipped()

                Text(restaurant.name.prefix(1).uppercased())
                    .font(AppFont.titleMedium)
                    .foregroundColor(AppColors.primary)
                    .frame(width: 40, height: 40)
                    .background(AppColors.surface.opacity(0.9))
                    .clipShape(Circle())
                    .padding(12)

                if !restaurant.isOpenNow {
                    Text("Geschlossen")
                        .font(AppFont.labelMedium)
                        .foregroundColor(AppColors.onError)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(AppColors.error)
                        .clipShape(Capsule())
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(restaurant.name)
                        .font(AppFont.titleMedium)
                        .foregroundColor(AppColors.onSurface)

                    Text("\(typeText) · \(restaurant.openingTime) – \(restaurant.closingTime) Uhr")
                        .font(AppFont.bodySmall)
                        .foregroundColor(AppColors.onSurfaceVariant)

                    if !restaurant.offersDelivery {
                        Text("Nur Abholung")
                            .font(AppFont.labelSmall)
                            .foregroundColor(AppColors.primary)
                    }

                    if !restaurant.address.isEmpty {
                        HStack(alignment: .top, spacing: 4) {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.system(size: 11))
                            // zwei Zeilen, damit PLZ und Ort nicht abgeschnitten werden
                            Text(restaurant.address)
                                .font(AppFont.bodySmall)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                        }
                        .foregroundColor(AppColors.onSurfaceVariant)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.forward")
                    .foregroundColor(AppColors.onSurfaceVariant)
            }
            .padding(16)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .cardStyle()
        .opacity(restaurant.isOpenNow ? 1 : 0.5)
    }

    private var typeText: String {
        restaurant.type.isEmpty ? String(localized: "Speisekarte ansehen", bundle: .appLanguage) : restaurant.type
    }
}

#Preview {
    RestaurantCardView(restaurant: FireRestaurant(
        name: "Shisha Lounge", type: "Shisha-Bar", address: "Hauptstraße 1, 10115 Berlin",
        cuisineTypes: ["Shisha"], openingTime: "18:00", closingTime: "02:00", offersDelivery: false
    ))
    .padding()
}
