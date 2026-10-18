//
//  NotificationManager.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import UserNotifications

/// Lokale Benachrichtigungen, solange die App offen oder im Hintergrund ist
class NotificationManager: NSObject, UNUserNotificationCenterDelegate {

    static let shared = NotificationManager()

    override private init() {
        super.init()
        // ohne Delegate zeigt iOS nichts an, solange die App offen ist
        UNUserNotificationCenter.current().delegate = self
    }

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error {
                print("Fehler bei der Berechtigungsanfrage: \(error.localizedDescription)")
            }
        }
    }

    /// Gleiche id ersetzt die alte Benachrichtigung, z.B. die Bestell-ID
    func show(id: String, title: String, text: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = text
        content.sound = .default
        // trigger nil = sofort anzeigen
        let request = UNNotificationRequest(identifier: id, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
