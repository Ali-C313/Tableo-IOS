//
//  AuthErrorText.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseAuth

/// Macht aus Firebase-Fehlern beim Login einen verständlichen Text
func authErrorText(_ error: Error) -> String {
    let nsError = error as NSError
    guard nsError.domain == AuthErrorDomain, let code = AuthErrorCode(rawValue: nsError.code) else {
        return error.localizedDescription
    }
    switch code {
    case .weakPassword:
        return String(localized: "Das Passwort muss mindestens 6 Zeichen haben.", bundle: .appLanguage)
    case .wrongPassword, .invalidCredential:
        return String(localized: "E-Mail oder Passwort ist falsch.", bundle: .appLanguage)
    case .userNotFound, .userDisabled:
        return String(localized: "Kein Konto mit dieser E-Mail-Adresse gefunden.", bundle: .appLanguage)
    case .emailAlreadyInUse:
        return String(localized: "Diese E-Mail-Adresse wird bereits verwendet.", bundle: .appLanguage)
    case .requiresRecentLogin:
        return String(localized: "Bitte gib zur Sicherheit dein aktuelles Passwort erneut ein.", bundle: .appLanguage)
    case .invalidEmail:
        return String(localized: "Ungültige E-Mail-Adresse.", bundle: .appLanguage)
    default:
        return error.localizedDescription
    }
}
