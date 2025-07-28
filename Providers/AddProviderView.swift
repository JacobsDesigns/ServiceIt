//
//  AddProviderView.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/18/25.
//


import SwiftUI
import SwiftData

struct AddProviderView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var name = ""
    @State private var contactInfo = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Provider Name", text: $name)
                    TextField("Contact Info", text: $contactInfo)
                }

                Section {
                    Button("Save Provider") {
                        let provider = ServiceProvider(name: name, contactInfo: contactInfo)
                        modelContext.insert(provider)
                        try? modelContext.save()
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .navigationTitle("Add Provider")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    AddProviderView()
        .modelContainer(PreviewContainer.shared)
}

