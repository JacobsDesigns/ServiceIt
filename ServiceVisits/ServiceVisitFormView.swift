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
    @State private var taxText: String = ""
    @State private var totalText: String = ""
    @State private var date: Date = .now
    @State private var mileage: String = ""
    @State private var notes: String = ""
    @State private var image: UIImage?
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var showDeleteAlert = false
    @State private var newServiceName: String = ""
    @State private var newItemCost: String = ""
    @State private var showAddItemSheet = false
    @State private var showAddProviderSheet = false

    @State private var selectedItemToAdd: ServiceItem? = nil
    @State private var costInput: String = ""
    @State private var addedItems: [SavedServiceItem] = []
    @State private var settingItem = false
    @State private var pendingItem: ServiceItem? = nil
    @State private var isShowingSheet = false
    @State private var isShowingEditSheet = false
    @State private var itemToEdit: SavedServiceItem? = nil
    
    //@State private var stagedItem: SavedServiceItem? = nil

    var body: some View {
        NavigationStack {
            Form {
                // 🚗 Vehicle Picker
                vehiclePickerSection
                
                // 🛠 Service Provider
                providerPickerSection
                
                // 🔧 Multi-Select Service Types
                //serviceItemSection
                //begin
                Section() {
                    
                    Button("Add Service Item") {
                        isShowingSheet = true
                    }
                    .buttonStyle(.borderedProminent)
                    .sheet(isPresented: $isShowingSheet) {
                        ItemPickerSheet(
                            serviceItems: serviceItems,
                            selectedItem: $selectedItemToAdd,
                            costInput: $costInput,
                            addedItems: $addedItems,
                            visitToEdit: visitToEdit,
                            isPresented: $isShowingSheet
                        )
                    }
                    
                    
                    
                    //                    Picker("", selection: $selectedItemToAdd){
                    //                        Text("Service Items").tag(nil as ServiceItem?)
                    //                        ForEach(serviceItems){ item in
                    //                            Text("\(item.name) • \(item.cost, format: .currency(code: "USD"))").tag(Optional(item))
                    //                        }
                    //                    }
                    //                    .pickerStyle(.menu)
                    //                    .onChange(of: selectedItemToAdd) { _, newValue in
                    //                    guard let item = newValue else { return }
                    //                    let alreadyAdded = addedItems.contains { $0.name == item.name }
                    //                    guard !alreadyAdded else { return }
                    //
                    //                    pendingItem = item
                    //                    costInput = String(format: "%.2f", item.cost)
                    //                    settingItem = true
                    //                }
                    
                    // Inline cost entry if a pending item is selected
                    //                    if let item = pendingItem {
                    //
                    //                        VStack(alignment: .leading, spacing: 10) {
                    //                            Text("Enter cost for \(item.name):")
                    //
                    //                            TextField("Cost", text: $costInput)
                    //                                .keyboardType(.decimalPad)
                    //                                .textFieldStyle(.roundedBorder)
                    //                                .onChange(of: costInput) { _, newValue in
                    //                                    if let newCost = Double(newValue), newCost >= 0 {
                    //                                        print("Valid cost Input: \(newCost)")
                    //                                        pendingItem!.cost = newCost
                    //                                    }
                    //                                }
                    //
                    //                            HStack {
                    //                                Button("Cancel") {
                    //                                    pendingItem = nil
                    //                                    selectedItemToAdd = nil
                    //                                    costInput = ""
                    //                                }
                    //
                    //                                Spacer()
                    //
                    //                                Button()
                    //                                {
                    //                                    let cost = Double(costInput) ?? item.cost
                    //                                    if let visit = visitToEdit {
                    //                                        let newItem = SavedServiceItem(name: item.name, cost: cost)
                    //                                        newItem.visit = visit
                    //                                        addedItems.append(newItem)
                    //
                    //                                    } else {
                    //                                        let stagedItem = SavedServiceItem(name: item.name, cost: cost)
                    //                                        addedItems.append(stagedItem)
                    //                                    }
                    //
                    //                                    pendingItem = nil
                    //                                    selectedItemToAdd = nil
                    //                                    costInput = ""
                    //                                } label: {
                    //                                    Label("Add Item", systemImage: "plus")
                    //                                }
                    //                            }
                    //                        }
                    //                        .padding(.vertical, 8)
                    //                    }
                    
                    
                    // List of added items
                    //                    ForEach(addedItems) { item in
                    //                        HStack {
                    //                            Text(item.name)
                    //                            Spacer()
                    //                            Text(item.cost, format: .currency(code: "USD"))
                    //                                .foregroundStyle(.secondary)
                    //                        }
                    //                    }
                    ForEach(addedItems.indices, id: \.self) { index in
                        let item = addedItems[index]
                        Button {
                            itemToEdit = item
                            isShowingEditSheet = true
                        } label: {
                            HStack {
                                Text("\(item.name)")
                                Spacer()
                                Text("$\(item.cost, specifier: "%.2f")")
                            }
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
                
                //ending
                
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
                    HStack {
                        Button("Attach Photo") {
                            showImagePicker = true
                        }
                        .buttonStyle(.borderedProminent)
                        Spacer()
                        Button("Delete Photo") {
                            //if let image {
                                image = nil
                            //}
                        }
                        .buttonStyle(.borderedProminent)
                    }
//                    Button("Camera"){
//                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
//                            //imagePicker.sourceType = .camera
//                            showCamera = true
//                        } else {
//                            //imagePicker.sourceType = .photoLibrary
//                            showImagePicker = true
//                        }
//                    }
                    
                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 180)
                    }
                }
                
                // ✅ Save / Delete
                Section {
                    //                    Button(visitToEdit == nil ? "Add Visit" : "Save Changes") {
                    //                        saveVisit()
                    //                        dismiss()
                    //                    }
                    //                    .disabled(
                    //                        selectedVehicle == nil ||
                    //                        selectedProvider == nil //||
                    //                        //selectedServiceItems.isEmpty //||
                    //                        //Double(costText) == nil ||
                    //                        //Int(mileage) == nil
                    //                    )
                    
                    if visitToEdit != nil {
                        Button("Delete Visit", role: .destructive) {
                            showDeleteAlert = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                
                Section {
                    HStack {
                        Button("Add Item"){
                            showAddItemSheet = true
                        }
                        .buttonStyle(.borderedProminent)
                        Spacer()
                        Button("Add Provider"){
                            showAddProviderSheet = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
            .navigationTitle(visitToEdit == nil ? "New Visit" : "Edit Visit")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button(visitToEdit == nil ? "Add Visit" : "Save Changes") { saveVisit() }
                        .disabled(
                            selectedVehicle == nil ||
                            selectedProvider == nil ||
                            cleanedMileageText(mileage) == nil)
                }
            }
            .onAppear(perform: loadVisitIfEditing)
            
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $image)
            }
            .sheet(isPresented: $showCamera) {
                ImagePicker(selectedImage: $image, sourceType: .camera)
            }
            
            // 🧩 Sheet for adding service items — placed here to avoid nesting issues
            .sheet(isPresented: $showAddItemSheet) {
                AddServiceItemView()
            }
            .sheet(isPresented: $showAddProviderSheet){
                AddProviderView()
            }
            .sheet(item: $itemToEdit) { item in
                EditItemSheet(
                    item: item,
                    onSave: { updatedItem in
                        if let index = addedItems.firstIndex(where: { $0.id == updatedItem.id }) {
                            addedItems[index] = updatedItem
                        }
                        itemToEdit = nil
                    },
                    onCancel: {
                        itemToEdit = nil
                    }
                )
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
            
            HStack {
                Text("Tax: ")
                    .font(.body)
                    .foregroundStyle(.secondary)
                Spacer()
                TextField("Tax", text: $taxText)
                    .keyboardType(.decimalPad)
                    .frame(width: 100, alignment: .trailing)
                    .onChange (of: taxText) {
                        updateTaxIfNeeded()
                    }
            }
            
            HStack {
               
                Text("Cost for all Items:")
                    .font(.body)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(costText)")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            HStack {
                Text("Grand Total")
                    .font(.body)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("$\(totalText)")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            HStack {
                TextField("Mileage", text: $mileage)
                    .keyboardType(.numberPad)
                Button("Use Current Mileage"){
                    if let mileage = selectedVehicle?.currentMileage {
                        self.mileage = formatMileage(mileage)
                    }
                }
            }
            
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
        Section() {
            Picker("Vehicle", selection: $selectedVehicle) {
                ForEach(allVehicles, id: \.self) { vehicle in
                    Text(vehicle.modelYear.description + " " + vehicle.name).tag(vehicle as Vehicle)
                }
            }
        }
    }
    
    var providerPickerSection: some View {
        Section() {
            Picker("Provider", selection: $selectedProvider) {
                Text("Select Provider").tag(nil as ServiceProvider?)
                ForEach(serviceProviders) { provider in
                    Text(provider.name).tag(provider as ServiceProvider?)
                }
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
        //taxText = "\(visit.tax ?? 0.0)"
        taxText = visit.tax?.formatted(.currency(code: "USD")) ?? ""
        totalText = "\(visit.total)"
        mileage = formatMileage(visit.mileage)//"\(visit.mileage)"
        notes = visit.notes ?? ""
        image = visit.photoData.flatMap(UIImage.init(data:))
        date = visit.date
    }

    func cleanedMileageText(_ cost: String) -> Int? {
        let output = cost
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .replacingOccurrences(of: "$", with: "")
        .replacingOccurrences(of: ",", with: "")
        return Int(output)
    }
    
    func updateTaxIfNeeded () {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        let cleanedCost = costText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: ",", with: "")
        
        let cleanedTax = taxText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: ",", with: "")
        
        if let cleanedCost = Double(cleanedCost) {
            let cleanedTax = Double(cleanedTax) ?? 0.0
            let totalTemp = cleanedCost + cleanedTax
            totalText = numberFormatter.string(from: NSNumber(value: totalTemp)) ?? "\(totalTemp)"
        }
        
        
     
    }
    
    
    
    private func saveVisit() {
        
        let cleanedCostText = costText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: ",", with: "")
        
        let cleanedTax = taxText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: ",", with: "")
        
        let cleanedMileage = mileage
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: ".", with: "")
        
        guard
            
            let vehicle = selectedVehicle,
            let provider = selectedProvider,
            let cost = Double(cleanedCostText),
            let mileageValue = Int(cleanedMileage)
                
        else {
            print("❌ Visit save failed: missing required fields")
            return
        }

        let visit: ServiceVisit
        let tax = Double(cleanedTax)
        let totalCostWithTax = cost + (tax ?? 0.0)
        
        if let existingVisit = visitToEdit {
            visit = existingVisit
        } else {
            visit = ServiceVisit(date: date,
                                 mileage: mileageValue,
                                 cost: cost,
                                 tax : tax,
                                 total: totalCostWithTax,
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
        visit.tax = tax
        visit.total = totalCostWithTax
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
    
    func formatMileage(_ mileage: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: mileage)) ?? "\(mileage)"
    }
    
}

#Preview {
    let vehicle = MockData.allVehicles().first!
    return ServiceVisitFormView(preselectedVehicle: vehicle)
        .modelContainer(PreviewContainer.shared)
}

