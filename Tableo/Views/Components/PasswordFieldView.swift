//
//  PasswordFieldView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Passwort mit Auge zum Ein- und Ausblenden. Enter ruft onDone auf
struct PasswordFieldView: View {
    @Binding var password: String
    var placeholder: LocalizedStringKey = ""
    var isError = false
    var onDone: () -> Void = {}

    @State private var visible = false

    var body: some View {
        HStack {
            Group {
                if visible {
                    TextField(placeholder, text: $password)
                } else {
                    SecureField(placeholder, text: $password)
                }
            }
            .textContentType(.password)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .submitLabel(.done)
            .onSubmit(onDone)

            Button {
                visible.toggle()
            } label: {
                Image(systemName: visible ? "eye.slash" : "eye")
                    .foregroundColor(AppColors.onSurfaceVariant)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(visible ? LocalizedStringKey("Passwort verbergen") : LocalizedStringKey("Passwort anzeigen"))
        }
        .fieldStyle(isError: isError)
    }
}

#Preview {
    PasswordFieldView(password: .constant("geheim"))
        .padding()
}
