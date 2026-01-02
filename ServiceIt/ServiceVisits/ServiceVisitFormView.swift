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
    
    @FocusState private var focusedField: Field?

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
    @State private var discountText: String = ""
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
    @State private var itemToEdit: SavedServiceItem? = nil
    
    let buttonWidth: CGFloat = 180
    @State private var showFullScreenViewer = false

    enum Field {
        case tax
        case discount
        case mileage
    }
    
    
    var body: some View {
        NavigationStack {
            Form {
                
                Section() {
                    
                    Button //("Add Service Item")
                    {
                        isShowingSheet = true
                    } label: {
                        Label("Add Service Item", systemImage: "plus.app.fill")
                    }
                    .buttonStyle(BorderedButtonStyle())
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
                
                // 💵 Cost / Mileage / Date
                visitDetailsSection
                
                // 📝 Notes
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
                
                
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
                        .buttonStyle(.bordered)
                        Spacer()
                        Button("Delete Photo") {
                                image = nil
                        }
                        .buttonStyle(.bordered)
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
                        Button("Add New Item"){
                            showAddItemSheet = true
                        }
                        .buttonStyle(.bordered)
                        Spacer()
                        Button("Add New Provider"){
                            showAddProviderSheet = true
                        }
                        .buttonStyle(.bordered)
                    }
                }
                
                // ✅ Save / Delete
                Section {
                    
                    if visitToEdit != nil {
                        Button("Delete Visit", role: .destructive) {
                            showDeleteAlert = true
                        }
                        .buttonStyle(.bordered)
                    }
                }
                
                
            }
            .navigationTitle(visitToEdit == nil ? "New Service Visit" : "Edit Visit")
            .toolbar {
                ToolbarItemGroup(placement: .keyboard){
                    Spacer()
                    Button("Done") {
                        
                        if focusedField == .mileage {
                            let raw = mileage
                                .trimmingCharacters(in: .whitespacesAndNewlines)
                                .replacingOccurrences(of: ",", with: "")
                            if let value = Int(raw) {
                                mileage = formatMileage(value)
                            }
                            
                        } else if focusedField == .tax {
                            let raw = taxText
                                .trimmingCharacters(in: .whitespacesAndNewlines)
                                .replacingOccurrences(of: ",", with: "")
                            if let value = Double(raw) {
                                taxText = formatDollars(value)
                            }
                            
                        } else if focusedField == .discount {
                            let raw = discountText
                                .trimmingCharacters(in: .whitespacesAndNewlines)
                                .replacingOccurrences(of: ",", with: "")
                            if let value = Double(raw) {
                                discountText = formatDollars(value)
                            }
                            
                        }
                        focusedField = nil
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: saveVisit){
                        HStack{
                            Image(systemName: visitToEdit == nil ? "plus" : "internaldrive.fill")
                            Text(visitToEdit == nil ? "Add Service Visit" : "Save Changes")
                        }
                    }
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
            .sheet(isPresented: $showAddItemSheet) {
                AddServiceItemView()
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.automatic)
            }
            .sheet(isPresented: $showAddProviderSheet){
                AddProviderView()
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.automatic)
            }
            .sheet(item: $itemToEdit) { item in
                EditItemSheet(
                    item: item,
                    onSave: { updatedItem in
                        if let index = addedItems.firstIndex(where: { $0.id == updatedItem.id }) {
                            addedItems[index] = updatedItem
                        }
                        // Recalculate subtotal and total
                        let subtotal = addedItems.reduce(0.0) { $0 + $1.cost }
                        costText = subtotal.formatted(.currency(code: "USD"))
                        
                        let tax = Double(taxText
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                            .replacingOccurrences(of: "$", with: "")
                            .replacingOccurrences(of: ",", with: "")) ?? 0.0
                        
                        let discount = Double(discountText
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                            .replacingOccurrences(of: "$", with: "")
                            .replacingOccurrences(of: ",", with: "")) ?? 0.0
                        
                        totalText = ((subtotal + tax) - discount).formatted(.currency(code: "USD"))
                        itemToEdit = nil
                    },
                    onCancel: {
                        itemToEdit = nil
                    }
                )
            }



            .alert("Delete Visit?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) { deleteVisit(); dismiss() }
                    .buttonStyle(.bordered)
                Button("Cancel", role: .cancel) {}
                    .buttonStyle(.bordered)
            } message: {
                Text("This action cannot be undone.")
            }
        }
    }
    
    var visitDetailsSection : some View {
        
        Section(header: Text("Visit Details")) {

            Section() {
                Grid(alignment: .leading, horizontalSpacing: 8, verticalSpacing: 8) {
                    GridRow {
                        Text("Tax:")
                        TextField("", text: $taxText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .tax)
                            .multilineTextAlignment(.trailing)
                            .gridColumnAlignment(.trailing)
                            .onChange (of: taxText){
                                updateTaxIfNeeded()
                            }
                        // make this entire column trailing
                    }
                    GridRow{
                        Text("Discount:")
                        TextField("", text: $discountText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .discount)
                            .multilineTextAlignment(.trailing)
                            .gridColumnAlignment(.trailing)
                            .onChange (of: discountText){
                                updateTaxIfNeeded()
                            }
                    }
                    GridRow {
                        Text("Cost for all Items:")
                        Text(costText)
                    }
                    GridRow {
                        Text("Grand Total").bold()
                        Text(totalText).bold()
                    }
                }
            }
            
            Picker("Provider", selection: $selectedProvider) {
                Text("Select Provider").tag(nil as ServiceProvider?)
                ForEach(serviceProviders) { provider in
                    Text(provider.name).tag(provider as ServiceProvider?)
                }
            }
            
            HStack {
                TextField("Mileage", text: $mileage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .mileage)
                
                Button("Use Current"){
                    if let mileage = selectedVehicle?.currentMileage {
                        self.mileage = formatMileage(mileage)
                    }
                }.buttonStyle(.bordered)
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

        var itemTotal: Double = 0.0
        for item in addedItems {
            itemTotal += item.cost
        }

        costText = formatter.string(from: NSNumber(value: itemTotal)) ?? ""
        taxText = formatter.string(from: NSNumber(value: visit.tax ?? 0.0)) ?? ""
        discountText = formatter.string(from: NSNumber(value: visit.discount ?? 0.0)) ?? ""
        totalText = formatter.string(from: NSNumber(value: itemTotal + (visit.tax ?? 0.0) - (visit.discount ?? 0.0))) ?? ""
        mileage = formatMileage(visit.mileage)
        notes = visit.notes ?? ""
        image = visit.photoData.flatMap(UIImage.init(data:))
        date = visit.date
    }

    private func cleanedMileageText(_ cost: String) -> Int? {
        let output = cost
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .replacingOccurrences(of: "$", with: "")
        .replacingOccurrences(of: ",", with: "")
        return Int(output)
    }
    
    private func updateTaxIfNeeded () {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.currencyCode = "USD"
        
        let cleanedCost = costText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: ",", with: "")
        
        let cleanedTax = taxText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: ",", with: "")
        
        let cleanedDiscount = discountText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: ",", with: "")
        
        if let cleanedCost = Double(cleanedCost) {
            let cleanedTax = Double(cleanedTax) ?? 0.0
            let cleanedDiscount = Double(cleanedDiscount) ?? 0.0
            let totalTemp = cleanedCost + cleanedTax - cleanedDiscount
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
        
        let cleanedDiscount = discountText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: ",", with: "")
        
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
        let discount = Double(cleanedDiscount)
        let totalCostWithTax = cost + (tax ?? 0.0) - (discount ?? 0.0)
        
        if let existingVisit = visitToEdit {
            visit = existingVisit
        } else {
            visit = ServiceVisit(date: date,
                                 mileage: mileageValue,
                                 cost: cost,
                                 tax : tax,
                                 discount: discount,
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
        visit.discount = discount
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
    
    private func formatMileage(_ mileage: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: mileage)) ?? "\(mileage)"
    }
    
    private func formatDollars(_ amount: Double) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.currencyCode = "USD"
        numberFormatter.string(from: NSNumber(value: amount))
        return "$\(amount)"
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

