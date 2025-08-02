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
    
    @FocusState private var isFocused: Field?
    
    enum Field {
        case first, second, third, year, mileage
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Vehicle Info")) {
                    
                    TextField("Name", text: $vehicle.name)
//                        .focused($isFocused, equals: .first)
//                        .background(DoneToolbar {
//                            isFocused = nil
//                        })
                    
                    TextField("VIN", text: $vehicle.vin)
//                        .focused($isFocused, equals: .second)
//                        .background(DoneToolbar {
//                            isFocused = nil
//                        })
                    
                    TextField("License Plate", text: $vehicle.license)
//                        .focused($isFocused, equals: .third)
//                        .background(DoneToolbar {
//                            isFocused = nil
//                        })
                    
                    TextField("Model Year", text: Binding(get: {String(vehicle.modelYear)},
                                                          set: {vehicle.modelYear = Int($0) ?? vehicle.modelYear}))
                    .keyboardType(.numberPad)
                    .focused($isFocused, equals: .year)
                    .background(DoneToolbar {
                        isFocused = nil
                    })
                    
                    TextField("Current Mileage", value: $vehicle.currentMileage, format: .number)
                        .keyboardType(.numberPad)
                        .focused($isFocused, equals: .mileage)
                        .background(DoneToolbar {
                            isFocused = nil
                        })
                        
                    
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
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Save") {
                    try? modelContext.save()
                        dismiss()
                    }
                }
//                ToolbarItemGroup(placement: .keyboard){
//                    Spacer()
//                    Button("Done"){
//                        //isFocused = nil
////                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1){
//                            isFocused = nil
//                        }
//                    }
//                }
            }
            
        }
    }
    
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

}

struct DoneToolbar: UIViewRepresentable {
    var onDone: () -> Void

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: context.coordinator, action: #selector(Coordinator.doneTapped))

        toolbar.items = [flexSpace, doneButton]
        textField.inputAccessoryView = toolbar
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onDone: onDone)
    }

    class Coordinator: NSObject {
        var onDone: () -> Void
        init(onDone: @escaping () -> Void) {
            self.onDone = onDone
        }

        @objc func doneTapped() {
            onDone()
        }
    }
}


#Preview{
    EditVehicleView(vehicle: MockData.allVehicles().first!)
        .modelContainer(PreviewContainer.shared)
    
}
