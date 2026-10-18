//
//  CancelOrderAlert.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

extension View {
    /// Sicherheitsabfrage vor dem Stornieren
    func cancelOrderAlert(isPresented: Binding<Bool>, message: Text, onConfirm: @escaping () -> Void) -> some View {
        self.alert("Bestellung stornieren?", isPresented: isPresented) {
            Button("Stornieren", role: .destructive, action: onConfirm)
            Button("Behalten", role: .cancel) {}
        } message: {
            message
        }
    }
}
