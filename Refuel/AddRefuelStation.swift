//
//  AddRefuelStation.swift
//  ServiceIt
//
//  Created by Jacob Filek on 8/4/25.
//
import SwiftUI
import SwiftData

struct AddRefuelStation: View {
@Environment(\.dismiss) private var dismiss
@Environment(\.modelContext) private var modelContext

@State private var name = ""
@State private var location = ""

var body: some View {
    NavigationStack {
        Form {
            Section {
                HStack {
                    Text("Name: ")
                    TextField("", text: $name)
                }
                HStack {
                    Text("Location: ")
                    TextField("", text: $location)
                }
            }

        }
        .navigationTitle("Add Station")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .topBarLeading) {
                Button("Add") {
                    let newStation = RefuelStation(name: name, location: location)
                    modelContext.insert(newStation)
                    try? modelContext.save()
                    dismiss()
                }.disabled(name.isEmpty)
            }
        }
    }
 }
}

#Preview{
    AddRefuelStation()
        .modelContainer(PreviewContainer.shared)
}
