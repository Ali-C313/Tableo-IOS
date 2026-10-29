//
//  StaffRowView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Eine Zeile in der Team-Liste
struct StaffRowView: View {
    let profile: FireStaffProfile
    let isMe: Bool
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            HStack(spacing: 14) {
                ProfileImageView(photoUrl: profile.photoUrl, name: profile.name, email: profile.email, size: 48)

                VStack(alignment: .leading, spacing: 2) {
                    Group {
                        if isMe {
                            Text("\(profile.name) (Du)")
                        } else {
                            Text(profile.name)
                        }
                    }
                    .font(AppFont.titleMedium)
                    .foregroundColor(AppColors.onSurface)
                    .lineLimit(1)

                    HStack(spacing: 10) {
                        Text(profile.role.title)
                            .font(AppFont.bodyMedium)
                            .foregroundColor(profile.role == .ohne ? AppColors.onSurfaceVariant : AppColors.primary)

                        if profile.onDuty {
                            // grüner Punkt
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(AppColors.onDutyGreen)
                                    .frame(width: 8, height: 8)
                                Text("Im Dienst")
                                    .font(AppFont.labelMedium)
                                    .foregroundColor(AppColors.onDutyGreen)
                            }
                        }
                    }
                }
                Spacer()

                Image(systemName: "chevron.forward")
                    .foregroundColor(AppColors.onSurfaceVariant)
                    .accessibilityLabel("Details")
            }
            .padding(12)
            .cardStyle(color: AppColors.surface, radius: 14, shadow: false)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    StaffRowView(
        profile: FireStaffProfile(restaurantId: "1", userId: "u1", name: "Omar Haddad", email: "omar@test.de", role: .kellner, joinedAt: 0),
        isMe: false,
        onClick: {}
    )
    .padding()
}
