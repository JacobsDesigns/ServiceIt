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

    var recordToEdit: ServiceRecord? = nil
    var vehicleMileage: Int? = nil

    @Query var serviceTypes: [ServiceType]
    @Query var serviceProviders: [ServiceProvider]
    @Query var vehicles: [Vehicle]

    @State private var selectedVehicle: Vehicle?
    @State private var selectedType: ServiceType?
    @State private var selectedProvider: ServiceProvider?
    @State private var cost: String = ""
    @State private var date: Date = .now
    @State private var mileage: String = ""
    @State private var showingTypeManager = false
    @State private var showingDeleteAlert = false

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Vehicle")) {
                    Picker("Vehicle", selection: $selectedVehicle) {
                        Text("Select Vehicle").tag(nil as Vehicle?)
                        ForEach(vehicles) { vehicle in
                            Text("\(vehicle.modelYear) \(vehicle.name)")
                                .tag(vehicle as Vehicle?)
                        }
                    }

                    if let mileageHint = vehicleMileage, mileage.isEmpty {
                        Button("Use Current Mileage (\(mileageHint) mi)") {
                            mileage = String(mileageHint)
                        }
                        .buttonStyle(.bordered)
                    }
                }

                Section(header: Text("Service Info")) {
                    Picker("Provider", selection: $selectedProvider) {
                        Text("Select Provider").tag(nil as ServiceProvider?)
                        ForEach(serviceProviders) { provider in
                            Text(provider.name).tag(provider as ServiceProvider?)
                        }
                    }

                    Picker("Type", selection: $selectedType) {
                        Text("Select Type").tag(nil as ServiceType?)
                        ForEach(serviceTypes) { type in
                            Text(type.name).tag(type as ServiceType?)
                        }
                    }

                    TextField("Cost", text: $cost)
                        .keyboardType(.decimalPad)

                    DatePicker("Date", selection: $date, displayedComponents: .date)

                    TextField("Mileage", text: $mileage)
                        .keyboardType(.decimalPad)
                }

                Section {
                    Button(recordToEdit == nil ? "Add Service" : "Save Changes") {
                        saveRecord()
                        dismiss()
                    }
                    .disabled(selectedVehicle == nil || selectedType == nil || selectedProvider == nil || Double(cost) == nil)

                    Button("Add Service Type") {
                        showingTypeManager = true
                    }
                    .sheet(isPresented: $showingTypeManager) {
                        ServiceTypeListView()
                    }

                    if recordToEdit != nil {
                        Button("Delete Record", role: .destructive) {
                            showingDeleteAlert = true
                        }
                    }
                }
            }
            .navigationTitle(recordToEdit == nil ? "New Service" : "Edit Service")
            .onAppear {
                populateEditingFields()
                initializeDefaultsIfNeeded()
            }
            .alert("Delete Service Record?", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    deleteRecord()
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }

    // MARK: - Helpers

    private func populateEditingFields() {
        guard let record = recordToEdit else { return }
        selectedVehicle = record.vehicle
        selectedProvider = record.provider
        selectedType = record.type
        cost = String(record.cost)
        date = record.date
        mileage = String(record.mileage)
    }

    private func initializeDefaultsIfNeeded() {
        if recordToEdit == nil {
            selectedVehicle = vehicles.first
            selectedProvider = serviceProviders.first
            selectedType = serviceTypes.first
        }
    }

    private func saveRecord() {
        guard let vehicle = selectedVehicle,
              let provider = selectedProvider,
              let type = selectedType,
              let costValue = Double(cost) else { return }

        if let record = recordToEdit {
            record.vehicle = vehicle
            record.provider = provider
            record.type = type
            record.cost = costValue
            record.date = date
            record.mileage = Int(mileage) ?? 0
        } else {
            let newRecord = ServiceRecord(
                vehicle: vehicle,
                type: type,
                cost: costValue,
                date: date,
                mileage: Int(mileage) ?? 0,
                provider: provider
            )
            modelContext.insert(newRecord)
        }

        try? modelContext.save()
    }

    private func deleteRecord() {
        guard let record = recordToEdit else { return }
        modelContext.delete(record)
        try? modelContext.save()
    }
}

#Preview {
    let civic = Vehicle(name: "Civic", modelYear: 2020, vin: "VIN123", currentMileage: 22000, license: "ABC123")
    let oilChange = ServiceType(name: "Oil Change")
    let autofix = ServiceProvider(name: "AutoFix", contactInfo: "autofix@example.com")

    let sampleRecord = ServiceRecord(
        vehicle: civic,
        type: oilChange,
        cost: 89.99,
        date: .now,
        mileage: 22000,
        provider: autofix
    )

    return ServiceRecordFormView(
        recordToEdit: sampleRecord,
        vehicleMileage: civic.currentMileage
    )
    .modelContainer(for: [
        Vehicle.self,
        ServiceType.self,
        ServiceProvider.self,
        ServiceRecord.self
    ])
}
