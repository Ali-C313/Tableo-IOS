//
//  GroupDividerView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Dünne Linie zwischen zwei Zeilen
struct GroupDividerView: View {
    var body: some View {
        Rectangle()
            .fill(AppColors.onSurfaceVariant.opacity(0.15))
            .frame(height: 0.5)
    }
}

#Preview {
    GroupDividerView()
        .padding()
}
