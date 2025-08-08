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
    @State private var addedCarWash: Bool = false
    @State private var carWashCost: Double = 0.0


    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Selected Vehicle: \(vehicle.name)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Picker("Station", selection: $selectedStation){
                        Text("Station").tag(nil as RefuelStation?)
                        ForEach(allStations) { station in
                            Text("\(station.name) • \(station.location)").tag(station)
                        }
                    }
                    
                    VStack (alignment: .leading) {
                        Text("Odometer: ")
                        HStack {
                            
                            TextField("", text: $mileage)
                                .keyboardType(.numberPad)
                            Button("Use Current"){
                                if let mileage = selectedVehicle?.currentMileage {
                                    self.mileage = formatMileage(mileage)
                                }
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
                        Text("Total: $\(String(format: "%.2f", computedTotal))")
                    }
                }
                
                Section {
                    Toggle("Added Car Wash", isOn: $addedCarWash)
                        //.toggleStyle(.checkbox)

                    if addedCarWash {
                        VStack {
                            TextField("Car Wash Cost", value: $carWashCost, format: .currency(code: "USD"))
                                .keyboardType(.decimalPad)
                                .padding(.bottom)

                            Text("Grand Total: $\(String(format: "%.2f", computedTotal + (carWashCost)))")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
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
        addedCarWash = visit.addedCarWash
        carWashCost = visit.carWashCost ?? 0
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
                //carWashCost: carWashCost
            )
            modelContext.insert(visit)
        }
        
        visit.odometer = mileageValue
        visit.date = date
        visit.gallons = Double(cleanedGallons) ?? 0.0
        visit.costPerGallon = Double(cleanedCostPerGallon) ?? 0.0
        visit.vehicle = vehicle
        visit.refuelStation = selectedStation
        visit.total = computedTotal
        visit.addedCarWash = addedCarWash
        visit.carWashCost = carWashCost
        
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
    
    func formatMileage(_ mileage: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: mileage)) ?? "\(mileage)"
    }
}

#Preview {
    let vehicle = MockData.allVehicles().first!
    
    RefuelVistFormView(vehicle: vehicle)
        .modelContainer(PreviewContainer.shared)
}
