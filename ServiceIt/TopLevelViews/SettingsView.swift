//
//  SettingsView.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/13/25.
//
import SwiftUI
import SwiftData
import UniformTypeIdentifiers
//import ZIPFoundation


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
    @Query var allRefuels: [RefuelVisit]

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
    
    @State private var distance: Int = 10
    @State private var speed: Int = 60
    
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
                    special
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
                    Text("This Service Item is still used by existing service records. Deleting it will remove the link and Delete all associated records.")
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
                    Text("This Service Provider is still used by existing service records. Deleting it will remove the link and Delete all associated service records.")
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
            Button("Export Records ... Data Only") {
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

    var special: some View {
        Section(header: Text("Travel Time Calculator")) {
            HStack(alignment: .top, spacing: 13) {
                VStack(alignment: .leading) {
                    Text("Distance (miles)")
                    Picker("Distance", selection: $distance) {
                        ForEach(1...500, id: \.self) { value in
                            Text("\(value)").tag(value)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity, maxHeight: 120)
                }

                VStack(alignment: .leading) {
                    Text("Speed (mph)")
                    Picker("Speed", selection: $speed) {
                        ForEach(1...120, id: \.self) { value in
                            Text("\(value)").tag(value)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(maxWidth: .infinity, maxHeight: 120)
                }
            }

            HStack {
                Text("Estimated Time...")
                Spacer()
                Text(travelTime)
                    .fontWeight(.bold)
            }

            Button(role: .destructive) {
                distance = 10
                speed = 60
            } label: {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Reset")
                }
            }
        }
    }
    
    
    
    // MARK: - Import & Export Helpers

    private var travelTime: String {
        guard speed > 0 else { return "—" }
        
        let time = Double(distance) / Double(speed)
        let hours = Int(time)
        let minutes = Int((time - Double(hours)) * 60)
        return "\(hours)h \(minutes)m"
    }

    
    private func exportCSV() {
        let serviceFilename = "service_export.csv"
        let refuelFileName = "refuel_export.csv"
        let serviceCSVURL = URL.documentsDirectory.appendingPathComponent(serviceFilename)
        let refuelCSVURL = URL.documentsDirectory.appendingPathComponent(refuelFileName)

        // Generate CSV content
        let serviceCSV = generateCSV(from: allVisits)
        let refuelCSV = generateRefuelCSV(from: allRefuels)

        do {
            try serviceCSV.write(to: serviceCSVURL, atomically: true, encoding: .utf8)
            print("Service CSV export successful at: \(serviceCSVURL.path)")
        } catch {
            print("Service Export failed: \(error)")
        }
        do {
            try refuelCSV.write(to: refuelCSVURL, atomically: true, encoding: .utf8)
            print("Refuel CSV export successful at: \(refuelCSVURL.path)")
        } catch {
            print("Refuel Export failed: \(error)")
        }
    }


    private func generateCSV(from records: [ServiceVisit]) -> String {
        print("total records received: \(records.count)")
        
        var lines = ["date,mileage,cost,tax,discount,items,itemsCost,provider,contactInfo,vehicle,year,vin,license"]
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
            let tax = record.tax != nil ? String(format: "%.2f", record.tax!) : ""
            let discount = record.discount != nil ? String(format: "%.2f", record.discount!) : ""
            let items = record.savedItems.map { $0.name }.joined(separator: ";")
            let providerName = provider.name
            let contactInfo = provider.contactInfo
            let vehicleName = vehicle.name
            let year = "\(vehicle.modelYear)"
            let vin = vehicle.vin
            let license = vehicle.license
            let itemsCost = record.savedItems.map {String($0.cost)}.joined(separator: ";")
            
            lines.append("\(date),\(mileage),\(cost),\(tax),\(discount),\(items),\(itemsCost),\(providerName),\(contactInfo),\(vehicleName),\(year),\(vin),\(license)")
            
            print ("appended line for \(vehicle.name)")
        }

        return lines.joined(separator: "\n")
    }

    private func generateRefuelCSV(from records: [RefuelVisit]) -> String {
        print("total records received: \(records.count)")
        
        var lines = ["Odometer,Date,Gallons,costPerGallon,Total,Carwash,CarWashCost,Vehicle,RefuleStation,StationLocation"]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        for record in records {
            
            guard let vehicle = record.vehicle,
                  let refuelStation = record.refuelStation,
                  isValid(vehicle), isValid(refuelStation) else {
                print("⚠️ Skipping invalid record: \(record)")
                continue
            }
            
            let odometer = "\(record.odometer)"
            let date = formatter.string(from: record.date)
            let gallons = record.gallons
            let costPerGallon = String(format: "%.2f", record.costPerGallon)
            let total = record.total
            let carWash = record.addedCarWash
            let carWashCost = String(format: "%.2f", record.carWashCost ?? "")
            let vehicleName = vehicle.name
            let refuelStationName = refuelStation.name
            let refuelStationLocation = refuelStation.location
            
            lines.append("\(odometer),\(date),\(gallons),\(costPerGallon),\(total),\(carWash),\(carWashCost),\(vehicleName),\(refuelStationName),\(refuelStationLocation)")
            
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
            message: "Choose what to import. (Use service_export.csv for Service, refuel_export.csv for Refuel.) Existing data is preserved if import fails.",
            preferredStyle: .alert
        )

        let importAction = UIAlertAction(title: "Import Service Records", style: .destructive) { _ in
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
        
        let importRefuelAction = UIAlertAction(title: "Import Refuel Records", style: .destructive) { _ in
            guard url.startAccessingSecurityScopedResource() else {
                print("❌ Failed to access security scoped resource")
                showImportFailurePopup()
                return
            }

            defer { url.stopAccessingSecurityScopedResource() }

            importRefuelRecords(from: url) { success in
                if success {
                    print("✅ Refuel import succeeded")
                } else {
                    print("⚠️ Refuel import failed — existing records preserved")
                    showImportFailurePopup()
                }
            }
        }

        alert.addAction(importAction)
        alert.addAction(importRefuelAction)
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
        // Read CSV data robustly (CSV exports are typically UTF-8)
        let content: String
        do {
            let data = try Data(contentsOf: url)
            if let s = String(data: data, encoding: .utf8) {
                content = s
            } else if let s = String(data: data, encoding: .utf16) {
                content = s
            } else if let s = String(data: data, encoding: .isoLatin1) {
                content = s
            } else {
                print("❌ Unable to decode CSV data. URL: \(url)")
                completion(false)
                return
            }
        } catch {
            print("❌ Unable to read CSV file at URL: \(url). Error: \(error)")
            completion(false)
            return
        }

        print("📄 Import URL: \(url)")
        print("📄 CSV length: \(content.count) chars")

        // CSV parser for quoted fields
        func parseCSVLine(_ line: String) -> [String] {
            var result: [String] = []
            var current = ""
            var inQuotes = false
            var iterator = line.makeIterator()

            while let ch = iterator.next() {
                if ch == "\"" {
                    if inQuotes {
                        // If next char is also a quote, it's an escaped quote
                        if let next = iterator.next() {
                            if next == "\"" {
                                current.append("\"")
                            } else {
                                // End quotes; push back the extra char by processing it normally
                                inQuotes = false
                                if next == "," {
                                    result.append(current)
                                    current = ""
                                } else {
                                    current.append(next)
                                }
                            }
                        } else {
                            inQuotes = false
                        }
                    } else {
                        inQuotes = true
                    }
                } else if ch == "," && !inQuotes {
                    result.append(current)
                    current = ""
                } else {
                    current.append(ch)
                }
            }
            result.append(current)
            return result.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        }

        let rows = content
            .components(separatedBy: .newlines)
            .dropFirst() // skip header row

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        for row in rows {
            let trimmedRow = row.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedRow.isEmpty { continue }
            let fields = parseCSVLine(trimmedRow)

            guard fields.count >= 13 else {
                print("⚠️ Skipping malformed row: \(row)")
                continue
            }

            // 📅 Parse row fields (must match export header)
            let date = dateFormatter.date(from: fields[0]) ?? .now
            let mileage = Int(fields[1]) ?? 0
            let cost = Double(fields[2]) ?? 0.0
            
            let taxString = fields[3].trimmingCharacters(in: .whitespacesAndNewlines)
            let tax = taxString.isEmpty ? nil : Double(taxString)

            let discountString = fields[4].trimmingCharacters(in: .whitespacesAndNewlines)
            let discount = discountString.isEmpty ? nil : Double(discountString)

            let itemsField = fields[5]
            let itemsCostField = fields[6]

            let providerName = fields[7]
            let contactInfo = fields[8]

            let vehicleName = fields[9]
            let vehicleYear = Int(fields[10]) ?? 0
            let vin = fields[11]
            let license = fields[12]

            let itemNames = itemsField.split(separator: ";").map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
            let itemCosts = itemsCostField.split(separator: ";").map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }

            // 🚗 Vehicle matching or creation
            let vehicle = fetchExistingVehicle(name: vehicleName, year: vehicleYear, vin: vin, license: license)
                ?? {
                    let newVehicle = Vehicle(name: vehicleName, modelYear: vehicleYear, vin: vin, license: license, currentMileage: mileage)
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

            // 📝 Final Record
            let computedTotal = cost + (tax ?? 0) - (discount ?? 0)
            let record = ServiceVisit(
                date: date,
                mileage: mileage,
                cost: cost,
                tax: tax,
                discount: discount,
                total: computedTotal,
                savedItems: []
            )
            record.vehicle = vehicle
            record.provider = provider

            // Recreate saved items from the exported items/itemsCost columns
            for (idx, name) in itemNames.enumerated() {
                let costString = idx < itemCosts.count ? itemCosts[idx] : ""
                let itemCost = Double(costString) ?? 0

                // Ensure the master ServiceItem exists (optional but useful for pickers)
                if fetchExistingServiceType(name: name) == nil {
                    let master = ServiceItem(name: name, cost: itemCost)
                    modelContext.insert(master)
                }

                let saved = SavedServiceItem(name: name, cost: itemCost)
                saved.visit = record
                record.savedItems.append(saved)
            }

            modelContext.insert(record)
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

    private func importRefuelRecords(from url: URL, completion: @escaping (Bool) -> Void) {
        // Read CSV data robustly (CSV exports are typically UTF-8)
        let content: String
        do {
            let data = try Data(contentsOf: url)
            if let s = String(data: data, encoding: .utf8) {
                content = s
            } else if let s = String(data: data, encoding: .utf16) {
                content = s
            } else if let s = String(data: data, encoding: .isoLatin1) {
                content = s
            } else {
                print("❌ Unable to decode CSV data. URL: \(url)")
                completion(false)
                return
            }
        } catch {
            print("❌ Unable to read CSV file at URL: \(url). Error: \(error)")
            completion(false)
            return
        }

        print("⛽️ Refuel Import URL: \(url)")
        print("⛽️ CSV length: \(content.count) chars")

        let rows = content
            .components(separatedBy: .newlines)
            .dropFirst() // skip header

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        for row in rows {
            let trimmed = row.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty { continue }

            // NOTE: generateRefuelCSV currently does not quote fields; this simple split matches the export.
            let fields = trimmed.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

            // Export header: Odometer,Date,Gallons,costPerGallon,Total,Carwash,CarWashCost,Vehicle,RefuleStation,StationLocation
            guard fields.count >= 10 else {
                print("⚠️ Skipping malformed refuel row: \(row)")
                continue
            }

            let odometer = Int(fields[0]) ?? 0
            let date = dateFormatter.date(from: fields[1]) ?? .now
            let gallons = Double(fields[2]) ?? 0
            let costPerGallon = Double(fields[3]) ?? 0
            let total = Double(fields[4]) ?? 0

            let carwashRaw = fields[5].lowercased()
            let addedCarWash = (carwashRaw == "true" || carwashRaw == "1" || carwashRaw == "yes")

            let carWashCostString = fields[6]
            let carWashCost = Double(carWashCostString)

            let vehicleName = fields[7]
            let stationName = fields[8]
            let stationLocation = fields[9]

            let vehicle = fetchExistingVehicleByNameOnly(name: vehicleName)
                ?? {
                    // Minimal placeholder values for required fields
                    let newVehicle = Vehicle(name: vehicleName, modelYear: 0, vin: "", license: "", currentMileage: odometer)
                    modelContext.insert(newVehicle)
                    return newVehicle
                }()

            let station = fetchExistingRefuelStation(name: stationName, location: stationLocation)
                ?? {
                    let newStation = RefuelStation(name: stationName, location: stationLocation)
                    modelContext.insert(newStation)
                    return newStation
                }()

            // Create refuel visit
            let visit = RefuelVisit(
                odometer: odometer,
                date: date,
                gallons: gallons,
                costPerGallon: costPerGallon,
                total: total,
            )
            visit.addedCarWash = addedCarWash
            visit.carWashCost = carWashCost
            visit.vehicle = vehicle
            visit.refuelStation = station

            modelContext.insert(visit)
        }

        do {
            try modelContext.save()
            completion(true)
        } catch {
            print("❌ Failed to save context (refuel import): \(error.localizedDescription)")
            completion(false)
        }
    }

    private func fetchExistingVehicleByNameOnly(name: String) -> Vehicle? {
        let descriptor = FetchDescriptor<Vehicle>(
            predicate: #Predicate {
                $0.name == name
            }
        )
        return try? modelContext.fetch(descriptor).first
    }

    private func fetchExistingRefuelStation(name: String, location: String) -> RefuelStation? {
        let descriptor = FetchDescriptor<RefuelStation>(
            predicate: #Predicate {
                $0.name == name &&
                $0.location == location
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
