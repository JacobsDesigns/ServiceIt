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
    @State private var suggestedMileageText = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Service Type Name", text: $name)

                    TextField("Suggested Interval (mi)", text: $suggestedMileageText)
                        .keyboardType(.numberPad)
                }

                Section {
                    Button("Save Service Type") {
                        let interval = Int(suggestedMileageText)
                        let type = ServiceType(name: name, suggestedMileage: interval)
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
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        hideKeyboard()
                    }
                }
            }
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
