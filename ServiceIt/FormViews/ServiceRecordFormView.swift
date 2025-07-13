//
//  ServiceRecordFormView.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/12/25.
//


import SwiftUI
import SwiftData

struct ServiceRecordFormView: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @Bindable var provider: ServiceProvider
    @State var editingRecord: ServiceRecord?

    @State private var cost: String = ""
    @State private var date: Date = Date()
    @State private var mileage: String = ""
    
    @Query var serviceTypes: [ServiceType]
    @State private var selectedType: ServiceType?
    
    @State private var showingTypeManager = false
    @State private var showingDeleteAleat = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Service Info")) {
                    
                    Picker("Service Type", selection: $selectedType){
                        Text("Select Type").tag(nil as ServiceType?)
                        ForEach(serviceTypes) { serviceType in
                            Text(serviceType.name).tag(serviceType as ServiceType?)
                        }
                    }
                    
                    TextField("Cost", text: $cost)
                        .keyboardType(.decimalPad)
                    
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    
                    TextField("Mileage", text: $mileage)
                        .keyboardType(.decimalPad)
                }// end section

                Section {
                    
                    Button(editingRecord == nil ? "Add Service" : "Save Changes") {
                        saveRecord()
                        dismiss()
                    }
                    .disabled(selectedType == nil || Double(cost) == nil)
                    
                    Button("Add Service Type") {
                        showingTypeManager = true
                    }
                    .sheet(isPresented: $showingTypeManager){
                        ServiceTypeListView()
                    }
                    
                    if editingRecord != nil {
                        Button("Delete Record", role: .destructive) {
                            showingDeleteAleat = true
                        }
                    }
                }//end section
                
                
                
            }
            .navigationTitle(editingRecord == nil ? "New Service" : "Edit Service")
            
            .onAppear {

                if let record = editingRecord {
                    selectedType = record.type
                    cost = String(record.cost)
                    date = record.date
                    mileage = String(record.mileage)
                } else if selectedType == nil {
                    selectedType = serviceTypes.first
                }
            }
            
            .alert("Delete Service Record?", isPresented: $showingDeleteAleat){
                Button("Delete", role: .destructive){
                    deleteRecord()
                    dismiss()
                }
                Button("Cancel", role: .cancel){}
            } message: {
                Text("This action cannot be undone.")
            }
            
        }
    }

    private func saveRecord() {
        guard let serviceType = selectedType else { return }
        if let record = editingRecord {
            record.type = serviceType
            record.cost = Double(cost) ?? 0
            record.date = date
            record.mileage = Int(mileage) ?? 0
        } else {
            let newRecord = ServiceRecord(type: serviceType,
                                          cost: Double(cost) ?? 0,
                                          date: date,
                                          mileage: Int(mileage) ?? 0,
                                          provider: provider)
            provider.records.append(newRecord)
        }
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    
    private func deleteRecord() {
        guard let record = editingRecord else { return }
        modelContext.delete(record)
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    
    
}

#Preview {
    let sampleType = ServiceType(name: "Brake Check")
    let sampleProvider = ServiceProvider(name: "Speedy Auto", contactInfo: "123-456-7890")
    let sampleRecord = ServiceRecord(type: sampleType,
                                     cost: 49.99,
                                     date: Date(), mileage: 12345,
                                     provider: sampleProvider)
    sampleProvider.records.append(sampleRecord)

    return ServiceRecordFormView(provider: sampleProvider, editingRecord: sampleRecord)
}
