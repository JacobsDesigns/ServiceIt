//
//  EditItemSheet.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/27/25.
//
import SwiftUI

struct EditItemSheet: View {
    @State var item: SavedServiceItem
    var onSave: (SavedServiceItem) -> Void
    var onCancel: () -> Void
    @FocusState private var isCostFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                
                Section("Service Item") {
                    TextField("Service Item", text: $item.name)
                }
                Section("Cost") {
                    TextField("Cost ($)", value: $item.cost, formatter: NumberFormatter())
                        .keyboardType(.decimalPad)
                        .focused($isCostFieldFocused)
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard){
                                Spacer()
                                Button("Done") {
                                    isCostFieldFocused = false
                                }
                            }
                        }
                    
                    Text("Previous Cost: \(String(format: "$%.2f", item.cost))")
                        .foregroundStyle(.secondary)
                }
            }
            
            .navigationTitle("Edit Item")
            .toolbar {
                ToolbarItem(placement: .confirmationAction){
                    Button("Save") {onSave(item)}
                }
                ToolbarItem(placement: .cancellationAction){
                    Button("Cancel", action: onCancel)
                }
            }
        }
    }
}
