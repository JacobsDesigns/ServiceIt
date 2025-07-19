//
//  EditVehicleView.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/18/25.
//


import SwiftUI
import SwiftData

struct EditVehicleView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Bindable var vehicle: Vehicle

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Vehicle Info")) {
                    TextField("Name", text: $vehicle.name)
                    TextField("VIN", text: $vehicle.vin)
                    TextField("License Plate", text: $vehicle.license)

//                    TextField("Model Year", value: $vehicle.modelYear, format: .number)
//                        .keyboardType(.numberPad)
                    TextField("Model Year", text: Binding(get: {String(vehicle.modelYear)},
                                                          set: {vehicle.modelYear = Int($0) ?? vehicle.modelYear}))

                    TextField("Current Mileage", value: $vehicle.currentMileage, format: .number)
                        .keyboardType(.numberPad)
                }

                Section {
                    Button("Save Changes") {
                        try? modelContext.save()
                        dismiss()
                    }
                }
            }
            .navigationTitle("Edit Vehicle")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

#Preview{
    EditVehicleView(vehicle: MockData.vehicle1)
        .modelContainer(PreviewContainer.shared)
    
}
