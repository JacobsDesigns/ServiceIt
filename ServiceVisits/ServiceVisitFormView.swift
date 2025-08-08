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
    @State private var image: UIImage? = nil
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
    
    let buttonWidth: CGFloat = 180
    @State private var showFullScreenViewer = false

    var body: some View {
        NavigationStack {
            Form {
                // 🚗 Vehicle Picker
                //vehiclePickerSection
                
                Section() {
                    
                    Button //("Add Service Item")
                    {
                        isShowingSheet = true
                    } label: {
                        Label("Service Item", systemImage: "plus.app.fill")
                    }
                    //.buttonStyle(BorderedButtonStyle())
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
                        //costText = String(format: "%.2f", totalCosts)
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
                
                
                // 💵 Cost / Mileage / Date
                visitDetailsSection
                
                // 📝 Notes
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
                
                // 🚗 Vehicle Photo
                //vehiclePhotoSection
                
                // 📷 Image Picker
                Section {

                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 180)
                            .onTapGesture {
                                DispatchQueue.main.async {
                                    showFullScreenViewer = true
                                }
                            }
                    }
                    HStack {
                        Button("Attach Photo") {
                            showImagePicker = true
                        }
                        .buttonStyle(BorderedButtonStyle())
                        Spacer()
                        Button("Delete Photo") {
                                image = nil
                        }
                        .buttonStyle(BorderedButtonStyle())
                    }
                }
                .fullScreenCover(isPresented: $showFullScreenViewer) {
                    if let image {
                        ZoomableImageView(image: image) {
                            showFullScreenViewer = false
                        }
                    } else {
                        Text("No Image")
                    }
                }

                // Add Provider and Item
                Section {
                    HStack {
                        Button("Add Item"){
                            showAddItemSheet = true
                        }
                        .buttonStyle(BorderedButtonStyle())
//                        .frame (width: buttonWidth)
                        Spacer()
                        Button("Add Provider"){
                            showAddProviderSheet = true
                        }
                        .buttonStyle(BorderedButtonStyle())
//                        .frame (width: buttonWidth)
                    }
                }
                
                // ✅ Save / Delete
                Section {
                    
                    if visitToEdit != nil {
                        Button("Delete Visit", role: .destructive) {
                            showDeleteAlert = true
                        }
                        .buttonStyle(BorderedButtonStyle())
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
//            .sheet(isPresented: $showCamera) {
//                ImagePicker(selectedImage: $image, sourceType: .camera)
//            }
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
                    .buttonStyle(BorderedButtonStyle())
                Button("Cancel", role: .cancel) {}
                    .buttonStyle(BorderedButtonStyle())
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }
    
    var visitDetailsSection : some View {
        
        Section(header: Text("Visit Details")) {
            
            Picker("Provider", selection: $selectedProvider) {
                Text("Select Provider").tag(nil as ServiceProvider?)
                ForEach(serviceProviders) { provider in
                    Text(provider.name).tag(provider as ServiceProvider?)
                }
            }
            
            HStack {
                Text("Tax: ")
                    .font(.body)
                    .foregroundStyle(.secondary)
                Spacer()
                TextField("", text: $taxText)
                    .keyboardType(.decimalPad)
                    .frame(width: 85, alignment: .trailing)
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
                Text("\(totalText)")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            HStack {
                TextField("Mileage", text: $mileage)
                    .keyboardType(.numberPad)
                Button("Use Current"){
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
   
    
    // MARK: - Actions

    private func loadVisitIfEditing() {
        guard let visit = visitToEdit else {
            selectedVehicle = preselectedVehicle
            return
        }
        print("Section appeared with pendingItem: ", pendingItem?.name ?? "nil")
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        
        selectedVehicle = visit.vehicle
        selectedProvider = visit.provider
        selectedServiceItems = Set(visit.savedItems)
        addedItems = visit.savedItems.sorted { $0.name < $1.name }
        costText = formatter.string(from: NSNumber(value: visit.cost)) ?? ""
        taxText = formatter.string(from: NSNumber(value: visit.tax ?? 0.0)) ?? ""
        totalText = formatter.string(from: NSNumber(value: visit.total)) ?? ""
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

    extension NumberFormatter {
        static var currency: NumberFormatter {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.currencyCode = "USD"
            return formatter
        }
    }




struct ZoomableImageView: View {
    let image: UIImage
    let onDismiss: () -> Void

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()

            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .scaleEffect(scale)
                .offset(offset)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            scale = lastScale * value
                        }
                        .onEnded { _ in
                            lastScale = scale
                        }
                )
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            offset = CGSize(
                                width: lastOffset.width + value.translation.width,
                                height: lastOffset.height + value.translation.height
                            )
                        }
                        .onEnded { _ in
                            lastOffset = offset
                        }
                )

            Button {
                onDismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 34))
                    .foregroundColor(.white)
                    .padding()
            }
        }
    }
}


#Preview {
    let vehicle = MockData.allVehicles().first!
    return ServiceVisitFormView(preselectedVehicle: vehicle)
        .modelContainer(PreviewContainer.shared)
}

