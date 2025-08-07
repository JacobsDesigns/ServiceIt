//
//  SettingsView.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/13/25.
//
import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import ZIPFoundation


struct ExportedFile: Identifiable {
    let id = UUID()
    let url: URL
}

struct SettingsView: View {
    @State private var exportedFile: ExportedFile?
    @State private var showToast = false

    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Vehicle.name) var vehicles: [Vehicle]
    @Query(sort: \ServiceProvider.name) var providers: [ServiceProvider]
    @Query(sort: \ServiceItem.name) var serviceItems: [ServiceItem]
    @Query(sort: \RefuelStation.name) var refuelStations: [RefuelStation]
    @Query var allVisits: [ServiceVisit]

    // Sheet & Alert State
    @State private var showingAddVehicle = false
    @State private var editingVehicle: Vehicle?
    @State private var vehicleToDelete: Vehicle?
    @State private var confirmedVehicleToDelete: Vehicle?
    @State private var showDeleteVehicleWarning = false

    @State private var showingAddProvider = false
    @State private var editingProvider: ServiceProvider?
    @State private var providerToDelete: ServiceProvider?
    @State private var confirmedProviderToDelete: ServiceProvider?
    @State private var showDeleteProviderWarning = false
    
    @State private var showingAddItem = false
    @State private var editingItem: ServiceItem?
    @State private var itemToDelete: ServiceItem?
    @State private var confirmedItemToDelete: ServiceItem?
    @State private var showDeleteItemWarning = false
    
    @State private var showingAddStation = false
    @State private var editingStation: RefuelStation?
    @State private var stationToDelete: RefuelStation?
    @State private var confirmedStationToDelete: RefuelStation?
    @State private var showDeleteStationWarning = false
    
    
    // Import/Export State
    @State private var showImporter = false
    @State private var exportURL: URL?
    @State private var showExporter = false
    @State private var showShareLink = false
    
    var body: some View {
        ZStack {
            NavigationStack {
                List {
                    vehiclesSection
                    providersSection
                    serviceItemsSection
                    stationsSections
                    dataManagementSection
                }
                .navigationTitle("Settings")
                
                .alert("Cannot Delete Vehicle", isPresented: $showDeleteVehicleWarning, presenting: vehicleToDelete) { vehicle in
                    Button("Cancel", role: .cancel) {
                        vehicleToDelete = nil
                        confirmedVehicleToDelete = nil
                    }
                    Button("Delete Anyway", role: .destructive) {
                        confirmedVehicleToDelete = vehicle
                        vehicleToDelete = nil
                        showDeleteVehicleWarning = false
                    }
                } message: { vehicle in
                    Text("This Vehicle is still used by existing service records. Deleting it will remove the link.")
                }
                .deleteAlert(object: $confirmedVehicleToDelete, title: "Vehicle") { vehicle in
                    unlinkVehicle(from: vehicle)
                    modelContext.delete(vehicle)
                    try? modelContext.save()
                }
                
                .alert("Cannot Delete Service Item", isPresented: $showDeleteItemWarning, presenting: itemToDelete) { type in
                    Button("Cancel", role: .cancel) {
                        itemToDelete = nil
                        confirmedItemToDelete = nil
                    }
                    Button("Delete Anyway", role: .destructive) {
                        confirmedItemToDelete = type
                        itemToDelete = nil
                        showDeleteItemWarning = false
                    }
                } message: { type in
                    Text("This Service Item is still used by existing service records. Deleting it will remove the link.")
                }
                .deleteAlert(object: $confirmedItemToDelete, title: "Service Type") { type in
                    unlinkServiceType(from: type)
                    modelContext.delete(type)
                    try? modelContext.save()
                }
                
                .alert("Cannot Delete Service Provider", isPresented: $showDeleteProviderWarning, presenting: providerToDelete) { provider in
                    Button("Cancel", role: .cancel) {
                        providerToDelete = nil
                        confirmedProviderToDelete = nil
                    }
                    Button("Delete Anyway", role: .destructive) {
                        confirmedProviderToDelete = provider
                        providerToDelete = nil
                        showDeleteProviderWarning = false
                    }
                } message: { provider in
                    Text("This Service Provider is still used by existing service records. Deleting it will remove the link.")
                }
                .deleteAlert(object: $confirmedProviderToDelete, title: "Service Provider") { provider in
                    unlinkServiceProvider(from: provider)
                    modelContext.delete(provider)
                    try? modelContext.save()
                }
                
                
                .sheet(isPresented: $showingAddVehicle) {
                    AddVehicleView()
                }
                .sheet(item: $editingVehicle) {
                    EditVehicleView(vehicle: $0)
                }
                .sheet(isPresented: $showingAddProvider) {
                    AddProviderView()
                }
                .sheet(item: $editingProvider) {
                    EditProviderFormView(provider: $0)
                }
                .sheet(isPresented: $showingAddItem) {
                    AddServiceItemView()
                }
                .sheet(item: $editingItem) {
                    EditServiceTypeView(item: $0)
                }
                
                .sheet(isPresented: $showingAddStation) {
                    AddRefuelStation()
                }
                .sheet(item: $editingStation) {
                    EditRefuelStation(provider: $0)
                }
                
                
                .sheet(item: $exportedFile, onDismiss: {
                    showToast = true
                    //exportedFile = nil  // clean up state
                }) { file in
                    ShareLink(item: file.url) {
                        Label("Share Exported CSV", systemImage: "square.and.arrow.up")
                            .font(.title2)
                            .padding()
                            .onAppear {
                                // 🎯 Auto-dismiss after short delay
                                DispatchQueue.main.asyncAfter(deadline: .now() + 15.0) {
                                    exportedFile = nil
                                }
                            }
                    }
                    
                }
                
                //            .sheet(item: $exportedFile) { file in
                //                VStack(spacing: 20) {
                //                    ShareLink(item: file.url) {
                //                        Label("Share Exported CSV", systemImage: "square.and.arrow.up")
                //                    }
                //                    Button("Done") {
                //                        exportedFile = nil
                //                    }
                //                }
                //                .padding()
                //            }
                
                
                .fileImporter(
                    isPresented: $showImporter,
                    allowedContentTypes: [.commaSeparatedText],
                    allowsMultipleSelection: false
                ) { result in
                    if case let .success(urls) = result, let firstURL = urls.first {
                        confirmAndImport(from: firstURL)
                    }
                }
            }
            
            if showToast {
                VStack {
                    Spacer()
                    Text("✅ Export completed ... all records are in the folder 'ServiceIt'")
                        .padding()
                        .background(Color.gray.opacity(1.8))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .transition(.move(edge: .bottom))
                        .animation(.easeInOut, value: showToast)
                }
                .padding(.bottom, 40)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                        showToast = false
                    }
                }
            }
            
        }//end of ZStack
        

        
    }// end of view

    // MARK: - Sections

    var vehiclesSection: some View {
        Section("Vehicles") {
            ForEach(vehicles) { vehicle in
                Button {
                    editingVehicle = vehicle
                } label: {
                    VStack(alignment: .leading) {
                        Text("\(vehicle.modelYear.description) \(vehicle.name)")
                        Text("Current Mileage: \(vehicle.currentMileage)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
                .swipeActions {
                    Button(role: .destructive) {
                        handleVehicleDeleteRequest(vehicle)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }

            Button("Add Vehicle") {
                showingAddVehicle = true
            }
            .buttonStyle(BorderedButtonStyle())
        }
    }

    var providersSection: some View {
        Section("Service Providers") {
            ForEach(providers) { provider in
                Button {
                    editingProvider = provider
                } label: {
                    VStack(alignment: .leading) {
                            Text(provider.name)
                            Text(provider.contactInfo)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                    }
                }
                .swipeActions {
                    Button(role: .destructive) {
                        handleProviderDeleteRequest(provider)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }

            Button("Add Provider") {
                showingAddProvider = true
            }
            .buttonStyle(BorderedButtonStyle())
        }
    }

    var serviceItemsSection: some View {
        Section("Service Items") {
            ForEach(serviceItems) { item in
                Button {
                    editingItem = item
                } label: {
                    HStack {
                        Text(item.name)
                        Spacer()
                        Text("Cost: \(item.cost.formatted(.currency(code: "USD")))")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
                .swipeActions {
                    Button(role: .destructive) {
                        handleServiceTypeDeleteRequest(item)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }

            Button("Add Service Item") {
                showingAddItem = true
            }
            .buttonStyle(BorderedButtonStyle())
        }
    }

    var stationsSections: some View {
        Section("Gas Stations"){
            ForEach(refuelStations) { station in
                Button {
                    editingStation = station
                } label: {
                    HStack {
                        Text(station.name)
                        Spacer()
                        Text("\(station.location)")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
//                .swipeActions {
//                    Button(role: .destructive){
//                        handleVehicleDeleteRequest(station)
//                    } label {
//                        Label("Delete", systemImage: "trash")
//                    }
//                }
            }
            Button("Add Gas Station") {
                showingAddStation = true
            }
            .buttonStyle(BorderedButtonStyle())
        }
    }
    
    var dataManagementSection: some View {
        Section("Data Management") {
            Button("Export Service Records") {
                showShareLink = false
                showExporter = true
                exportCSV()
                showToast = true
            }
            Button("Import from CSV") {
                showImporter = true
            }
        }
    }

    // MARK: - Import & Export Helpers

//    private func exportCSV() {
//        let imageDirectory = URL.documentsDirectory.appendingPathComponent("ExportedImages")
//
//        // Ensure ExportedImages folder exists
//        if !FileManager.default.fileExists(atPath: imageDirectory.path) {
//            try? FileManager.default.createDirectory(at: imageDirectory, withIntermediateDirectories: true)
//        }
//
//        let filename = "service_export.csv"
//        let csvURL = URL.documentsDirectory.appendingPathComponent(filename)
//        let zipURL = URL.documentsDirectory.appendingPathComponent("service_export.zip")
//
//        // Generate CSV content
//        let csv = generateCSV(from: allVisits, imageDirectory: imageDirectory)
//
//        do {
//            // Write CSV
//            try csv.write(to: csvURL, atomically: true, encoding: .utf8)
//
//            // Collect files: CSV + Images
//            var filesToZip: [URL] = [csvURL]
//            if let imageFiles = try? FileManager.default.contentsOfDirectory(at: imageDirectory, includingPropertiesForKeys: nil) {
//                filesToZip.append(contentsOf: imageFiles)
//            }
//
//             //Create ZIP archive
//            try FileManager.default.zipItem(
//                at: csvURL.deletingLastPathComponent(), // directory containing the files
//                to: zipURL,
//                shouldKeepParent: false
//            )
//
//             //Update exported file reference if needed
//            if FileManager.default.fileExists(atPath: zipURL.path) {
//                exportedFile = ExportedFile(url: zipURL)
//                print("✅ ZIP export successful at: \(zipURL.path)")
//            } else {
//                print("⚠️ ZIP file not found after creation")
//            }
//
//        } catch {
//            print("❌ Export failed: \(error)")
//        }
//    }

    private func exportCSV() {
        let filename = "service_export.csv"
        let csvURL = URL.documentsDirectory.appendingPathComponent(filename)

        // Generate CSV content (passing a dummy imageDirectory since it's unused)
        let csv = generateCSV(from: allVisits, imageDirectory: URL(fileURLWithPath: "/dev/null"))

        do {
            try csv.write(to: csvURL, atomically: true, encoding: .utf8)
            print("✅ CSV export successful at: \(csvURL.path)")
        } catch {
            print("❌ Export failed: \(error)")
        }
    }


    private func generateCSV(from records: [ServiceVisit], imageDirectory: URL) -> String {
        print("total records received: \(records.count)")
        
        var lines = ["date,mileage,cost,items,itemsCost,provider,contactInfo,vehicle,year,vin,license,imageFilename"]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        for record in records {
            
            print("processing record: \(record)")
            
            guard let vehicle = record.vehicle,
                  let provider = record.provider,
                  !record.savedItems.isEmpty,
                  isValid(vehicle), isValid(provider) else {
                print("⚠️ Skipping invalid record: \(record)")
                continue
            }

            let date = formatter.string(from: record.date)
            let mileage = "\(record.mileage)"
            let cost = String(format: "%.2f", record.cost)
            let items = record.savedItems.map { $0.name }.joined(separator: ";")
            let providerName = provider.name
            let contactInfo = provider.contactInfo
            let vehicleName = vehicle.name
            let year = "\(vehicle.modelYear)"
            let vin = vehicle.vin
            let license = vehicle.license
            let itemsCost = record.savedItems.map {String($0.cost)}.joined(separator: ";")

            var imageFilename: String = ""

            if let photoData = vehicle.photoData {
                let idHash = vehicle.persistentModelID.id.hashValue
                let sanitizedID = String(idHash).replacingOccurrences(of: "[^a-zA-Z0-9]", with: "_", options: .regularExpression)
                let filename = "Vehicle_\(sanitizedID).jpg"

                let imageURL = imageDirectory.appendingPathComponent(filename)

                do {
                    try photoData.write(to: imageURL)
                    imageFilename = filename
                } catch {
                    print("❌ Failed to save image for \(vehicle.name): \(error)")
                    imageFilename = "" // fallback
                }
            }

            lines.append("\(date),\(mileage),\(cost),\(items),\(itemsCost),\(providerName),\(contactInfo),\(vehicleName),\(year),\(vin),\(license),\(imageFilename)")
            
            print ("appended line for \(vehicle.name)")
        }

        return lines.joined(separator: "\n")
    }

    private func isValid<T: PersistentModel>(_ model: T) -> Bool {
        let id = model.persistentModelID
        let descriptor = FetchDescriptor<T>(
            predicate: #Predicate {
                $0.persistentModelID == id
            }
        )
        return (try? modelContext.fetch(descriptor).first) != nil
    }

    
    private func isServiceTypeInUse(_ serviceType: ServiceItem) -> Bool {
        let typeID = serviceType.persistentModelID

        let descriptor = FetchDescriptor<ServiceVisit>(
            predicate: #Predicate<ServiceVisit> {
                $0.savedItems.contains(where: { $0.persistentModelID == typeID })
            }
        )
        return (try? modelContext.fetch(descriptor))?.isEmpty == false
    }

    private func isServiceProviderInUse(_ provider: ServiceProvider) -> Bool {
        let providerID = provider.persistentModelID
        let descriptor = FetchDescriptor<ServiceVisit>(
            predicate: #Predicate {
                $0.provider?.persistentModelID == providerID
            }
        )
        return (try? modelContext.fetch(descriptor))?.isEmpty == false
    }

    private func isVehicleInUse(_ vehicle: Vehicle) -> Bool {
        let vehicleID = vehicle.persistentModelID
        let descriptor = FetchDescriptor<ServiceVisit>(
            predicate: #Predicate {
                $0.vehicle?.persistentModelID == vehicleID
            }
        )
        return (try? modelContext.fetch(descriptor))?.isEmpty == false
    }
    
    
    
    private func handleServiceTypeDeleteRequest(_ type: ServiceItem) {
        let typeID = type.persistentModelID
        let descriptor = FetchDescriptor<ServiceVisit>(
            predicate: #Predicate<ServiceVisit> {
                $0.savedItems.contains(where: { $0.persistentModelID == typeID })
            }
        )
        if let linkedRecords = try? modelContext.fetch(descriptor), !linkedRecords.isEmpty {
            itemToDelete = type
            showDeleteItemWarning = true
        } else {
            confirmedItemToDelete = type
        }
    }

    private func handleProviderDeleteRequest(_ provider: ServiceProvider) {
        let providerID = provider.persistentModelID
        let descriptor = FetchDescriptor<ServiceVisit>(
            predicate: #Predicate {
                $0.provider?.persistentModelID == providerID
            }
        )

        if let linkedRecords = try? modelContext.fetch(descriptor), !linkedRecords.isEmpty {
            providerToDelete = provider
            showDeleteProviderWarning = true
        } else {
            confirmedProviderToDelete = provider
        }
    }

    private func handleVehicleDeleteRequest(_ vehicle: Vehicle) {
        let vehicleID = vehicle.persistentModelID
        let descriptor = FetchDescriptor<ServiceVisit>(
            predicate: #Predicate {
                $0.vehicle?.persistentModelID == vehicleID
            }
        )

        if let linkedRecords = try? modelContext.fetch(descriptor), !linkedRecords.isEmpty {
            vehicleToDelete = vehicle
            showDeleteVehicleWarning = true
        } else {
            confirmedVehicleToDelete = vehicle
        }
    }
    


    
    private func unlinkServiceType(from type: ServiceItem) {
        let typeID = type.persistentModelID

        let descriptor = FetchDescriptor<ServiceVisit>(
            predicate: #Predicate<ServiceVisit> {
                $0.savedItems.contains(where: { $0.persistentModelID == typeID })
            }
        )

        if let records = try? modelContext.fetch(descriptor) {
            for record in records {
                record.savedItems.removeAll(where: { $0.persistentModelID == typeID })
            }
        }
    }

    private func unlinkServiceProvider(from provider: ServiceProvider) {
        let providerID = provider.persistentModelID
        let descriptor = FetchDescriptor<ServiceVisit>(
            predicate: #Predicate {
                $0.provider?.persistentModelID == providerID
            }
        )

        if let records = try? modelContext.fetch(descriptor) {
            for record in records {
                record.provider = nil
            }
        }
    }

    private func unlinkVehicle(from vehicle: Vehicle) {
        let vehicleID = vehicle.persistentModelID
        let descriptor = FetchDescriptor<ServiceVisit>(
            predicate: #Predicate {
                $0.vehicle?.persistentModelID == vehicleID
            }
        )

        if let records = try? modelContext.fetch(descriptor) {
            for record in records {
                record.vehicle = nil
            }
        }
    }

    






    private func confirmAndImport(from url: URL) {
        let alert = buildImportConfirmationAlert(for: url)
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = scene.windows.first?.rootViewController {
            rootVC.present(alert, animated: true)
        }
    }

    private func buildImportConfirmationAlert(for url: URL) -> UIAlertController {
        let alert = UIAlertController(
            title: "Replace Existing Records?",
            message: "This will delete all current service records only if the import succeeds. Continue?",
            preferredStyle: .alert
        )

        let importAction = UIAlertAction(title: "Import", style: .destructive) { _ in
            guard url.startAccessingSecurityScopedResource() else {
                print("❌ Failed to access security scoped resource")
                showImportFailurePopup()
                return
            }

            defer { url.stopAccessingSecurityScopedResource() }

            // ✅ Try importing first (no deletion yet)
            importServiceRecords(from: url) { success in
                if success {
                    print("✅ Safe to delete old records after confirmed import")
                    //deleteExistingServiceRecords()
                } else {
                    print("⚠️ Import failed — existing records preserved")
                    showImportFailurePopup()
                }
            }
        }

        alert.addAction(importAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        return alert
    }

    private func showImportFailurePopup() {
        let alert = UIAlertController(
            title: "Import Failed",
            message: "We couldn’t read the CSV file. Please check the format and try again.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = scene.windows.first?.rootViewController {
            root.present(alert, animated: true)
        }
    }
    
    private func deleteExistingServiceRecords() {
        let recordDescriptor = FetchDescriptor<ServiceVisit>()
        let vehicleDescriptor = FetchDescriptor<Vehicle>()
        let providerDescriptor = FetchDescriptor<ServiceProvider>()
        let typeDescriptor = FetchDescriptor<ServiceItem>()

        do {
            let records = try modelContext.fetch(recordDescriptor)
            let vehicles = try modelContext.fetch(vehicleDescriptor)
            let providers = try modelContext.fetch(providerDescriptor)
            let types = try modelContext.fetch(typeDescriptor)

            records.forEach { modelContext.delete($0) }
            vehicles.forEach { modelContext.delete($0) }
            providers.forEach { modelContext.delete($0) }
            types.forEach { modelContext.delete($0) }

            try modelContext.save()
            print("🧹 Deleted all service data: \(records.count) records, \(vehicles.count) vehicles, \(providers.count) providers, \(types.count) types")
        } catch {
            print("❌ Failed to delete data: \(error)")
        }
    }

    private func importServiceRecords(from url: URL, completion: @escaping (Bool) -> Void) {
        guard let content = try? String(contentsOf: url, encoding: .ascii) else {
            print("❌ Unable to read CSV file")
            completion(false)
            return
        }

        let rows = content
            .components(separatedBy: .newlines)
            .dropFirst() // skip header row

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        for row in rows {
            let fields = row.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

            guard fields.count >= 12 else {
                print("⚠️ Skipping malformed row: \(row)")
                continue
            }

            // 📅 Parse row fields
            let date = dateFormatter.date(from: fields[0]) ?? .now
            let mileage = Int(fields[1]) ?? 0
            let cost = Double(fields[2]) ?? 0.0
            let typeName = fields[3]
            let providerName = fields[4]
            let contactInfo = fields[5]
            let vehicleName = fields[6]
            let vehicleYear = Int(fields[7]) ?? 0
            let vin = fields[8]
            let license = fields[9]
            let suggestedMileage = Int(fields[10]) ?? 0
            let imageFilename = fields[11]
            
            
            
            let imageDirectory = URL.documentsDirectory.appendingPathComponent("ExportedImages")
            let imageURL = imageDirectory.appendingPathComponent(imageFilename)
            var photoData: Data? = nil
            if FileManager.default.fileExists(atPath: imageURL.path) {
                photoData = try? Data(contentsOf: imageURL)
            } else {
                print("⚠️ Image not found: \(imageURL.lastPathComponent)")
            }

            if photoData == nil {
                if let iCloudURL = FileManager.default.url(forUbiquityContainerIdentifier: "iCloud.com.jacob.ServiceIt")?
                    .appendingPathComponent("Documents/ExportedImages") {
                    let iCloudImageURL = iCloudURL.appendingPathComponent(imageFilename)
                    photoData = try? Data(contentsOf: iCloudImageURL)
                    if photoData == nil {
                        print("⚠️ Image not found in iCloud either: \(imageFilename)")
                    }
                } else {
                    print("⚠️ iCloud container not available — skipping image: \(imageFilename)")
                }
            }

//            if photoData == nil {
//                guard let iCloudURL = FileManager.default.url(forUbiquityContainerIdentifier: "iCloud.com.jacob.ServiceIt")?
//                    .appendingPathComponent("Documents/ExportedImages") else {
//                    print("❌ iCloud container not available")
//                    return
//                }
//                let imageURL = iCloudURL.appendingPathComponent(imageFilename)
//                photoData = try? Data(contentsOf: imageURL)
//            }
            

            // 🚗 Vehicle matching or creation
            let vehicle = fetchExistingVehicle(name: vehicleName, year: vehicleYear, vin: vin, license: license)
                ?? {
                    let newVehicle = Vehicle(name: vehicleName, modelYear: vehicleYear, vin: vin, license: license, currentMileage: mileage)
                    newVehicle.photoData = photoData
                    modelContext.insert(newVehicle)
                    return newVehicle
                }()

            // 🏢 Provider matching or creation
            let provider = fetchExitingProvider(name: providerName, contactInfo: contactInfo)
                ?? {
                    let newProvider = ServiceProvider(name: providerName, contactInfo: contactInfo)
                    modelContext.insert(newProvider)
                    return newProvider
                }()

            // 🔧 ServiceType matching or creation
            let type = fetchExistingServiceType(name: typeName)
                ?? {
                    let newType = ServiceItem(name: typeName, cost: Double(suggestedMileage))
                    modelContext.insert(newType)
                    return newType
                }()

            // 📝 Final Record
//            let record = ServiceVisit(
//                vehicle: vehicle,
//                type: type,
//                cost: cost,
//                date: date,
//                mileage: mileage
//            )
//            record.provider = provider
//            modelContext.insert(record)
        }

        do {
            try modelContext.save()
            print("✅ Import complete")
            completion(true)
        } catch {
            print("❌ Failed to save context: \(error.localizedDescription)")
            completion(false)
        }
    }


    private func fetchExistingVehicle(name: String, year: Int, vin: String, license: String) -> Vehicle? {
        let descriptor = FetchDescriptor<Vehicle>(
            predicate: #Predicate {
                $0.name == name &&
                $0.modelYear == year &&
                $0.vin == vin &&
                $0.license == license
            }
        )
        return try? modelContext.fetch(descriptor).first
    }
    
    private func fetchExitingProvider(name: String, contactInfo: String) -> ServiceProvider? {
        let descriptor = FetchDescriptor<ServiceProvider>(
            predicate: #Predicate {
                $0.name == name &&
                $0.contactInfo == contactInfo
            }
        )
        return try? modelContext.fetch(descriptor).first
    }

    private func fetchExistingServiceType(name rawName: String) -> ServiceItem? {
        let normalizedName = rawName.trimmingCharacters(in: .whitespacesAndNewlines)

        let descriptor = FetchDescriptor<ServiceItem>(
            predicate: #Predicate { type in
                type.name == normalizedName
            }
        )
        return try? modelContext.fetch(descriptor).first
    }



    
}

extension View {
    func deleteAlert<T: Identifiable>(
        object: Binding<T?>,
        title: String,
        message: String? = nil,
        deleteAction: @escaping (T) -> Void
    ) -> some View {
        self.alert("Delete \(title)?", isPresented: Binding(
            get: { object.wrappedValue != nil },
            set: { newValue in
                if !newValue {
                    object.wrappedValue = nil
                }
            }
        ), presenting: object.wrappedValue) { item in
            Button("Delete", role: .destructive) {
                deleteAction(item)
                object.wrappedValue = nil
            }
            Button("Cancel", role: .cancel) {
                object.wrappedValue = nil
            }
        } message: { item in
            Text(message ?? "This will permanently delete this \(title.lowercased()).")
        }
    }
}



#Preview {
    SettingsView()
        .modelContainer(PreviewContainer.shared)
}
