//
//  ServiceVisitFormView.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/24/25.
//
import SwiftUI
import SwiftData


struct ServiceVisitFormView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext

    var visitToEdit: ServiceVisit? = nil
    var preselectedVehicle: Vehicle? = nil

    @Query var serviceItems: [ServiceItem]
    @Query var serviceProviders: [ServiceProvider]
    @Query var allVehicles: [Vehicle]

    @State private var selectedVehicle: Vehicle?
    @State private var selectedProvider: ServiceProvider?
    @State private var selectedServiceTypes: Set<ServiceItem> = []
    @State private var costText: String = ""
    @State private var date: Date = .now
    @State private var mileage: String = ""
    @State private var notes: String = ""
    @State private var image: UIImage?
    @State private var showImagePicker = false
    @State private var showDeleteAlert = false
    @State private var newServiceName: String = ""
    @State private var newItemCost: String = ""
    @State private var selectedItemToAdd: ServiceItem?
    @State private var addedItems: [ServiceItem] = []
    @State private var showAddItemSheet = false
    
    
    var body: some View {
        NavigationStack {
            Form {
                // 🚗 Vehicle Picker
                vehiclePickerSection

                // 🛠 Service Provider
                providerPickerSection

                // 🔧 Multi-Select Service Types
                serviceItemSection

                // 💵 Cost / Mileage / Date
                visitDetailsSection

                // 📝 Notes
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }

                // 🚗 Vehicle Photo
                vehiclePhotoSection

                // 📷 Image Picker
                Section {
                    Button("Attach Photo") {
                        showImagePicker = true
                    }
                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 180)
                    }
                }

                // ✅ Save / Delete
                Section {
                    Button(visitToEdit == nil ? "Add Visit" : "Save Changes") {
                        saveVisit()
                        dismiss()
                    }
                    .disabled(
                        selectedVehicle == nil ||
                        selectedProvider == nil ||
                        selectedServiceTypes.isEmpty ||
                        Double(costText) == nil ||
                        Int(mileage) == nil
                    )

                    if visitToEdit != nil {
                        Button("Delete Visit", role: .destructive) {
                            showDeleteAlert = true
                        }
                    }
                }
            }
            .navigationTitle(visitToEdit == nil ? "New Visit" : "Edit Visit")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear(perform: loadVisitIfEditing)
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $image)
            }
            // 🧩 Sheet for adding service items — placed here to avoid nesting issues
            .sheet(isPresented: $showAddItemSheet) {
                //AddServiceItemView(addedItems: $addedItems)
            }
            .alert("Delete Visit?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) { deleteVisit(); dismiss() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }

//    var body: some View {
//        NavigationStack {
//            Form {
//                // 🚗 Vehicle Picker
//                vehiclePickerSection
//
//                // 🛠 Service Provider
//                providerPickerSection
//
//                // 🔧 Multi-Select Service Types
//                serviceItemSection
//
//                // 💵 Cost / Mileage / Date
//               visitDetailsSection
//
//                // 📝 Notes
//                Section(header: Text("Notes")) {
//                    TextEditor(text: $notes)
//                        .frame(minHeight: 100)
//                }
//                
//                // 🚗 Vehicle Photo
//               vehiclePhotoSection
//                
//                // 📷 Image Picker
//                Section {
//                    Button("Attach Photo") {
//                        showImagePicker = true
//                    }
//                    if let image {
//                        Image(uiImage: image)
//                            .resizable()
//                            .scaledToFit()
//                            .frame(height: 180)
//                    }
//                }
//
//                // ✅ Save / Delete
//                Section {
//                    Button(visitToEdit == nil ? "Add Visit" : "Save Changes") {
//                        saveVisit()
//                        dismiss()
//                    }
//                    .disabled(selectedVehicle == nil || selectedProvider == nil || selectedServiceTypes.isEmpty || Double(costText) == nil || Int(mileage) == nil)
//
//                    if visitToEdit != nil {
//                        Button("Delete Visit", role: .destructive) {
//                            showDeleteAlert = true
//                        }
//                    }
//                }
//            }
//            .navigationTitle(visitToEdit == nil ? "New Visit" : "Edit Visit")
//            .toolbar {
//                ToolbarItem(placement: .topBarTrailing) {
//                    Button("Cancel") { dismiss() }
//                }
//            }
//            .onAppear(perform: loadVisitIfEditing)
//            .sheet(isPresented: $showImagePicker) {
//                ImagePicker(selectedImage: $image)
//            }
//            .sheet(isPresented: $showAddItemSheet) {
//                AddServiceItemView(addedItems: $addedItems)
//            }
//            .alert("Delete Visit?", isPresented: $showDeleteAlert) {
//                Button("Delete", role: .destructive) { deleteVisit(); dismiss() }
//                Button("Cancel", role: .cancel) {}
//            } message: {
//                Text("This action cannot be undone.")
//            }
//        }
//    }

    var visitDetailsSection : some View {
        Section(header: Text("Visit Details")) {
            TextField("Cost", text: $costText)
                .keyboardType(.decimalPad)
            TextField("Mileage", text: $mileage)
                .keyboardType(.numberPad)
            DatePicker("Date", selection: $date, displayedComponents: .date)
        }
    }
    
    var vehiclePhotoSection: some View {
        Section(header: Text("Photo")) {
            Button(action: {
                showImagePicker = true
            }) {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                }
            }
        }
    }
    
    var vehiclePickerSection: some View {
        Section(header: Text("Vehicle")) {
            Picker("Vehicle", selection: $selectedVehicle) {
                ForEach(allVehicles, id: \.self) { vehicle in
                    Text(vehicle.modelYear.description + " " + vehicle.name).tag(vehicle as Vehicle)
                }
            }
        }
    }
    
    var providerPickerSection: some View {
        Section(header: Text("Provider")) {
            Picker("Provider", selection: $selectedProvider) {
                Text("Select Provider").tag(nil as ServiceProvider?)
                ForEach(serviceProviders) { provider in
                    Text(provider.name).tag(provider as ServiceProvider?)
                }
            }
        }
    }
    
    

    var serviceItemSection: some View {
        
        Section(header: Text("Service Items")) {
            // Picker to add existing items
            Picker("Add Existing Item", selection: $selectedItemToAdd) {
                Text("Select Service").tag(nil as ServiceItem?)
                ForEach(serviceItems) { item in
                    Text("\(item.name) • \(item.cost, format: .currency(code: "USD"))")
                        .tag(item as ServiceItem?)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: selectedItemToAdd) {
                if let item = selectedItemToAdd, !addedItems.contains(item) {
                    addedItems.append(item)
                }
                selectedItemToAdd = nil
            }

            // List of added items
            ForEach(addedItems) { item in
                HStack {
                    Text(item.name)
                    Spacer()
                    Text(item.cost, format: .currency(code: "USD"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .onDelete { indexSet in
                addedItems.remove(atOffsets: indexSet)
            }

            // Subtotal
            HStack {
                Text("Subtotal")
                    .bold()
                Spacer()
                Text(addedItems.reduce(0.0) { total, item in
                    total + item.cost }, format: .currency(code: "USD"))
                    .bold()
                    .foregroundStyle(.primary)
            }

            // Input row to add a brand-new item
//            Button {
//                showAddItemSheet = true
//            } label: {
//                Label("Add New Service Item", systemImage: "plus.circle.fill")
//                    .foregroundStyle(.blue)
//            }
//            .sheet(isPresented: $showAddItemSheet) {
//                AddServiceItemView()//(addedItems: $addedItems)
//            }
//            .padding(.top)

        }

    }

    
    
    
    // MARK: - Actions

    private func loadVisitIfEditing() {
        guard let visit = visitToEdit else {
            selectedVehicle = preselectedVehicle
            return
        }

        selectedVehicle = visit.vehicle
        selectedProvider = visit.provider
        selectedServiceTypes = Set(visit.items)
        costText = String(visit.cost)
        mileage = String(visit.mileage)
        notes = visit.notes ?? ""
        if let data = visit.photoData {
            image = UIImage(data: data)
        }
        date = visit.date
    }

    private func saveVisit() {
        guard let vehicle = selectedVehicle,
              let provider = selectedProvider,
              let cost = Double(costText),
              let mileageValue = Int(mileage) else { return }

        if let visit = visitToEdit {
            visit.vehicle = vehicle
            visit.provider = provider
            visit.items = Array(selectedServiceTypes)
            visit.cost = cost
            visit.date = date
            visit.mileage = mileageValue
            visit.notes = notes
            visit.photoData = image?.jpegData(compressionQuality: 0.8)
        } else {
            let visit = ServiceVisit(
                date: date,
                mileage: mileageValue,
                cost: cost,
                notes: notes,
                photoData: image?.jpegData(compressionQuality: 0.8),
                vehicle: vehicle,
                provider: provider,
                items: Array(selectedServiceTypes)
            )
            modelContext.insert(visit)
        }

        try? modelContext.save()
    }

    private func deleteVisit() {
        guard let visit = visitToEdit else { return }
        modelContext.delete(visit)
        try? modelContext.save()
    }
}

#Preview {
    let vehicle = MockData.allVehicles().first!
    return ServiceVisitFormView(preselectedVehicle: vehicle)
        .modelContainer(PreviewContainer.shared)
}

