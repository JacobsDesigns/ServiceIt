//
//  ServiceTypeListView.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/12/25.
//
import SwiftUI
import SwiftData

struct ServiceItemListView: View {
    @Query var serviceTypes: [ServiceItem]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var newTypeName: String = ""
    @State private var newTypeCost: String = ""
    @State private var editingType: ServiceItem?

    var body: some View {
        NavigationStack {
            List {
                ForEach(serviceTypes) { type in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(type.name)
                            Text("$\(type.cost, specifier: "%.2f")")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 4)
                    .background(editingType == type ? Color.blue.opacity(0.1) : Color.clear)
                    .cornerRadius(6)
                    .onTapGesture {
                        editingType = type
                        newTypeName = type.name
                        newTypeCost = String(format: "%.2f", type.cost)
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        modelContext.delete(serviceTypes[index])
                    }
                }

                Section(header: Text(editingType == nil ? "Add New Item" : "Edit Item")) {
                    TextField("Service Item", text: $newTypeName)
                    TextField("Cost", text: $newTypeCost)
                        .keyboardType(.decimalPad)

                    Button(editingType == nil ? "Add Service Item" : "Save Changes") {
                        saveType()
                    }
                    .disabled(newTypeName.trimmingCharacters(in: .whitespaces).isEmpty ||
                              Double(newTypeCost.trimmingCharacters(in: .whitespaces)) == nil)
                }
            }
            .navigationTitle("Service Items")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func saveType() {
        let trimmedName = newTypeName.trimmingCharacters(in: .whitespaces)
        let trimmedCost = newTypeCost.trimmingCharacters(in: .whitespaces)
        guard let cost = Double(trimmedCost) else { return }

        if let type = editingType {
            type.name = trimmedName
            type.cost = cost
        } else {
            let newType = ServiceItem(name: trimmedName, cost: cost)
            modelContext.insert(newType)
        }

        do {
            try modelContext.save()
            newTypeName = ""
            newTypeCost = ""
            editingType = nil
        } catch {
            print("❌ Failed to save type: \(error)")
        }
    }
}


#Preview {
    ServiceItemListView()
        .modelContainer(PreviewContainer.shared)
}
