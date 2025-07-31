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

    @Bindable var item: ServiceItem
    @State private var cost: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Service Item", text: $item.name)

                    TextField("Cost $", text: $cost)
                        .keyboardType(.numberPad)
                        .onChange(of: cost) {
                            if let value = Double(cost) {
                                item.cost = value
                            } else {
                                item.cost = 0
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
            .navigationTitle("Edit Service Item")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
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
                cost = String(item.cost)
            }
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

//#Preview {
//    let container = PreviewContainer.shared
//    let context = container.context
//    let mockType = ServiceItem(name: "Oil Change", cost: 50)
//    context.insert(mockType)
//
//    EditServiceTypeView(type: mockType)
//        .modelContainer(container)
//}
