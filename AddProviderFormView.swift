//
//  AddProviderFormView.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/12/25.
//

import SwiftUICore
import SwiftUI



struct AddProviderFormView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var contact = ""
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Provider Name", text: $name)
                TextField("Contact Info", text: $contact)
                
                Button("Save") {
                    let newProvider = ServiceProvider(name: name, contactInfo: contact)
                    context.insert(newProvider)
                    do {
                        try context.save()
                        dismiss()
                    } catch {
                        print("Save Failed: \(error)")
                    }
                }
                .disabled(name.isEmpty || contact.isEmpty)
            }
            .navigationTitle("Add Provider")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing){
                    Button("Cancel"){
                        dismiss()
                    }
                }
            }
        }
    }
}
