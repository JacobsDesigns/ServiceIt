//
//  EditProviderFormView.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/12/25.
//
import SwiftUI
import SwiftData

struct EditProviderFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Bindable var provider: ServiceProvider

    @State private var name: String = ""
    @State private var contact: String = ""

    var body: some View {
        NavigationStack {
            Form {
                HStack {
                    Text("Name: ")
                    TextField("", text: $name)
                }
                HStack {
                    Text("Contact Info: ")
                    TextField("", text: $contact)
                }
            }
            .navigationTitle("Edit Provider")
            .onAppear {
                name = provider.name
                contact = provider.contactInfo
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Save") {
                        provider.name = name
                        provider.contactInfo = contact

                        do {
                            try modelContext.save()
                            dismiss()
                        } catch {
                            print("Failed to save provider: \(error)")
                        }
                    }
                    .disabled(name.isEmpty || contact.isEmpty)
                    
                }
            }
        }
    }
}
#Preview {
    let newpro = ServiceProvider(name: "Provider", contactInfo: "" )
    EditProviderFormView(provider: newpro)
        .modelContainer(PreviewContainer.shared)
}
