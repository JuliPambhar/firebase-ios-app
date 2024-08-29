//
//  ItemViewModelTest.swift
//  FirebaseAppTests
//
//  Created by Rohan Pambhar on 2024-08-27.
//

import Foundation
@testable import FirebaseApp
import XCTest

class FirebaseDataViewModelTests: XCTestCase {
    var viewModel: FirebaseDataViewModel!
    var mockRepository: MockFirebaseRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockFirebaseRepository()
        viewModel = FirebaseDataViewModel(repository: mockRepository)
    }
    
    override func tearDown() {
        viewModel = nil
        mockRepository = nil
        super.tearDown()
    }
    
    func testFetchItems() {
        // Given
        let expectation = XCTestExpectation(description: "Delayed Assertion")
        let firestoreItems = [DataInfo(id: "1", name: "Item 1", description: "Description 1")]
        let realtimeDatabaseItems = [DataInfo(id: "2", name: "Item 2", description: "Description 2")]
        mockRepository.mockFirestoreItems = firestoreItems
        mockRepository.mockRealtimeDatabaseItems = realtimeDatabaseItems
        
        // When
        viewModel.fetchItems()
        
        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            XCTAssertEqual(self.viewModel.firestoreItems, firestoreItems)
            XCTAssertEqual(self.viewModel.realtimeDBItems, realtimeDatabaseItems)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testAddItemToFirestore() {
        //Given
        let itemToAdd = DataInfo(id: "2", name: "Item 2", description: "Description 2")
        let firestoreItems = [DataInfo(id: "1", name: "Item 1", description: "Description 1")]
        mockRepository.mockFirestoreItems = firestoreItems
        
        //When
        viewModel.addItemToFirestore(itemToAdd) { error in
            XCTAssertNil(error)
            XCTAssertTrue(self.mockRepository.mockFirestoreItems.contains { $0.id == itemToAdd.id })
        }
    }
    
    func testErrorWhenAddingCorruptItemToFirestore() {
        //Given
        let itemToAdd = DataInfo(id: "", name: "", description: "")
        let firestoreItems = [DataInfo(id: "1", name: "Item 1", description: "Description 1")]
        mockRepository.mockFirestoreItems = firestoreItems
        
        //When
        viewModel.addItemToFirestore(itemToAdd) { error in
            XCTAssertNotNil(error)
        }
        
    }
    
    func testAddItemToRealtimeDB() {
        //Given
        let itemToAdd = DataInfo(id: "2", name: "Item 2", description: "Description 2")
        let realtimeDatabaseItems = [DataInfo(id: "1", name: "Item 1", description: "Description 1")]
        mockRepository.mockRealtimeDatabaseItems = realtimeDatabaseItems
        
        //When
        viewModel.addItemToRealtimeDB(itemToAdd) { error in
            XCTAssertNil(error)
            XCTAssertTrue(self.mockRepository.mockRealtimeDatabaseItems.contains { $0.id == itemToAdd.id })
        }
    }
    
    func testErrorWhenAddingCorruptItemToRealtimeDB() {
        //Given
        let itemToAdd = DataInfo(id: "", name: "", description: "")
        let realtimeDatabaseItems = [DataInfo(id: "1", name: "Item 1", description: "Description 1")]
        mockRepository.mockRealtimeDatabaseItems = realtimeDatabaseItems
        
        //When
        viewModel.addItemToRealtimeDB(itemToAdd) { error in
            XCTAssertNotNil(error)
        }
    }
}
