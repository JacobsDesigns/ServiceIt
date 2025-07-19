//
//  AddVehicleView.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/13/25.
//
import SwiftUI
import SwiftData
import PhotosUI


struct AddVehicleView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var name: String = ""
    @State private var modelYearString: String = ""
    @State private var vin: String = ""
    @State private var license: String = ""
    @State private var mileage: Int?

    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImageData: Data?

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Vehicle Info")) {
                    TextField("Name", text: $name)
                    TextField("VIN", text: $vin)
                    TextField("License Plate", text: $license)
                    
                    TextField("Model Year", text: $modelYearString)
                        .keyboardType(.numberPad)

                    TextField("Current Mileage", value: $mileage, format: .number)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Photo")) {
                    PhotosPicker(selection: $selectedPhoto, matching: .images, photoLibrary: .shared()) {
                        Label("Select Vehicle Photo", systemImage: "photo.on.rectangle")
                    }
                    .onChange(of: selectedPhoto) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                selectedImageData = data
                                // Optionally store it or preview it
                            }
                        }
                    }

                    if let data = selectedImageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 180)
                            .cornerRadius(12)
                    }
                }


                Section {
                    Button("Save Vehicle") {
                        saveVehicle()
                        dismiss()
                    }
                    .disabled(!isValid)
                }
            }
            .navigationTitle("Add Vehicle")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    // MARK: - Validation
    private var isValid: Bool {
        !name.isEmpty &&
        !vin.isEmpty &&
        !license.isEmpty &&
        !modelYearString.isEmpty &&
        mileage != nil
    }

    // MARK: - Save Logic
    private func saveVehicle() {
        guard let year = Int(modelYearString),
              let mileageValue = mileage else { return }

        let newVehicle = Vehicle(
            name: name,
            modelYear: year,
            vin: vin,
            currentMileage: mileageValue,
            license: license
        )

        modelContext.insert(newVehicle)
        try? modelContext.save()
    }
}

#Preview {
    AddVehicleView().modelContainer(PreviewContainer.shared)
}
