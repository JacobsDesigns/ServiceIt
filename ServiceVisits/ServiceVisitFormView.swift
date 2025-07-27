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
    @State private var selectedServiceItems: Set<SavedServiceItem> = []
    @State private var costText: String = ""
    @State private var date: Date = .now
    @State private var mileage: String = ""
    @State private var notes: String = ""
    @State private var image: UIImage?
    @State private var showImagePicker = false
    @State private var showDeleteAlert = false
    @State private var newServiceName: String = ""
    @State private var newItemCost: String = ""
    @State private var showAddItemSheet = false

    @State private var selectedItemToAdd: ServiceItem? = nil
    @State private var costInput: String = ""
    @State private var addedItems: [SavedServiceItem] = []
    @State private var settingItem = false
    @State private var pendingItem: ServiceItem?


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
                        selectedProvider == nil //||
                        //selectedServiceItems.isEmpty //||
                        //Double(costText) == nil ||
                        //Int(mileage) == nil
                    )

                    if visitToEdit != nil {
                        Button("Delete Visit", role: .destructive) {
                            showDeleteAlert = true
                        }
                    }
                }
                Section {
                    Button("Add Item"){
                        showAddItemSheet = true
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
                AddServiceItemView()
            }
            .alert("Delete Visit?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) { deleteVisit(); dismiss() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }


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

            Picker("Select an Item", selection: $selectedItemToAdd){
                Text("Select an Item").tag(nil as ServiceItem?)
                ForEach(serviceItems){ item in
                    Text("\(item.name) • \(item.cost, format: .currency(code: "USD"))").tag(Optional(item))
                }
            }
            .pickerStyle(.menu)
            .onChange(of: selectedItemToAdd) { _, newValue in
                print("Picker changed to: ", newValue?.name ?? "nil")
            guard let item = newValue else { return }
            let alreadyAdded = addedItems.contains { $0.name == item.name }
            guard !alreadyAdded else { return }

            pendingItem = item
            costInput = String(format: "%.2f", item.cost)
            settingItem = true
            print(item.name)
            print(item.cost)
        }

            // Inline cost entry if a pending item is selected
            if let item = pendingItem {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Enter cost for \(item.name):")

                    TextField("Cost", text: $costInput)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: costInput) { _, newValue in
                            if let newCost = Double(newValue), newCost >= 0 {
                                print("Valid cost Input: \(newCost)")
                                
                            }
//                            let p_item = pendingItem {
//                                p_item.cost = newCost
//                            }
                        }

                    HStack {
                        Button("Cancel") {
                            pendingItem = nil
                            selectedItemToAdd = nil
                            costInput = ""
                        }

                        Spacer()

                        Button("Add Item") {
                            
//                            guard let item = pendingItem else { return }
//                            guard let cost = Double(costInput) else { return }
                            
                            let cost = Double(costInput) ?? item.cost

                            if let visit = visitToEdit {
                                print("visitToEdit is set: \(visit.date)")
                                
                                let newItem = SavedServiceItem(name: item.name, cost: cost)
                                newItem.visit = visit
                                modelContext.insert(newItem)

                                do {
                                    try modelContext.save()
                                    print("✅ Save succeeded")
                                } catch {
                                    print("🛑 Save failed: \(error)")
                                }

                                addedItems.append(newItem)
                                
                            } else {
                                print("visitToEdit is nil — staging item")
                                let stagedItem = SavedServiceItem(name: item.name, cost: cost)
                                addedItems.append(stagedItem)
                            }

                            pendingItem = nil
                            selectedItemToAdd = nil
                            costInput = ""
                        }
                    }
                }
                .padding(.vertical, 8)
            }


            // List of added items
            ForEach(addedItems) { item in
                HStack {
                    Text(item.name)
                    Spacer()
                    Text(item.cost, format: .currency(code: "USD"))
                        .foregroundStyle(.secondary)
                }
            }
            .onDelete { indexSet in
                addedItems.remove(atOffsets: indexSet)
            }
            .onChange (of: addedItems) { _, newValue in
                let totalCosts = newValue.reduce(0.0) { $0 + $1.cost}
                    costText = totalCosts.formatted(.currency(code: "USD"))
            }

            // Subtotal
            HStack {
                Text("Subtotal")
                    .bold()
                Spacer()
                Text(addedItems.reduce(0.0) { $0 + $1.cost }, format: .currency(code: "USD"))
                    .bold()
                    .foregroundStyle(.primary)
            }
        }
    }
    
    // MARK: - Actions

    private func loadVisitIfEditing() {
        guard let visit = visitToEdit else {
            selectedVehicle = preselectedVehicle
            return
        }
        print("Section appeared with pendingItem: ", pendingItem?.name ?? "nil")
        selectedVehicle = visit.vehicle
        selectedProvider = visit.provider
        selectedServiceItems = Set(visit.savedItems)
        addedItems = visit.savedItems.sorted { $0.name < $1.name }
        costText = "\(visit.cost)"
        mileage = "\(visit.mileage)"
        notes = visit.notes ?? ""
        image = visit.photoData.flatMap(UIImage.init(data:))
        date = visit.date
    }

    private func saveVisit() {
        guard
            let vehicle = selectedVehicle,
            let provider = selectedProvider,
            let cost = Double(costText),
            let mileageValue = Int(mileage)
        else {
            print("❌ Visit save failed: missing required fields")
            return
        }

        let visit: ServiceVisit

        if let existingVisit = visitToEdit {
            visit = existingVisit
        } else {
            visit = ServiceVisit(date: date,
                                 mileage: mileageValue,
                                 cost: cost,
                                 notes: notes,
                                 photoData: image?.jpegData(compressionQuality: 0.8),
                                 vehicle: vehicle,
                                 provider: provider,
                                 savedItems: [])
            modelContext.insert(visit)
        }

        // Update visit attributes
        visit.date = date
        visit.mileage = mileageValue
        visit.cost = cost
        visit.notes = notes
        visit.photoData = image?.jpegData(compressionQuality: 0.8)
        visit.vehicle = vehicle
        visit.provider = provider

        // Link staged SavedServiceItems
        for item in addedItems {
            item.visit = visit
            modelContext.insert(item)
        }

        visit.savedItems = addedItems

        do {
            try modelContext.save()
            print("✅ Saved visit for \(vehicle.name) \(vehicle.modelYear)")
            dismiss()
        } catch {
            print("❌ Failed to save visit: \(error.localizedDescription)")
        }
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

