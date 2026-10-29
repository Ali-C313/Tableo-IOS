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

#Preview {
    VStack(spacing: 16) {
        LabeledFieldView(label: "E-Mail", text: .constant("ali@test.de"), keyboard: .emailAddress)
        PasswordFieldView(password: .constant("geheim"))
    }
    .padding()
}
