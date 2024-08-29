//
//  ContentView.swift
//  FirebaseApp
//
//  Created by Juli Pambhar on 2024-08-25.
//

import SwiftUI

struct FirebaseDataView: View {
    
    @StateObject private var viewModel = FirebaseDataViewModel()
    @State private var showingAddItemView = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Firestore Items")) {
                    ForEach(viewModel.firestoreItems) { item in
                        ItemRow(item: item)
                    }
                }
                .accessibilityIdentifier("FireStoreSection")
                
                Section(header: Text("Realtime DB Items")) {
                    ForEach(viewModel.realtimeDBItems) { item in
                        ItemRow(item: item)
                    }
                }
                .accessibilityIdentifier("RealtimeDBSection")
            }
            .navigationTitle("Firebase Demo")
            .toolbar {
                Button(action: { showingAddItemView = true }) {
                    Image(systemName: "plus")
                }.accessibilityIdentifier("plus")
            }
            .sheet(isPresented: $showingAddItemView) {
                AddItemView(viewModel: viewModel)
            }
        }
    }
}

struct ItemRow: View {
    let item: Item
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(item.name)
                .font(.headline)
            Text(item.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

struct AddItemView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: FirebaseDataViewModel
    @State private var name = ""
    @State private var description = ""
    @State private var useFireStore = true
    @State private var showingAlert = false
    @State private var isValidationError = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name).accessibilityIdentifier("Name")
                TextField("Description", text: $description).accessibilityIdentifier("Description")
                Toggle("Use Firestore", isOn: $useFireStore).accessibilityIdentifier("Use Firestore")
            }
            .navigationTitle("Add New Item")
            .toolbar {
                Button("Save") {
                    if(name.isEmpty) {
                        alertMessage = "Name cannot be empty"
                        alertTitle = "Oops!"
                        isValidationError = true
                        showingAlert = true
                    } else if (description.isEmpty){
                        alertMessage = "Description cannot be empty"
                        alertTitle = "Oops!"
                        isValidationError = true
                        showingAlert = true
                    } else {
                        let newItem = Item(name: name, description: description)
                        if useFireStore {
                            viewModel.addItemToFirestore(newItem)
                            { error in
                                handleCompletion(error)
                            }
                        } else {
                            viewModel.addItemToRealtimeDB(newItem)
                            { error in
                                handleCompletion(error)
                            }
                        }
                    }
                }.accessibilityIdentifier("Save")
            }
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text(alertTitle),
                message:Text(alertMessage),
                dismissButton: .default(
                    Text("OK"),
                    action: {
                        if(isValidationError) {
                            isValidationError = false
                        } else {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                )
            )
        }
    }
    
    private func handleCompletion(_ error: Error?) {
        if let error = error {
            alertTitle = "Error"
            alertMessage = "Error: \(error.localizedDescription)"
        } else {
            alertTitle = "Success"
            alertMessage = "Item added successfully"
            name = ""
            description = ""
        }
        showingAlert = true
    }
    
}




#Preview {
    FirebaseDataView()
}
