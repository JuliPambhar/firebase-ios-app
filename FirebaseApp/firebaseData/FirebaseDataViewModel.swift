//
//  BookViewModel.swift
//  FirebaseApp
//
//  Created by Juli Pambhar on 2024-08-25.
//

import Foundation

import Firebase
import Combine
import FirebaseFirestore
import FirebaseDatabase
import FirebaseDatabaseInternal

class FirebaseDataViewModel: ObservableObject {
    @Published var firestoreItems: [Item] = []
    @Published var realtimeDBItems: [Item] = []
    
    var db: Firestore = Firestore.firestore()
    var ref: DatabaseReference = Database.database().reference()
    
    var cancelables: Set<AnyCancellable> = []
    
    private let repository: FirebaseRepository
    
    init(repository: FirebaseRepository = FirebaseRepository()) {
        self.repository = repository
        fetchItems()
    }
    
    func fetchItems() {
        repository.getFireStoreItems { [weak self] items in
            DispatchQueue.main.async {
                self?.firestoreItems = items
            }
        }
        
        repository.getRealtimeDatabaseItems { [weak self] items in
            DispatchQueue.main.async {
                self?.realtimeDBItems = items
            }
        }
    }
    
    func addItemToFirestore(_ item: Item, completion: @escaping (Error?) -> Void) {
        repository.addItemToFirestore(item, completion: completion)
    }
    
    func addItemToRealtimeDB(_ item: Item,completion: @escaping (Error?) -> (Void)) {
        repository.addItemToRealtimeDB(item, completion: completion)
    }
}
