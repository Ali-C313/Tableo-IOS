//
//  SettingsViewModel.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Erscheinungsbild, Sprache und Onboarding. Alles wird in den UserDefaults gespeichert
@MainActor
class SettingsViewModel: ObservableObject {

    @Published var themeMode: ThemeMode {
        didSet { UserDefaults.standard.set(themeMode.rawValue, forKey: "theme_mode") }
    }

    @Published var language: AppLanguage {
        didSet { UserDefaults.standard.set(language.rawValue, forKey: "app_language") }
    }

    @Published var onboardingCompleted: Bool {
        didSet { UserDefaults.standard.set(onboardingCompleted, forKey: "onboarding_completed") }
    }

    init() {
        let defaults = UserDefaults.standard
        themeMode = ThemeMode(rawValue: defaults.string(forKey: "theme_mode") ?? "") ?? .system
        language = AppLanguage(rawValue: defaults.string(forKey: "app_language") ?? "") ?? .system
        onboardingCompleted = defaults.bool(forKey: "onboarding_completed")
    }

    /// Version aus der Info.plist, z.B. "1.0"
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
}
