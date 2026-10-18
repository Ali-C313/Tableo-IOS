//
//  LabeledFieldView.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Textfeld mit Rahmen und kleiner Überschrift darüber
struct LabeledFieldView: View {
    let label: LocalizedStringKey
    @Binding var text: String
    var hint: LocalizedStringKey?
    var isError = false
    var keyboard: UIKeyboardType = .default
    var contentType: UITextContentType?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(AppFont.labelMedium)
                .foregroundColor(isError ? AppColors.error : AppColors.onSurfaceVariant)

            TextField("", text: $text)
                .keyboardType(keyboard)
                .textContentType(contentType)
                .textInputAutocapitalization(keyboard == .emailAddress ? .never : .sentences)
                .autocorrectionDisabled(keyboard == .emailAddress)
                .fieldStyle(isError: isError)

            if let hint {
                Text(hint)
                    .font(AppFont.bodySmall)
                    .foregroundColor(AppColors.onSurfaceVariant)
            }
        }
    }
}

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
    VStack(spacing: 16) {
        LabeledFieldView(label: "E-Mail", text: .constant("ali@test.de"), keyboard: .emailAddress)
        PasswordFieldView(password: .constant("geheim"))
    }
    .padding()
}
