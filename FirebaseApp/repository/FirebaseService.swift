//
//  FirebaseService.swift
//  FirebaseApp
//
//  Created by Juli Pambhar on 2024-08-26.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseDatabase
import FirebaseDatabaseInternal


class RealFirebaseService: FirebaseService {
    private let db = Firestore.firestore()
    private let ref = Database.database().reference()
    
    func fetchFirestoreItems() -> AnyPublisher<[Item], Error> {
        let subject = PassthroughSubject<[Item], Error>()
        
        db.collection("items").addSnapshotListener { querySnapshot, error in
            if let error = error {
                subject.send(completion: .failure(error))
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                subject.send([])
                return
            }
            
            let items = documents.compactMap { document -> Item? in
                try? document.data(as: Item.self)
            }
            subject.send(items)
        }
        
        return subject.eraseToAnyPublisher()
    }
    
    func fetchRealtimeDBItems() -> AnyPublisher<[Item], Error> {
        let subject = PassthroughSubject<[Item], Error>()
        
        ref.child("items").observe(.value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                subject.send([])
                return
            }
            
            let items = value.compactMap { key, value -> Item? in
                guard let itemDict = value as? [String: Any] else { return nil }
                return Item(id: key, name: itemDict["name"] as? String ?? "", description: itemDict["description"] as? String ?? "")
            }
            subject.send(items)
        }
        
        return subject.eraseToAnyPublisher()
    }
    
    func addItemToFirestore(_ item: Item) -> AnyPublisher<Void, Error> {
        return Future { promise in
            do {
                _ = try self.db.collection("items").addDocument(from: item)
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    func addItemToRealtimeDB(_ item: Item) -> AnyPublisher<Void, Error> {
        return Future { promise in
            self.ref.child("items").childByAutoId().setValue([
                "name": item.name,
                "description": item.description
            ]) { error, _ in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
}
