//
//  ItemPickerSheet.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/27/25.
//
import SwiftUI
import SwiftData

struct ItemPickerSheet: View {
    let serviceItems: [ServiceItem]
    @Binding var selectedItem: ServiceItem?
    @Binding var costInput: String
    @Binding var addedItems: [SavedServiceItem]
    var visitToEdit: ServiceVisit?
    @Binding var isPresented: Bool
    @FocusState private var isCostFieldFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Menu {
                        ForEach(serviceItems) { item in
                            Button {
                                selectedItem = item
                                costInput = String(format: "%.2f", item.cost)
                            } label: {
                                Text("\(item.name) • \(item.cost, format: .currency(code: "USD"))")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    } label: {
                        Text(selectedItem?.name ?? "Select Service Item")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                Section(header: Text("Enter Cost")) {
                    TextField("Enter Cost", text: $costInput)
                        .keyboardType(.decimalPad)
                        .focused($isCostFieldFocused)
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                Button("Done") {
                                    isCostFieldFocused = false // Dismisses the keyboard
                                }
                            }
                        }

                }
            }
            .navigationTitle("Add Item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        selectedItem = nil
                        costInput = ""
                        isPresented = false
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Confirm") {
                        guard let item = selectedItem else {
                            isPresented = false
                            return
                        }

                        let cost = Double(costInput) ?? item.cost
                        let newItem = SavedServiceItem(name: item.name, cost: cost)

                        // Attach to visit if needed
                        if let visit = visitToEdit {
                            newItem.visit = visit
                        }

                        // Prevent duplicates
                        let alreadyAdded = addedItems.contains { $0.name == item.name }
                        guard !alreadyAdded else {
                            isPresented = false
                            return
                        }

                        addedItems.append(newItem)

                        // Clear state
                        selectedItem = nil
                        costInput = ""
                        isPresented = false
                    }

                }
            }
        }
    }
}
