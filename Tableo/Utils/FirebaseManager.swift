//
//  FirebaseManager.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class FirebaseManager {
    let auth: Auth
    let database: Firestore
    let storage: Storage

    static var shared: FirebaseManager {
        if instance == nil {
            instance = FirebaseManager()
        }
        return instance!
    }

    static private var instance: FirebaseManager?

    private init() {
        // falls noch nicht passiert, z.B. in der Preview
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        auth = Auth.auth()
        database = Firestore.firestore()
        storage = Storage.storage()
    }

    /// nil, wenn niemand oder nur ein anonymer Gast angemeldet ist
    var userId: String? {
        guard let user = auth.currentUser, !user.isAnonymous else { return nil }
        return user.uid
    }
}
