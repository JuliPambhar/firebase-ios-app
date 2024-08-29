//
//  BookInfo.swift
//  FirebaseApp
//
//  Created by Juli Pambhar on 2024-08-25.
//

import Foundation
struct Item: Identifiable, Codable, Equatable {
    var id: String = UUID().uuidString
    var name: String
    var description: String
}
