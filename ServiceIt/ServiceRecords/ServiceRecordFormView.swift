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
    var vehicle: Vehicle? = nil

    @Query var serviceTypes: [ServiceType]
    @Query var serviceProviders: [ServiceProvider]
    @Query var allVehicles: [Vehicle]

    @State private var selectedVehicle: Vehicle?
    @State private var selectedType: ServiceType?
    @State private var selectedProvider: ServiceProvider?
    @State private var cost: String = ""
    @State private var date: Date = .now
    @State private var mileage: String = ""
    @State private var showingTypeManager = false
    @State private var showingDeleteAlert = false
    @State private var showingProviderManager = false
    @State private var showCalendar = false

    enum FieldFocus: Hashable {
        case mileage, cost
    }
    @FocusState private var focusedField: FieldFocus?
    @State private var costText: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                
                if let data = selectedVehicle?.photoData,
                   let image = UIImage(data: data) {
                    Section {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 180)
                            .cornerRadius(5)
                            .padding(.vertical, 2)
                    }
                }
                
                if vehicle == nil {
                    // Show picker only when no default vehicle passed
                    Section(header: Text("Vehicle")) {
                        Picker("Vehicle", selection: $selectedVehicle) {
                            Text("Select Vehicle").tag(nil as Vehicle?)
                            ForEach(allVehicles) { vehicle in
                                Text("\(vehicle.plainModelYearString) \(vehicle.name)")
                                    .tag(vehicle as Vehicle?)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }

                if let mileageHint = selectedVehicle?.currentMileage, mileage.isEmpty {
                    Section {
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

                    TextField("Cost", text: $costText)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .cost)
                    
                    TextField("Mileage", text: $mileage)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .mileage)
                        .onChange(of: mileage) {
                            mileage = mileage.filter { $0.isNumber }
                        }
//                        .onChange(of: mileage){ newValue in
//                            mileage = newValue.filter { $0.isNumber }
//                        }
                    
                    Button {
                        showCalendar = true
                    } label: {
                        HStack {
                            Text("Date")
                            Image(systemName: "calendar")
                            Spacer()
                            Text(date.formatted(date: .abbreviated, time: .omitted))
                        }
                    }
                    .popover(isPresented: $showCalendar) {
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .frame(width: 360, height: 360)
                            .presentationCompactAdaptation(.popover)
                    }
                    .onChange(of: date) { _, _ in
                        showCalendar = false
                    }

                }

                Section {
                    Button(recordToEdit == nil ? "Add Service" : "Save Changes") {
                        saveRecord()
                        dismiss()
                    }
                    .disabled(selectedVehicle == nil ||
                              selectedType == nil ||
                              selectedProvider == nil ||
                              Double(costText) == nil ||
                              Int(mileage) == nil)
                    
                    
                    if recordToEdit != nil {
                        Button("Delete Record", role: .destructive) {
                            showingDeleteAlert = true
                        }
                    }
                }
                
                Section {
                    Button("Add Service Type") {
                        showingTypeManager = true
                    }
                    .sheet(isPresented: $showingTypeManager) {
                        ServiceTypeListView()
                    }
                    Button("Add Service Provider") {
                        showingProviderManager = true
                    }
                    .sheet(isPresented: $showingProviderManager) {
                        AddProviderView()
                    }
                }
                
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing){
                    Button("Cancel"){
                        dismiss()
                    }
                }
                
                ToolbarItemGroup(placement: .keyboard){
                    Spacer()
                    Button("Done"){
                        focusedField = nil
                    }
                }
            }
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
            .navigationTitle(recordToEdit == nil ? "New Service" : "Edit Service")
        }
    }

    // MARK: - Helpers

    private func populateEditingFields() {
        
        guard let record = recordToEdit else { return }
        selectedVehicle = record.vehicle
        selectedProvider = record.provider
        selectedType = record.type
        cost = "\(record.cost)"
        costText = "\(record.cost)"
        date = record.date
        mileage = "\(record.mileage)"
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        costText = formatter.string(from: NSNumber(value: record.cost)) ?? ""

    }

    private func initializeDefaultsIfNeeded() {
        if recordToEdit == nil {
            selectedVehicle = vehicle ?? allVehicles.first
            selectedProvider = serviceProviders.first
            selectedType = serviceTypes.first
        }
    }

    private func saveRecord() {
        guard let vehicle = selectedVehicle,
              let provider = selectedProvider,
              let type = selectedType,
              let costValue = Double(costText),
              let mileageValue = Int(mileage) else { return }
        
        if let record = recordToEdit {
            record.vehicle = vehicle
            record.provider = provider
            record.type = type
            record.cost = costValue
            record.date = date
            record.mileage = mileageValue
        } else {
            let newRecord = ServiceRecord(
                vehicle: vehicle,
                type: type,
                cost: costValue,
                date: date,
                mileage: mileageValue,
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
     ServiceRecordFormView()
        .modelContainer(PreviewContainer.shared)
}
