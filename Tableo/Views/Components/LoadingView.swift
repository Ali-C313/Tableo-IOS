//
//  LoadingView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Ladekreis in der Mitte
struct LoadingView: View {
    var body: some View {
        ProgressView()
            .tint(AppColors.primary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    LoadingView()
}
