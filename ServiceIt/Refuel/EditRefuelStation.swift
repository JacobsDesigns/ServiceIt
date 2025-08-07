//
//  EditRefuelStation.swift
//  ServiceIt
//
//  Created by Jacob Filek on 8/5/25.
//
import SwiftUI
import SwiftData

struct EditRefuelStation: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Bindable var provider: RefuelStation

    @State private var name: String = ""
    @State private var location: String = ""

    var body: some View {
        NavigationStack {
            Form {
                HStack {
                    Text("Name: ")
                    TextField("", text: $name)
                }
                HStack {
                    Text("Location: ")
                    TextField("", text: $location)
                }
            }
            .navigationTitle("Edit Station")
            .onAppear {
                name = provider.name
                location = provider.location
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Save") {
                        provider.name = name
                        provider.location = location

                        do {
                            try modelContext.save()
                            dismiss()
                        } catch {
                            print("Failed to save station: \(error)")
                        }
                    }
                    .disabled(name.isEmpty || location.isEmpty)
                    
                }
            }
        }
    }
}
#Preview {
    let newStation = RefuelStation(name: "Shell", location: "RSM" )
    EditRefuelStation(provider: newStation)
        .modelContainer(PreviewContainer.shared)
}
