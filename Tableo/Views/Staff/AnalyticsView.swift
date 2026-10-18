//
//  AnalyticsView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Umsatz und Anzahl abgeschlossener Bestellungen für einen wählbaren Zeitraum
struct AnalyticsView: View {

    let restaurantId: String
    let restaurantName: String

    @StateObject private var analyticsViewModel = AnalyticsViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(AnalyticsPeriod.allCases, id: \.self) { period in
                        FilterChipView(label: period.title, selected: period == analyticsViewModel.period) {
                            analyticsViewModel.period = period
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
            }

            if analyticsViewModel.isLoading {
                LoadingView()
            } else if let errorMessage = analyticsViewModel.errorMessage {
                ErrorView(message: errorMessage)
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        summary(value: analyticsViewModel.totalRevenue.euro, label: "Umsatz")
                        summary(value: "\(analyticsViewModel.totalOrders)", label: "Bestellungen")
                    }
                    .padding(16)
                    .cardStyle()

                    if analyticsViewModel.totalOrders == 0 {
                        Text("In diesem Zeitraum keine abgeschlossenen Bestellungen.")
                            .font(AppFont.bodyMedium)
                            .foregroundColor(AppColors.onSurfaceVariant)
                            .padding(.top, 24)
                    } else {
                        BarChartView(buckets: analyticsViewModel.buckets)
                            .padding(.top, 32)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
            }
        }
        .screenBackground()
        .navigationTitle("Statistik · \(restaurantName)")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            analyticsViewModel.fetchOrders(restaurantId: restaurantId)
        }
        .onDisappear {
            analyticsViewModel.removeListener()
        }
    }

    private func summary(value: String, label: LocalizedStringKey) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(AppFont.titleLarge)
                .foregroundColor(AppColors.primary)
            Text(label)
                .font(AppFont.bodySmall)
                .foregroundColor(AppColors.onSurfaceVariant)
        }
        .frame(maxWidth: .infinity)
    }
}

/// Einfaches Balkendiagramm, Höhe im Verhältnis zum größten Umsatz
struct BarChartView: View {
    let buckets: [ChartBucket]

    private let maxBarHeight: CGFloat = 120

    var body: some View {
        let maxRevenue = max(buckets.map { $0.revenue }.max() ?? 1, 1)

        HStack(alignment: .bottom, spacing: 0) {
            ForEach(buckets) { bucket in
                VStack(spacing: 4) {
                    if bucket.revenue > 0 {
                        Text(bucket.revenue.euro)
                            .font(AppFont.labelSmall)
                            .foregroundColor(AppColors.onSurfaceVariant)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.7)
                    }

                    UnevenRoundedRectangle(topLeadingRadius: 6, topTrailingRadius: 6)
                        .fill(AppColors.primary)
                        .frame(width: 22, height: maxBarHeight * CGFloat(min(max(bucket.revenue / maxRevenue, 0), 1)) + 4)

                    Text(bucket.label)
                        .font(AppFont.labelSmall)
                        .foregroundColor(AppColors.onSurfaceVariant)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

#Preview {
    NavigationStack {
        AnalyticsView(restaurantId: "1", restaurantName: "Shisha Lounge")
    }
}
