//
//  ServiceTypeListView.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/12/25.
//


import SwiftUI
import SwiftData

struct ServiceTypeListView: View {
    @Query var serviceTypes: [ServiceType]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var newTypeName: String = ""
    @State private var editingType: ServiceType?

    var body: some View {
        NavigationStack {
            List {
                ForEach(serviceTypes) { type in
                    Text(type.name)
                        .padding(.vertical, 4)
                        .background(editingType == type ? Color.blue.opacity(0.1) : Color.clear)
                        .cornerRadius(6)
                        .onTapGesture {
                            editingType = type
                            newTypeName = type.name
                        }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        modelContext.delete(serviceTypes[index])
                    }
                }

                Section(header: Text(editingType == nil ? "Add New Type" : "Edit Type")) {
                    TextField("Service Type Name", text: $newTypeName)

                    Button(editingType == nil ? "Add Service Type" : "Save Changes") {
                        saveType()
                    }
                    .disabled(newTypeName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .navigationTitle("Service Types")
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing){
                    Button("Cancel"){
                        dismiss()
                    }
                }
            }
        }
    }

    private func saveType() {
        let trimmed = newTypeName.trimmingCharacters(in: .whitespaces)

        if let type = editingType {
            type.name = trimmed
        } else {
            let newType = ServiceType(name: trimmed)
            modelContext.insert(newType)
        }

        do {
            try modelContext.save()
            newTypeName = ""
            editingType = nil
            
        } catch {
            print("❌ Failed to save type: \(error)")
        }
    }
}
