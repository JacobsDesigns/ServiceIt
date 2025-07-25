//
//  EditVehicleView.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/18/25.
//


import SwiftUI
import SwiftData
import PhotosUI

struct EditVehicleView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Bindable var vehicle: Vehicle

    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImageData: Data?
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Vehicle Info")) {
                    TextField("Name", text: $vehicle.name)
                    TextField("VIN", text: $vehicle.vin)
                    TextField("License Plate", text: $vehicle.license)
                    TextField("Model Year", text: Binding(get: {String(vehicle.modelYear)},
                                                          set: {vehicle.modelYear = Int($0) ?? vehicle.modelYear}))

                    TextField("Current Mileage", value: $vehicle.currentMileage, format: .number)
                        .keyboardType(.numberPad)
                }

                Section(header: Text("Photo")) {
                                    PhotosPicker(selection: $selectedPhoto, matching: .images, photoLibrary: .shared()) {
                                        Label("Update Photo", systemImage: "photo")
                                    }
                                    .onChange(of: selectedPhoto) {
                                        Task {
                                            if let data = try? await selectedPhoto?.loadTransferable(type: Data.self) {
                                                selectedImageData = data
                                                vehicle.photoData = data
                                            }
                                        }
                                    }

                                    if let data = selectedImageData ?? vehicle.photoData,
                                       let image = UIImage(data: data) {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 180)
                                            .cornerRadius(12)
                                    }
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
    EditVehicleView(vehicle: MockData.allVehicles().first!)
        .modelContainer(PreviewContainer.shared)
    
}
