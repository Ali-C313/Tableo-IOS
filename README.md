<div align="center">

<img src="Tableo/Assets.xcassets/AppIcon.appiconset/app-icon-1024.png" width="140" alt="Tableo App-Icon" />

# Tableo

**Bestellen am Tisch, zum Abholen oder per Lieferung. Für Restaurants, Cafés und Shisha-Bars.**

Native iOS-App in Swift und SwiftUI mit Firebase als Backend.
Gäste bestellen, das Personal arbeitet die Bestellungen live ab und Fahrer liefern mit Live-Tracking aus.

<br />

![Swift](https://img.shields.io/badge/Swift-5-F05138?style=for-the-badge&logo=swift&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-iOS%2018.2+-0D96F6?style=for-the-badge&logo=apple&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore%20%7C%20Storage-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![MapKit](https://img.shields.io/badge/MapKit-Live--Tracking-34C759?style=for-the-badge&logo=apple&logoColor=white)

![Architektur](https://img.shields.io/badge/Architektur-MVVM-B5651D?style=flat-square)
![Sprachen](https://img.shields.io/badge/Sprachen-10-B5651D?style=flat-square)
![Dark Mode](https://img.shields.io/badge/Dark%20Mode-ja-1B1712?style=flat-square)
![RTL](https://img.shields.io/badge/Arabisch-rechts%20nach%20links-1B1712?style=flat-square)

<br />

<img src="Tableo/Assets.xcassets/cuisine_burger.imageset/cuisine_burger.png" width="52" />&nbsp;
<img src="Tableo/Assets.xcassets/cuisine_pizza.imageset/cuisine_pizza.png" width="52" />&nbsp;
<img src="Tableo/Assets.xcassets/cuisine_sushi.imageset/cuisine_sushi.png" width="52" />&nbsp;
<img src="Tableo/Assets.xcassets/cuisine_pasta.imageset/cuisine_pasta.png" width="52" />&nbsp;
<img src="Tableo/Assets.xcassets/cuisine_asiatisch.imageset/cuisine_asiatisch.png" width="52" />&nbsp;
<img src="Tableo/Assets.xcassets/cuisine_indisch.imageset/cuisine_indisch.png" width="52" />&nbsp;
<img src="Tableo/Assets.xcassets/cuisine_fastfood.imageset/cuisine_fastfood.png" width="52" />&nbsp;
<img src="Tableo/Assets.xcassets/cuisine_fruehstueck.imageset/cuisine_fruehstueck.png" width="52" />&nbsp;
<img src="Tableo/Assets.xcassets/cuisine_kaffee.imageset/cuisine_kaffee.png" width="52" />&nbsp;
<img src="Tableo/Assets.xcassets/cuisine_getraenke.imageset/cuisine_getraenke.png" width="52" />&nbsp;
<img src="Tableo/Assets.xcassets/cuisine_shisha.imageset/cuisine_shisha.png" width="52" />

</div>

---

## Inhalt

- [Über das Projekt](#über-das-projekt)
- [Funktionen](#funktionen)
- [So läuft eine Bestellung](#so-läuft-eine-bestellung)
- [Live-Tracking](#live-tracking)
- [Architektur](#architektur)
- [Datenmodell](#datenmodell)
- [Projektstruktur](#projektstruktur)
- [Technologien](#technologien)
- [Sprachen](#sprachen)
- [Installation](#installation)
- [Autor](#autor)

---

## Über das Projekt

Tableo ersetzt die Papierkarte und den Zettelblock. Gäste sehen die Speisekarte auf dem eigenen Handy,
bestellen direkt an den Tisch, holen später ab oder lassen sich liefern. Die Küche sieht neue Bestellungen
sofort im Dashboard, und bei Lieferungen verfolgt der Kunde den Fahrer live auf der Karte.

Die App ist die native iOS-Version von Tableo. Daneben gibt es eine
[Kotlin-Multiplatform-Version](https://github.com/Ali-C313/Tableo-KMP) für Android.
Beide nutzen dasselbe Firebase-Projekt und arbeiten mit denselben Daten:
Eine Bestellung vom iPhone erscheint sofort im Dashboard auf dem Android-Tablet und umgekehrt.

---

## Funktionen

Eine App, drei Rollen. Welche Bereiche man sieht, hängt vom Konto ab.

<table>
<tr>
<th width="33%">Gäste &amp; Kunden</th>
<th width="33%">Personal</th>
<th width="33%">Fahrer</th>
</tr>
<tr valign="top">
<td>

- Restaurants nach Küche, Art und Name filtern
- Geöffnete Restaurants zuerst
- Abholung oder Lieferung umschalten
- Lieferadresse per Standort oder Suche
- Speisekarte mit Preisen in EUR, USD, GBP und TRY
- Am Tisch, zur Abholzeit oder als Lieferung bestellen
- Bestellen auch ohne Konto als Gast
- Status jeder Bestellung live
- Benachrichtigung bei jedem neuen Schritt
- Erneut bestellen mit einem Tipp
- Stornieren, solange noch nicht gekocht wird

</td>
<td>

- Dashboard mit allen offenen Bestellungen
- Status von Neu über In Zubereitung bis Fertig
- Dienst-Schalter mit Benachrichtigung bei neuen Bestellungen
- Speisekarte verwalten, mit Foto-Upload
- Artikel als ausverkauft markieren
- Team mit Rollen (Leitung, Kellner, Koch, Küchenhilfe, Bar, Lieferant)
- Archiv aller abgeschlossenen Bestellungen
- Statistik: Umsatz und Bestellungen für 24 Std., 3 Tage, 1 Monat oder 6 Monate

</td>
<td>

- Abholbereite Lieferungen annehmen
- Eigene Tour planen und umsortieren
- Tour starten, Standort wird live geteilt
- Navigation mit Apple Karten
- Zustellung bestätigen, die nächste rückt nach
- Benachrichtigung bei neuen Lieferungen

</td>
</tr>
</table>

**Außerdem:** Hell- und Dunkelmodus, 10 Sprachen ohne Neustart umschaltbar, Arabisch von rechts nach links,
Profilbild, Konto löschen mit 30 Tagen Bedenkzeit, Impressum, Datenschutz und AGB in der App.

---

## So läuft eine Bestellung

```mermaid
flowchart LR
    A([Restaurant wählen]) --> B[Speisekarte]
    B --> C{Wie bestellen?}
    C -->|Am Tisch| D[Tischnummer]
    C -->|Abholung| E[Uhrzeit]
    C -->|Lieferung| F[Adresse]
    D --> G[Warenkorb & Bezahlart]
    E --> G
    F --> G
    G --> H[(Firestore)]
    H --> I[Dashboard im Restaurant]
    H --> J[Meine Bestellungen]
```

Jede Bestellung durchläuft feste Schritte. Am Tisch und bei Abholung endet sie in der Küche,
eine Lieferung geht danach an die Fahrer:

```mermaid
stateDiagram-v2
    direction LR
    [*] --> Offen
    Offen --> InZubereitung: Personal startet
    InZubereitung --> Fertig
    Fertig --> Erledigt: Tisch / Abholung
    Fertig --> Abholbereit: Lieferung
    Abholbereit --> Angenommen: Fahrer nimmt an
    Angenommen --> Unterwegs: Tour startet
    Unterwegs --> Erledigt: zugestellt
    Offen --> Storniert: Kunde oder Restaurant
    InZubereitung --> Storniert: Restaurant
    Abholbereit --> Storniert: Restaurant
    Erledigt --> [*]
    Storniert --> [*]
```

Das Stornieren läuft über eine Firestore-Transaktion. So kann eine Bestellung nicht gleichzeitig
storniert und vom Fahrer angenommen werden.

---

## Live-Tracking

Sobald ein Fahrer eine Lieferung annimmt, schickt die App seinen Standort an alle Bestellungen seiner Tour.
Der Kunde sieht den Fahrer auf der Karte und eine geschätzte Ankunftszeit. Darin sind auch die
Lieferungen eingerechnet, die der Fahrer vorher noch macht.

```mermaid
sequenceDiagram
    participant F as Fahrer-App
    participant DB as Firestore
    participant K as Kunden-App

    F->>DB: Lieferung annehmen (Platz in der Tour)
    DB-->>K: Status "Angenommen"
    K->>K: Benachrichtigung "Fahrer gefunden"
    F->>DB: Tour starten
    loop alle 10 Meter
        F->>DB: Standort an alle Bestellungen der Tour
        DB-->>K: neuer Standort
        K->>K: Karte und Ankunftszeit aktualisieren
    end
    F->>DB: Zugestellt
    DB-->>K: Status "Erledigt"
```

Die Ankunftszeit rechnet mit rund 25 km/h in der Stadt und 3 Minuten pro Übergabe an der Tür.
Die Strecke geht über alle Stopps, die vorher noch dran sind.

---

## Architektur

Die App ist nach **MVVM** aufgebaut. Views zeigen nur an, ViewModels halten den Zustand und sprechen mit Firebase.

```mermaid
flowchart TB
    subgraph UI [Views]
        V1[HomeView]
        V2[MenuView]
        V3[DashboardView]
        V4[DriverView]
    end

    subgraph VM [ViewModels]
        G[App-weit<br/>User · Settings · Navigation<br/>Cart · Delivery · Shift · OrderUpdates]
        S[pro Screen<br/>Restaurant · Menu · Dashboard<br/>Driver · Tracking · Team · ...]
    end

    subgraph Data [Daten]
        FM[FirebaseManager]
        R[ExchangeRateRepository]
        LM[LocationManager]
        NM[NotificationManager]
    end

    UI -->|"@EnvironmentObject / @StateObject"| VM
    VM --> FM
    VM --> R
    VM --> LM
    VM --> NM
    FM --> FB[(Firebase<br/>Auth · Firestore · Storage)]
    R --> API[(frankfurter.app)]
```

- **ViewModels** sind `ObservableObject`-Klassen mit `@Published`-Variablen und laufen auf dem `@MainActor`.
- **Live-Daten** kommen über Firestore-Snapshot-Listener. Eine View startet den Listener in `onAppear`
  und beendet ihn in `onDisappear`.
- **App-weite ViewModels** werden einmal in `TableoApp` erstellt und mit `environmentObject` weitergegeben,
  z.B. der Warenkorb, der über mehrere Screens erhalten bleibt.
- **Navigation:** Jeder Tab hat einen eigenen `NavigationStack`, alle Ziele sind im Enum `Route` beschrieben.
- **Wechselkurse** kommen über ein Repository mit Protocol, das mit `URLSession` und `Codable` arbeitet.

---

## Datenmodell

```mermaid
erDiagram
    RESTAURANT ||--o{ MENU_ITEM : "hat"
    RESTAURANT ||--o{ ORDER : "bekommt"
    RESTAURANT ||--o{ STAFF_PROFILE : "beschäftigt"
    USER ||--o{ ORDER : "bestellt"
    USER ||--o| STAFF_PROFILE : "arbeitet als"
    ORDER ||--|{ ORDER_ITEM : "enthält"

    RESTAURANT {
        string name
        string type
        string address
        array cuisineTypes
        string openingTime
        string closingTime
        bool offersDelivery
    }
    MENU_ITEM {
        string restaurantId
        string name
        double price
        string category
        string imageUrl
        bool available
    }
    ORDER {
        string restaurantId
        string userId
        string orderType
        string status
        string paymentMethod
        map deliveryLocation
        map driverLocation
        int tourPosition
        long createdAt
    }
    ORDER_ITEM {
        string menuItemId
        string name
        double pricePerItem
        int quantity
    }
    STAFF_PROFILE {
        string restaurantId
        string userId
        string role
        bool onDuty
    }
```

| Collection      | Inhalt                                                   |
|-----------------|----------------------------------------------------------|
| `restaurants`   | Restaurants mit Öffnungszeiten und Küchen                |
| `menuItems`     | Artikel der Speisekarte, gehören zu einem Restaurant     |
| `orders`        | Bestellungen mit Positionen, Status und Fahrer-Standort  |
| `staffProfiles` | Mitarbeiter, die Dokument-ID ist die User-ID             |
| `users`         | Vormerkung zum Löschen eines Kontos                      |

---

## Projektstruktur

```
Tableo/
├── TableoApp.swift          Start der App, Firebase und die ViewModels für die ganze App
├── Enums/                   OrderStatus, OrderType, Route, StaffRole, ThemeMode ...
├── Models/                  FireRestaurant, FireMenuItem, FireOrder, FireStaffProfile ...
├── ViewModels/              ein ViewModel pro Bereich
├── Views/
│   ├── Start/               Splash und Onboarding
│   ├── Main/                RootView, Tabs und Navigation
│   ├── Home/                Startseite mit allen Restaurants
│   ├── Menu/                Speisekarte
│   ├── Order/               Bestelldetails, Warenkorb, Bestätigung
│   ├── MyOrders/            Meine Bestellungen, Details, Live-Tracking
│   ├── Auth/                Anmelden und Registrieren
│   ├── Settings/            Konto, Kontoinformationen, Rechtliches
│   ├── Staff/               Dashboard, Archiv, Speisekarte, Team, Statistik
│   ├── Driver/              Fahrer-Bereich
│   └── Components/          kleine Views für mehrere Screens
├── Repositories/            Wechselkurs-API
├── Utils/                   FirebaseManager, Standort, Benachrichtigungen, Formatierung
├── Theme/                   Farben, Schriften, Button-Stile
├── Assets.xcassets          App-Icon, Logo, Bilder der Küchen
└── Resources/               String Catalog, Schriften, Info.plist
```

---

## Technologien

| Bereich              | Umsetzung                                                    |
|----------------------|--------------------------------------------------------------|
| Sprache & UI         | Swift 5, SwiftUI                                             |
| Architektur          | MVVM mit `ObservableObject`, `@Published`, `@EnvironmentObject` |
| Anmeldung            | Firebase Auth (E-Mail, anonym für Gäste)                     |
| Datenbank            | Cloud Firestore mit Snapshot-Listenern, Transaktionen, Batches |
| Bilder               | Firebase Storage, `AsyncImage`, `PhotosPicker`               |
| Karte & Standort     | MapKit, CoreLocation, CLGeocoder                             |
| Benachrichtigungen   | UserNotifications                                            |
| Netzwerk             | `URLSession`, `Codable`, Wechselkurse von frankfurter.app    |
| Übersetzungen        | String Catalog (`Localizable.xcstrings`)                     |
| Design               | eigene Farben für Hell und Dunkel, Fraunces und Manrope als Schriften |

---

## Sprachen

Die Sprache lässt sich in der App unter **Konto > Einstellungen** ohne Neustart umstellen.

| | | | | |
|:-:|:-:|:-:|:-:|:-:|
| Deutsch | English | Türkçe | العربية | Español |
| Français | Italiano | Polski | Русский | Українська |

Die Texte stehen auf Deutsch im Code, die Übersetzungen im String Catalog.
Bei Arabisch dreht sich die ganze Oberfläche auf rechts nach links.

---

## Installation

**Voraussetzungen:** Xcode 16 oder neuer, iOS 18.2 oder neuer, ein Firebase-Projekt.

1. Repository klonen
   ```bash
   git clone https://github.com/Ali-C313/Tableo-IOS.git
   ```
2. In der [Firebase Console](https://console.firebase.google.com) eine iOS-App anlegen,
   die `GoogleService-Info.plist` herunterladen und nach `Tableo/Resources` legen.
   Die Datei ist bewusst nicht im Repository.
3. In Firebase **Authentication** (E-Mail/Passwort und Anonym), **Firestore** und **Storage** aktivieren.
4. `Tableo.xcodeproj` öffnen. Xcode lädt das Firebase-Paket beim ersten Öffnen selbst.
5. Unter *Signing & Capabilities* das eigene Team wählen, die Bundle-ID steht in `Configuration/Config.xcconfig`.
6. Simulator oder iPhone wählen und starten.

---

## Autor

**Ali Chehab**

[![GitHub](https://img.shields.io/badge/GitHub-Ali--C313-181717?style=flat-square&logo=github)](https://github.com/Ali-C313)

Entstanden als Abschlussprojekt im Syntax Institut.
