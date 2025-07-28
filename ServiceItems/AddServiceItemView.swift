//
//  AddServiceTypeView.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/18/25.
//
import SwiftUI
import SwiftData

struct AddServiceItemView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var newServiceName = ""
    @State private var newItemCost = ""
    @FocusState private var isCostFieldFocused: Bool
    
    var body: some View {
        NavigationStack{
            Form {
                Section {
                    TextField("Service Item", text: $newServiceName)
                    TextField("Cost", text: $newItemCost)
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
                
                Section {
                    Button("Save Item") {
                        let trimmedName = newServiceName.trimmingCharacters(in: .whitespacesAndNewlines)
                        let trimmedCost = newItemCost.trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        guard !trimmedName.isEmpty else { return }
                        
                        let newItem = ServiceItem(name: trimmedName, cost: Double(trimmedCost) ?? 0)
                        modelContext.insert(newItem)
                        try? modelContext.save()
                        dismiss()
                    }
                    .disabled(newServiceName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .navigationTitle("Add Service Item")
            .toolbar{
                ToolbarItem(placement: .cancellationAction){
                    Button("Cancel"){
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AddServiceItemView()
        .modelContainer(PreviewContainer.shared)
}

 
