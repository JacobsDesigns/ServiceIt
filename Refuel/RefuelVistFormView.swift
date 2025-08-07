//
//  RefuelVistFormView.swift
//  ServiceIt
//
//  Created by Jacob Filek on 8/5/25.
//
import SwiftUI
import SwiftData


struct RefuelVistFormView: View {

    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    
    @Bindable var vehicle: Vehicle
    
    var preselectedVehicle: Vehicle? = nil
    var refuelVisitToEdit: RefuelVisit? = nil
    
    @Query var allVehicles: [Vehicle]
    @Query var allStations: [RefuelStation]
    
    @State private var selectedVehicle: Vehicle?
    @State private var selectedStation: RefuelStation?
    @State private var showDeleteAlert = false
    @State private var mileage: String = ""
    @State private var date: Date = .now
    @State private var gallons: String = ""
    @State private var costPerGallon: String = ""
    @State private var costText: String = ""
    var computedTotal: Double {
        (Double(gallons) ?? 0.0) * (Double(costPerGallon) ?? 0.0)
    }
    
//    init(vehicle: Vehicle, preselectedVehicle: Vehicle? = nil, refuelVisittoEdit: RefuelVisit? = nil) {
//        self.vehicle = vehicle
//        self.preselectedVehicle = preselectedVehicle
//        self.refuelVisitToEdit = refuelVisittoEdit
//        _selectedVehicle = State(initialValue: vehicle)
//    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Selected Vehicle: \(vehicle.name)")
                         
                    Picker("Station", selection: $selectedStation){
                        Text("Station").tag(nil as RefuelStation?)
                        ForEach(allStations) { station in
                            Text("\(station.name) • \(station.location)").tag(station)
                        }
                    }
                    
                    HStack {
                        Text("Odometer: ")
                        TextField("", text: $mileage)
                            .keyboardType(.numberPad)
                        Button("Use Current"){
                            if let mileage = selectedVehicle?.currentMileage {
                                self.mileage = String(mileage)
                            }
                        }
                    }
                    HStack {
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                    }
                    HStack {
                        Text("Gallons: ")
                        TextField("", text: $gallons)
                            .keyboardType(.decimalPad)
                        }
                    HStack {
                        Text("Cost per Gallon: ")
                        TextField("", text: $costPerGallon)
                            .keyboardType(.decimalPad)
                        }
                    HStack {
                        Text("Total: \(String(format: "%.2f", computedTotal))")
                    }
                }
                Section {
                    
                    if refuelVisitToEdit != nil {
                        Button("Delete Visit", role: .destructive) {
                            showDeleteAlert = true
                        }
                        .buttonStyle(BorderedButtonStyle())
                    }
                }
            }
            .navigationTitle(refuelVisitToEdit == nil ? "New Refuel" : "Edit Refuel")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button(refuelVisitToEdit == nil ? "Add Visit" : "Save Changes") { saveVisit() }
                        .disabled(
                            selectedStation == nil || mileage.isEmpty || gallons.isEmpty || costPerGallon.isEmpty
                        )
                }
            }
            .onAppear(perform: loadIfEditing)
            .alert("Delete Visit?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) { deleteVisit(); dismiss() }
                    .buttonStyle(BorderedButtonStyle())
                Button("Cancel", role: .cancel) {}
                    .buttonStyle(BorderedButtonStyle())
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }
    
    private func loadIfEditing() {
        guard let visit = refuelVisitToEdit else {
            selectedVehicle = vehicle
            return
        }
        selectedVehicle = vehicle
        mileage = String(visit.odometer)
        date = visit.date
        gallons = String(visit.gallons)
        costPerGallon = String(visit.costPerGallon)
        selectedStation = visit.refuelStation
    }
    
    private func saveVisit() {
        
        let cleanedMileage = mileage
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: "")
        
       let cleanedGallons = gallons
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: "")
        
        let cleanedCostPerGallon = costPerGallon
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: "")
        
        
        guard
                let vehicle = selectedVehicle,
                let mileageValue = Int(cleanedMileage)
                
        else {
            print("Save Failed")
            return
        }
        
        let visit: RefuelVisit
        
        if let existingVisit = refuelVisitToEdit {
            visit = existingVisit
        } else {
            visit = RefuelVisit(
                odometer: mileageValue,
                date: date,
                gallons: Double(cleanedGallons) ?? 0.0,
                costPerGallon: Double(cleanedCostPerGallon) ?? 0.0,
                total: computedTotal,
                vehicle: vehicle,
                refuelStation: selectedStation
            )
            modelContext.insert(visit)
        }
        
        visit.odometer = mileageValue
        visit.date = date
        visit.gallons = Double(cleanedGallons) ?? 0.0
        visit.costPerGallon = Double(cleanedCostPerGallon) ?? 0.0
        visit.vehicle = vehicle
        visit.refuelStation = selectedStation
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Something went wrong saving the visit: \(error)")
        }
        
    }
    
    private func deleteVisit() {
        guard let visit = refuelVisitToEdit else { return }
        modelContext.delete(visit)
        try? modelContext.save()
    }
}

#Preview {
    let vehicle = MockData.allVehicles().first!
    
    RefuelVistFormView(vehicle: vehicle)
        .modelContainer(PreviewContainer.shared)
}
