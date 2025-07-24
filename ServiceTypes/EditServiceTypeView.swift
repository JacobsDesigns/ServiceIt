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
    @State private var mileageText: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Service Type Name", text: $type.name)

                    TextField("Suggested Interval (mi)", text: $mileageText)
                        .keyboardType(.numberPad)
                        .onChange(of: mileageText) {
                            if let value = Int(mileageText) {
                                type.suggestedMileage = value
                            } else {
                                type.suggestedMileage = nil
                            }
                        }
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
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        hideKeyboard()
                    }
                }
            }
            .onAppear {
                mileageText = type.suggestedMileage.map(String.init) ?? ""
            }
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
