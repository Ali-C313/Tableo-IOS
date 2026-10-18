//
//  OrderCancel.swift
//  Tableo
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseFirestore

extension Firestore {
    /// Storniert in einer Transaktion, damit nichts dazwischenkommt.
    /// Kunden dürfen nur solange offen, das Restaurant bis der Fahrer losfährt
    func cancelOrder(orderId: String, byRestaurant: Bool) async throws {
        let reference = collection("orders").document(orderId)

        let result = try await runTransaction { transaction, errorPointer -> Any? in
            let snapshot: DocumentSnapshot
            do {
                snapshot = try transaction.getDocument(reference)
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }

            let status = OrderStatus(rawValue: snapshot.get("status") as? String ?? "")
            let allowed = byRestaurant ? (status?.canRestaurantCancel == true) : (status == .offen)

            if allowed {
                transaction.updateData([
                    "status": OrderStatus.storniert.rawValue,
                    "cancelledByRestaurant": byRestaurant
                ], forDocument: reference)
            }
            return allowed
        }

        if (result as? Bool) != true {
            throw byRestaurant ? OrderError.alreadyOnTheWay : OrderError.alreadyInPreparation
        }
    }
}
