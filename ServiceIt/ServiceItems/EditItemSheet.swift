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
    @State private var costText = ""
    
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Service Item") {
                    TextField("Service the Item", text: $item.name)
                }
                Section("Cost") {
                    HStack{
                        Text("$")
                        TextField("Cost ($)", text: $costText)
                            .keyboardType(.decimalPad)
                            .focused($isCostFieldFocused)
                            .onChange(of: costText){
                                if let value = Double(costText) {
                                    item.cost = value
                                } else {
                                    item.cost = 0
                                }
                            }
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer()
                                    Button("Done") {
                                        isCostFieldFocused = false
                                    }
                                }
                            }
                    }
                }
            }
                .navigationTitle("Edit Item")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing){
                        Button("Cancel", action: onCancel)
                    }
                    ToolbarItem(placement: .topBarLeading){
                        Button("Save") {onSave(item)}
                    }
            }
                .onAppear {
                    costText = String(item.cost)
                }
        }
    }
}
