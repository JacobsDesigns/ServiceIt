//
//  ItemPickerSheet.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/27/25.
//
import SwiftUI
import SwiftData

struct ItemPickerSheet: View {
    
    @Environment(\.modelContext) private var modelContext
    let serviceItems: [ServiceItem]
    @Binding var selectedItem: ServiceItem?
    @Binding var costInput: String
    @Binding var addedItems: [SavedServiceItem]
    var visitToEdit: ServiceVisit?
    @Binding var isPresented: Bool
    @FocusState private var isCostFieldFocused: Bool
    
    @State private var showAddItemOverlay = false
    @State private var tempName: String = ""
    @State private var tempCost : String = ""
    
    var body: some View {
        
        let sortedItems = serviceItems.sorted { $0.name < $1.name }
        
        NavigationStack {
            Form {
                Section(header: Text("Edit Cost if needed")) {
                    HStack {
                        Text("$")
                        TextField("Enter Cost", text: $costInput)
                            .keyboardType(.decimalPad)
                            .focused($isCostFieldFocused)
                    }
                }

                Section (header: Text("Select a Service Item")) {
                        ForEach(sortedItems) { item in
                            Button {
                                selectedItem = item
                                costInput = String(format: "%.2f", item.cost)
                            } label: {
                                HStack {
                                    Text(item.name)
                                    Spacer()
                                    Text("\(item.cost, format: .currency(code: "USD"))")
                                }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                }

                Section (header: Text("Add New Service Item")){
                    Button("Add"){
                        withAnimation {
                            showAddItemOverlay = true
                        }
                    }
                }


            }
            .navigationTitle("Add Item")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isCostFieldFocused = false // Dismisses the keyboard
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        selectedItem = nil
                        costInput = ""
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
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
        .overlay(
            Group {
                if showAddItemOverlay {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                        VStack(spacing: 20) {
                            Text("Add New Service Item")
                                .font(.headline)
                            TextField("Name", text: $tempName)
                                .textFieldStyle(.roundedBorder)
                            TextField("Cost", text: $tempCost)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                            HStack {
                                Button("Cancel") {
                                    withAnimation {
                                        showAddItemOverlay = false
                                    }
                                }
                                Spacer()
                                Button("Save") {
                                    let trimmedName = tempName.trimmingCharacters(in: .whitespacesAndNewlines)
                                    let trimmedCost = tempCost.trimmingCharacters(in: .whitespacesAndNewlines)
                                    
                                    guard !trimmedName.isEmpty else { return }
                                    
                                    let newItem = ServiceItem(name: trimmedName, cost: Double(trimmedCost) ?? 0)
                                    modelContext.insert(newItem)
                                    try? modelContext.save()
                                    withAnimation {
                                        showAddItemOverlay = false
                                    }
                                }
                                .disabled(tempName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .frame(maxWidth: 400)
                        .shadow(radius: 10)
                    }
                    .transition(.opacity)
                }
            }
        )
    }
    
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedItem: ServiceItem? = nil
        @State private var costInput: String = ""
        @State private var addedItems: [SavedServiceItem] = []
        @State private var isPresented: Bool = true

        let mockItems = [
            ServiceItem(name: "Oil Change", cost: 49.99),
            ServiceItem(name: "Tire Rotation", cost: 29.99),
            ServiceItem(name: "Brake Inspection", cost: 39.99)
        ]

        var body: some View {
            ItemPickerSheet(
                serviceItems: mockItems,
                selectedItem: $selectedItem,
                costInput: $costInput,
                addedItems: $addedItems,
                visitToEdit: nil,
                isPresented: $isPresented
            )
        }
    }

    return PreviewWrapper()
}
