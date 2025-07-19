//
//  EditServiceTypeView.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/18/25.
//
import SwiftUI
import SwiftData

struct EditServiceTypeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Bindable var type: ServiceType

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Service Type Name", text: $type.name)
                }

                Section {
                    Button("Save Changes") {
                        try? modelContext.save()
                        dismiss()
                    }
                }
            }
            .navigationTitle("Edit Service Type")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
