//
//  AddServiceTypeView.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/18/25.
//
import SwiftUI
import SwiftData

struct AddServiceItemView: View {
    //@Environment(\.dismiss) private var dismiss
    //@Environment(\.modelContext) private var modelContext
    //@Binding var addedItems: [ServiceItem]
    
    @State private var newServiceName = ""
    @State private var newItemCost = ""

    var body: some View {
        Text("Hi")
//        VStack(spacing: 16) {
//            TextField("Service Name", text: $newServiceName)
//                .textFieldStyle(.roundedBorder)
//
//            TextField("Cost", text: $newItemCost)
//                .textFieldStyle(.roundedBorder)
//                .keyboardType(.decimalPad)
//
//            Button("Add Item") {
//                let trimmedName = newServiceName.trimmingCharacters(in: .whitespacesAndNewlines)
//                let trimmedCost = newItemCost.trimmingCharacters(in: .whitespacesAndNewlines)
//
//                guard !trimmedName.isEmpty, let cost = Double(trimmedCost) else { return }
//
//                let newItem = ServiceItem(name: trimmedName, cost: cost)
//                modelContext.insert(newItem)
//                try? modelContext.save()
//                addedItems.append(newItem)
//                dismiss()
//            }
//            .disabled(newServiceName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
//                      Double(newItemCost.trimmingCharacters(in: .whitespacesAndNewlines)) == nil)
//
//            Spacer()
//        }
//        .padding()
    }
}



 
