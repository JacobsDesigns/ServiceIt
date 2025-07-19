//
//  CarView.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/13/25.
//

import SwiftUI

struct VehicleDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var vehicle: Vehicle // 👈 Bind to the vehicle model
    @FocusState private var isMileageFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Basic Info")) {
                    HStack {
                        TextField("Model Year", value: $vehicle.modelYear, format: .number.locale(Locale(identifier: "en_US_POSIX")))
                            .keyboardType(.numberPad)
                        TextField("Vehicle Name", text: $vehicle.name)
                    }
                }
                Section(header: Text("Current Mileage")) {
                    TextField("Mileage", value: $vehicle.currentMileage, format: .number.grouping(.automatic))
                        .keyboardType(.numberPad)
                        .focused($isMileageFocused)
                }
                Section(header: Text("License Plate")){
                    TextField("License Plate", text: $vehicle.license)
                }
                Section(header: Text("VIN")){
                    TextField("VIN", text: $vehicle.vin)
                }


                
            }
            .navigationTitle("Vehicle Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        isMileageFocused = false
                    }
                }
            }
        }
    }
}


#Preview {
    let testVehicle = Vehicle(
        name: "Test Car",
        modelYear: 2022,
        vin: "1HGBH41JXMN109186",
        currentMileage: 32500, 
        license: "123456789"
    )

    return VehicleDetailView(vehicle: testVehicle)
}

