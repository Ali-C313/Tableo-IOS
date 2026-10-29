//
//  BarChartView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

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
    BarChartView(buckets: [
        ChartBucket(label: "Mo", revenue: 120),
        ChartBucket(label: "Di", revenue: 80),
        ChartBucket(label: "Mi", revenue: 200)
    ])
    .padding()
}
