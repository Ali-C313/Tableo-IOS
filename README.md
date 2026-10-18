# Tableo (iOS, Swift/SwiftUI)

iPhone-Version von Tableo, der Bestell-App für Restaurants und Shisha-Bars.
Gleiche Funktionen und gleiches Firebase-Projekt wie die Kotlin-Multiplatform-App (`Android/Tableo-KMP`).
Beide Apps lesen und schreiben dieselben Firestore-Daten.

## Starten

1. `Tableo.xcodeproj` in Xcode öffnen
2. Xcode lädt das Firebase-Paket (Swift Package Manager) beim ersten Öffnen selbst
3. Unter Signing & Capabilities das eigene Team auswählen
4. iPhone oder Simulator wählen und starten

Mindestversion ist iOS 18.2. Die Bundle-ID steht in `Configuration/Config.xcconfig`.

Die `GoogleService-Info.plist` ist nicht im Repository. Wer das Projekt klont, lädt sie in der
Firebase Console herunter und legt sie nach `Tableo/Resources`.

## Aufbau

```
Tableo/
├── TableoApp.swift   startet Firebase, erstellt die ViewModels für die ganze App
├── Enums/            OrderStatus, OrderType, Route, AppTab, ThemeMode …
├── Models/           FireRestaurant, FireMenuItem, FireOrder, FireStaffProfile …
├── ViewModels/       ein ViewModel pro Bereich
├── Views/
│   ├── Start/        Splash und Onboarding
│   ├── Main/         RootView, MainTabView, RouteView
│   ├── Home/         Startseite mit allen Restaurants
│   ├── Menu/         Speisekarte
│   ├── Order/        Bestelldetails, Warenkorb, Bestätigung
│   ├── MyOrders/     Meine Bestellungen, Details, Live-Tracking
│   ├── Auth/         Anmelden und Registrieren
│   ├── Settings/     Konto, Kontoinformationen, Rechtliches
│   ├── Staff/        Dashboard, Archiv, Speisekarte, Team, Statistik
│   ├── Driver/       Fahrer-Bereich
│   └── Components/   kleine Views, die mehrere Screens nutzen
├── Repositories/     Wechselkurs-API (Protocol + Klasse)
├── Utils/            FirebaseManager, Standort, Benachrichtigungen, Formatieren
├── Theme/            Farben, Schriften, Button-Stile
├── Assets.xcassets
└── Resources/        Localizable.xcstrings, Schriften, GoogleService-Info.plist, Info.plist
```

## So ist der Code aufgebaut

- `FirebaseManager.shared` hält `auth`, `database` und `storage`
- ViewModels sind `@MainActor class …: ObservableObject` mit `@Published` Variablen
- Firestore wird mit `addSnapshotListener` gelesen, z.B. `fetchMenu(restaurantId:)`.
  Die View startet den Listener in `.onAppear` und entfernt ihn in `.onDisappear` mit `removeListener()`
- ViewModels, die die ganze App braucht (User, Settings, Navigation, Warenkorb, Lieferadresse,
  Bestell-Updates, Dienst), werden in `TableoApp` als `@StateObject` erstellt und mit
  `.environmentObject` weitergegeben. Screens holen sie mit `@EnvironmentObject`
- ViewModels nur für einen Screen sind dort ein `@StateObject`
- Lade- und Fehlerzustand stehen als `isLoading` und `errorMessage` im ViewModel,
  alles was nur der Screen braucht steht als `@State` in der View
- Navigation über das Enum `Route`, jeder Tab hat einen eigenen `NavigationStack`

## Sprachen

Deutsch (Standard), Englisch, Türkisch, Arabisch (von rechts nach links), Spanisch, Französisch,
Italienisch, Polnisch, Russisch und Ukrainisch. Die Texte stehen auf Deutsch direkt in den Views,
z.B. `Text("Restaurants entdecken")`, die Übersetzungen in `Resources/Localizable.xcstrings`.
Außerhalb von Views: `String(localized: "Gast", bundle: .appLanguage)`.
Die Sprache lässt sich unter Konto > Einstellungen ohne Neustart umstellen.
