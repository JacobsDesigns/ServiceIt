//
//  SettingsView.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/13/25.
//
import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Vehicle.name) var vehicles: [Vehicle]
    @Query(sort: \ServiceProvider.name) var providers: [ServiceProvider]
    @Query(sort: \ServiceType.name) var serviceTypes: [ServiceType]
    @Query var allRecords: [ServiceRecord]

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
    
    @State private var showingAddType = false
    @State private var editingType: ServiceType?
    @State private var typeToDelete: ServiceType?
    @State private var confirmedTypeToDelete: ServiceType?
    @State private var showDeleteTypeWarning = false
    
    // Import/Export State
    @State private var showImporter = false
    @State private var exportURL: URL?
    @State private var showExporter = false
    @State private var showShareLink = false
    
    var body: some View {
        NavigationStack {
            List {
                vehiclesSection
                providersSection
                serviceTypesSection
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
            
            .alert("Cannot Delete Service Type", isPresented: $showDeleteTypeWarning, presenting: typeToDelete) { type in
                Button("Cancel", role: .cancel) {
                    typeToDelete = nil
                    confirmedTypeToDelete = nil
                }
                Button("Delete Anyway", role: .destructive) {
                    confirmedTypeToDelete = type
                    typeToDelete = nil
                    showDeleteTypeWarning = false
                }
            } message: { type in
                Text("This Service Type is still used by existing service records. Deleting it will remove the link.")
            }
            .deleteAlert(object: $confirmedTypeToDelete, title: "Service Type") { type in
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
            
            
            .overlay(alignment: .bottom) {
                VStack(spacing: 12) {

                    if showShareLink, let exportURL {
                        ShareLink(item: exportURL) {
                            Label("Export CSV", systemImage: "square.and.arrow.up")
                                .padding(12)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())
                        }
                        .onTapGesture {
                            showShareLink = false
                        }
                        .transition(.scale)
                    }
                }
                .padding(.bottom, 32)
                .animation(.easeInOut, value: showShareLink)
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
            .sheet(isPresented: $showingAddType) {
                AddServiceTypeView()
            }
            .sheet(item: $editingType) {
                EditServiceTypeView(type: $0)
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
            .sheet(isPresented: $showExporter) {
                if let exportURL {
                    ShareLink(item: exportURL) {
                        Label("Share Exported CSV", systemImage: "square.and.arrow.up")
                    }
                    .padding()
                }
            }

        }
    }

    // MARK: - Sections

    var vehiclesSection: some View {
        Section("Vehicles") {
            ForEach(vehicles) { vehicle in
                Button {
                    editingVehicle = vehicle
                } label: {
                    VStack(alignment: .leading) {
                        Text("\(vehicle.modelYear.description) \(vehicle.name)")
                        Text("Mileage: \(vehicle.currentMileage)")
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
            .buttonStyle(.borderedProminent)
        }
    }

    var providersSection: some View {
        Section("Service Providers") {
            ForEach(providers) { provider in
                Button {
                    editingProvider = provider
                } label: {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(provider.name)
                            Spacer()
                            Text(provider.contactInfo)
                                .font(.footnote)
                        }
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
            .buttonStyle(.borderedProminent)
        }
    }

    var serviceTypesSection: some View {
        Section("Service Types") {
            ForEach(serviceTypes) { type in
                Button {
                    editingType = type
                } label: {
                    Text(type.name)
                }
                .swipeActions {
                    Button(role: .destructive) {
                        handleServiceTypeDeleteRequest(type)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }

            Button("Add Service Type") {
                showingAddType = true
            }
            .buttonStyle(.borderedProminent)
        }
    }

    var dataManagementSection: some View {
        Section("Data Management") {
            Button("Export Service Records") {
                exportCSV()
            }

            Button("Import from CSV") {
                showImporter = true
            }
        }
    }

    // MARK: - Import & Export Helpers

    
    func generateCSV(from records: [ServiceRecord]) -> String {
        var lines = ["date,mileage,cost,type,provider,contactInfo,vehicle,year,vin,license,typeSuggestedMileage"]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        for record in records {
            
            guard let vehicle = record.vehicle,
                  let provider = record.provider,
                  let type = record.type,
                  isValid(vehicle), isValid(provider), isValid(type) else {
                print("⚠️ Skipping invalid record: \(record)")
                continue
            }

            let date = formatter.string(from: record.date)
            let mileage = "\(record.mileage)"
            let cost = String(format: "%.2f", record.cost)
            let typeName = type.name
            let providerName = provider.name
            let contactInfo = provider.contactInfo
            let vehicleName = vehicle.name
            let year = "\(vehicle.modelYear)"
            let vin = vehicle.vin
            let license = vehicle.license
            let suggestedMilage = type.suggestedMileage ?? 0

            lines.append("\(date),\(mileage),\(cost),\(typeName),\(providerName),\(contactInfo),\(vehicleName),\(year),\(vin),\(license),\(suggestedMilage)")
        }

        return lines.joined(separator: "\n")
    }

    func isValid<T: PersistentModel>(_ model: T) -> Bool {
        let id = model.persistentModelID
        let descriptor = FetchDescriptor<T>(
            predicate: #Predicate {
                $0.persistentModelID == id
            }
        )
        return (try? modelContext.fetch(descriptor).first) != nil
    }

    
    func isServiceTypeInUse(_ serviceType: ServiceType) -> Bool {
        let typeID = serviceType.persistentModelID
        let descriptor = FetchDescriptor<ServiceRecord>(
            predicate: #Predicate<ServiceRecord>{
                $0.type?.persistentModelID == typeID
            }
        )
        return (try? modelContext.fetch(descriptor))?.isEmpty == false
    }

    func isServiceProviderInUse(_ provider: ServiceProvider) -> Bool {
        let providerID = provider.persistentModelID
        let descriptor = FetchDescriptor<ServiceRecord>(
            predicate: #Predicate {
                $0.provider?.persistentModelID == providerID
            }
        )
        return (try? modelContext.fetch(descriptor))?.isEmpty == false
    }

    func isVehicleInUse(_ vehicle: Vehicle) -> Bool {
        let vehicleID = vehicle.persistentModelID
        let descriptor = FetchDescriptor<ServiceRecord>(
            predicate: #Predicate {
                $0.vehicle?.persistentModelID == vehicleID
            }
        )
        return (try? modelContext.fetch(descriptor))?.isEmpty == false
    }
    
    
    func handleServiceTypeDeleteRequest(_ type: ServiceType) {
        let typeID = type.persistentModelID
        let descriptor = FetchDescriptor<ServiceRecord>(
            predicate: #Predicate {
                $0.type?.persistentModelID == typeID
            }
        )
        if let linkedRecords = try? modelContext.fetch(descriptor), !linkedRecords.isEmpty {
            typeToDelete = type
            showDeleteTypeWarning = true
        } else {
            confirmedTypeToDelete = type
        }
    }
    
    func handleProviderDeleteRequest(_ provider: ServiceProvider) {
        let providerID = provider.persistentModelID
        let descriptor = FetchDescriptor<ServiceRecord>(
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

    func handleVehicleDeleteRequest(_ vehicle: Vehicle) {
        let vehicleID = vehicle.persistentModelID
        let descriptor = FetchDescriptor<ServiceRecord>(
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

    
    func unlinkServiceType(from type: ServiceType) {
        let typeID = type.persistentModelID

        let descriptor = FetchDescriptor<ServiceRecord>(
            predicate: #Predicate {
                $0.type?.persistentModelID == typeID
            }
        )

        if let records = try? modelContext.fetch(descriptor) {
            for record in records {
                record.type = nil
            }
        }
    }

    func unlinkServiceProvider(from provider: ServiceProvider) {
        let providerID = provider.persistentModelID
        let descriptor = FetchDescriptor<ServiceRecord>(
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

    func unlinkVehicle(from vehicle: Vehicle) {
        let vehicleID = vehicle.persistentModelID
        let descriptor = FetchDescriptor<ServiceRecord>(
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

    

    

    func exportCSV() {
        let csv = generateCSV(from: allRecords)
        let filename = "service_export.csv"
        let url = URL.documentsDirectory.appendingPathComponent(filename)
        
        do {
            try csv.write(to: url, atomically: true, encoding: .utf8)
            print("✅ CSV written to: \(url)")

            exportURL = url
            showShareLink = true

        } catch {
            print("❌ Failed to write CSV: \(error)")
        }
    }

    func confirmAndImport(from url: URL) {
        let alert = UIAlertController(title: "Replace Existing Records?",
                                      message: "This will delete all current service records before importing. Continue?",
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Import", style: .destructive) { _ in
            deleteExistingServiceRecords()
            importServiceRecords(from: url)
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = scene.windows.first?.rootViewController {
            root.present(alert, animated: true)
        }
    }
    
    func deleteExistingServiceRecords() {
        let recordDescriptor = FetchDescriptor<ServiceRecord>()
        let vehicleDescriptor = FetchDescriptor<Vehicle>()
        let providerDescriptor = FetchDescriptor<ServiceProvider>()
        let typeDescriptor = FetchDescriptor<ServiceType>()

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

    func importServiceRecords(from url: URL) {
        guard let content = try? String(contentsOf: url, encoding: .utf8) else {
            print("❌ Unable to read CSV file")
            return
        }

        let rows = content.components(separatedBy: .newlines).dropFirst()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        for row in rows {
            let fields = row.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

            guard fields.count >= 10 else {
                print("⚠️ Skipping malformed row: \(row)")
                continue
            }

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

            var vehicle = fetchExistingVehicle(name: vehicleName, year: vehicleYear, vin: vin, license: license)
            
            if vehicle == nil {
                vehicle = Vehicle(name: vehicleName, modelYear: vehicleYear, vin: vin, license: license, currentMileage: mileage)
                modelContext.insert(vehicle!)
            }

            // 🔎 Match or create Provider
            var provider = fetchExitingProvider(name: providerName, contactInfo: contactInfo)
            if provider == nil {
                provider = ServiceProvider(name: providerName, contactInfo: contactInfo)
                modelContext.insert(provider!)
            }

            // 🔎 Match or create Type
            var type = fetchExistingServiceType(name: typeName)
            if type == nil {
                type = ServiceType(name: typeName, suggestedMileage: suggestedMileage)
                modelContext.insert(type!)
            }
            

            // 📝 Create and link the ServiceRecord
            let record = ServiceRecord(vehicle: vehicle!, type: type!, cost: cost, date: date, mileage: mileage)
            record.provider = provider
            modelContext.insert(record)
        }

        try? modelContext.save()
        print("✅ Import complete")
    }



    func fetchExistingVehicle(name: String, year: Int, vin: String, license: String) -> Vehicle? {
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
    
    func fetchExitingProvider(name: String, contactInfo: String) -> ServiceProvider? {
        let descriptor = FetchDescriptor<ServiceProvider>(
            predicate: #Predicate {
                $0.name == name &&
                $0.contactInfo == contactInfo
            }
        )
        return try? modelContext.fetch(descriptor).first
    }

    func fetchExistingServiceType(name rawName: String) -> ServiceType? {
        let normalizedName = rawName.trimmingCharacters(in: .whitespacesAndNewlines)

        let descriptor = FetchDescriptor<ServiceType>(
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
