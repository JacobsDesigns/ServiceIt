//
//  AddServiceTypeView.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/18/25.
//


import SwiftUI
import SwiftData

struct AddServiceTypeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var name = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Service Type Name", text: $name)
                }

                Section {
                    Button("Save Service Type") {
                        let type = ServiceType(name: name)
                        modelContext.insert(type)
                        try? modelContext.save()
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .navigationTitle("Add Service Type")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
