//
//  ServiceRecordListView.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/12/25.
//
import SwiftUI
import SwiftData

struct ServiceVisitListView: View {
    @Environment(\.modelContext) private var modelContext
    var vehicle: Vehicle
    @Query var allVisits: [ServiceVisit]

    @Binding var sortOption: RecordSortOption
    var selectedYear: Int?

    @State private var searchText = ""
    @State private var showingAddRecord = false
    @State private var recordToEdit: ServiceVisit?

    var body: some View {
        VStack(spacing: 0) {
            List {
                ForEach(filteredVisits) { visit in
                    Button {
                        recordToEdit = visit
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    ForEach(visit.savedItems) { item in
                                        Text(item.name)
                                            .font(.headline)
                                    }
                                }

                                Spacer()

                                Text(visit.provider?.name ?? "Unknown Provider")
                                    .font(.footnote)
                                    .italic()
                                    .foregroundColor(.secondary)
                            }

                            Text("Cost: \(visit.cost, format: .currency(code: "USD"))")

                            HStack {
                                Text(visit.date.formatted(date: .abbreviated, time: .omitted))
                                Spacer()
                                Text("Mileage: \(visit.mileage)")
                            }
                            .font(.footnote)
                            .foregroundColor(.gray)
                        }
                    }
                }
            }
            .listRowSpacing(4)
            .searchable(text: $searchText)

            if !filteredVisits.isEmpty {
                HStack {
                    Text("Total Cost")
                        .font(.headline)
                    Spacer()
                    Text(totalCost, format: .currency(code: "USD"))
                        .font(.headline)
                }
                .padding()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddRecord = true
                } label: {
                    Label("Add Record", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddRecord) {
            ServiceVisitFormView(preselectedVehicle: vehicle)
        }
        .sheet(item: $recordToEdit) { visit in
            ServiceVisitFormView(visitToEdit: visit)
        }
//        .onAppear {
//        for visit in allVisits {
//            print("--- Visit ---")
//            print("Vehicle ID: \(visit.vehicle?.persistentModelID)")
//            print("View vehicle ID: \(vehicle.persistentModelID)")
//            print("Provider exists: \(visit.provider != nil)")
//            print("Items count: \(visit.items.count)")
//            print("Filter valid? \(filterValidVisits([visit]).isEmpty ? "❌" : "✅")")
//            print("Year match? \(applyYearFilter(to: [visit]).isEmpty ? "❌" : "✅")")
//            print("Search match? \(applySearchFilter(to: [visit]).isEmpty ? "❌" : "✅")")
//        }
//    }

    }
}

private extension ServiceVisitListView {
    
    var filteredVisits: [ServiceVisit] {
        allVisits.filter { visit in
            visit.provider != nil &&
            visit.vehicle?.persistentModelID == vehicle.persistentModelID //&&
            //(!visit.items.isEmpty)// || visit.notes?.isEmpty == false)
        }
    }

//    var filteredVisits: [ServiceVisit] {
//        allVisits.filter { visit in
//            visit.provider != nil &&
//            visit.vehicle?.persistentModelID == vehicle.persistentModelID &&
//            !visit.items.isEmpty
//        }
//    }

//    var filteredVisits: [ServiceVisit] {
//        applySorting(
//            to: applySearchFilter(
//                to: applyYearFilter(
//                    to: filterValidVisits(allVisits)
//                )
//            )
//        )
//    }

    func filterValidVisits(_ visits: [ServiceVisit]) -> [ServiceVisit] {
        visits.filter {
            !$0.savedItems.isEmpty &&
            $0.provider != nil &&
            $0.vehicle?.persistentModelID == vehicle.persistentModelID
        }
    }

    func applyYearFilter(to visits: [ServiceVisit]) -> [ServiceVisit] {
        guard let year = selectedYear else { return visits }
        return visits.filter {
            Calendar.current.component(.year, from: $0.date) == year
        }
    }

    func applySearchFilter(to visits: [ServiceVisit]) -> [ServiceVisit] {
        guard !searchText.isEmpty else { return visits }
        return visits.filter {
            let itemMatches = $0.savedItems.contains {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
            let providerMatches = $0.provider?.name.localizedCaseInsensitiveContains(searchText) ?? false
            let yearMatches = String(Calendar.current.component(.year, from: $0.date)).contains(searchText)
            return itemMatches || providerMatches || yearMatches
        }
    }

    func applySorting(to visits: [ServiceVisit]) -> [ServiceVisit] {
        switch sortOption {
        case .dateDescending:     return visits.sorted { $0.date > $1.date }
        case .dateAscending:      return visits.sorted { $0.date < $1.date }
        case .mileageAscending:   return visits.sorted { $0.mileage < $1.mileage }
        case .mileageDescending:  return visits.sorted { $0.mileage > $1.mileage }
        case .costAscending:      return visits.sorted { $0.cost < $1.cost }
        case .costDescending:     return visits.sorted { $0.cost > $1.cost }
        }
    }

    var totalCost: Decimal {
        Decimal(filteredVisits.reduce(0) { $0 + $1.cost })
    }
}

#Preview("Service Record List") {
    struct PreviewWrapper: View {
        @State private var sortOption: RecordSortOption = .dateDescending

        var body: some View {
            let container = PreviewContainer.shared
            let context = container.mainContext

            let vehicle = Vehicle(name: "Preview Car", modelYear: 2011, vin: "W", license: "6TLS", currentMileage: 120000)
            let provider = ServiceProvider(name: "Preview Shop", contactInfo: "")
            let item = SavedServiceItem(name: "Oil Change", cost: 54)

            let visit = ServiceVisit(
                date: Date(),
                mileage: 12345,
                cost: 89.99,
                notes: "Routine service",
                photoData: nil,
                vehicle: vehicle,
                provider: provider,
                savedItems: [item]
            )

            context.insert(vehicle)
            context.insert(provider)
            context.insert(item)
            context.insert(visit)

            return ServiceVisitListView(vehicle: vehicle, sortOption: $sortOption)
                .modelContainer(container)
        }
    }

    return PreviewWrapper()
}

//struct ServiceVisitListView: View {
//    @Environment(\.modelContext) private var modelContext
//    var vehicle: Vehicle
//    @Query var allVisits: [ServiceVisit]
//
//    @State private var searchText = ""
//    @Binding var sortOption: RecordSortOption
//    var selectedYear: Int?
//
//    @State private var showingAddRecord = false
//    @State private var recordToEdit: ServiceVisit?
//
//    var filteredVisits: [ServiceVisit] {
//        
//
//        
//        let validVisits = allVisits.filter {
//            !$0.items.isEmpty && $0.provider != nil && $0.vehicle != nil
//        }
//
//        let vehicleRecords = validVisits.filter {
//            $0.vehicle?.id == vehicle.id
//        }
//
//        let yearFiltered = selectedYear == nil ? vehicleRecords : vehicleRecords.filter {
//            Calendar.current.component(.year, from: $0.date) == selectedYear
//        }
//
//        let searched = searchText.isEmpty ? yearFiltered : yearFiltered.filter {
//            let itemMatches = $0.items.contains {
//                $0.name.localizedCaseInsensitiveContains(searchText)
//            }
//            let providerMatches = $0.provider?.name.localizedCaseInsensitiveContains(searchText) ?? false
//            let yearMatches = String(Calendar.current.component(.year, from: $0.date)).contains(searchText)
//            return itemMatches || providerMatches || yearMatches
//        }
//
//        switch sortOption {
//        case .dateDescending:     return searched.sorted { $0.date > $1.date }
//        case .dateAscending:      return searched.sorted { $0.date < $1.date }
//        case .mileageAscending:   return searched.sorted { $0.mileage < $1.mileage }
//        case .mileageDescending:  return searched.sorted { $0.mileage > $1.mileage }
//        case .costAscending:      return searched.sorted { $0.cost < $1.cost }
//        case .costDescending:     return searched.sorted { $0.cost > $1.cost }
//        }
//    }
//
//    var totalCost: Decimal {
//        Decimal(filteredVisits.reduce(0) { $0 + $1.cost })
//    }
//
//    var body: some View {
//        
//        VStack(spacing: 0) {
//            List {
//                ForEach(filteredVisits) { visit in
//                    Button {
//                        recordToEdit = visit
//                    } label: {
//                        VStack(alignment: .leading, spacing: 6) {
//                            HStack {
//                                VStack(alignment: .leading, spacing: 2) {
//                                    ForEach(visit.items) { item in
//                                        if isValidItem(item) {
//                                            Text(item.name)
//                                                .font(.headline)
//                                        }
//                                    }
//                                }
//
//                                Spacer()
//
//                                Text(visit.provider?.name ?? "Unknown Provider")
//                                    .font(.footnote)
//                                    .italic()
//                                    .foregroundColor(.secondary)
//                            }
//
//                            Text("Cost: \(visit.cost, format: .currency(code: "USD"))")
//
//                            HStack {
//                                Text(visit.date.formatted(date: .abbreviated, time: .omitted))
//                                Spacer()
//                                Text("Mileage: \(visit.mileage)")
//                            }
//                            .font(.footnote)
//                            .foregroundColor(.gray)
//                        }
//                    }
//                }
//            }
//            .listRowSpacing(4)
//            .searchable(text: $searchText)
//
//            if !filteredVisits.isEmpty {
//                
//                HStack {
//                    Text("Total Cost")
//                        .font(.headline)
//                    Spacer()
//                    Text(totalCost, format: .currency(code: "USD"))
//                        .font(.headline)
//                }
//                .padding()
//            }
//        }
//        .toolbar {
//            ToolbarItem(placement: .navigationBarTrailing) {
//                Button {
//                    showingAddRecord = true
//                } label: {
//                    Label("Add Record", systemImage: "plus")
//                }
//            }
//        }
//        .sheet(isPresented: $showingAddRecord) {
//            ServiceVisitFormView(preselectedVehicle: vehicle)
//        }
//        .sheet(item: $recordToEdit) { visit in
//            ServiceVisitFormView(visitToEdit: visit)//(recordToEdit: record, vehicle: vehicle)
//        }
//        .onAppear {
//            print("All visits fetched: \(allVisits.count)")
//            allVisits.forEach { print("Visit vehicle: \($0.vehicle?.name ?? "nil")") }
//        }
//
//    }
//
//    func isValidItem(_ item: ServiceItem) -> Bool {
//        let itemID = item.persistentModelID
//        let descriptor = FetchDescriptor<ServiceItem>(
//            predicate: #Predicate { $0.persistentModelID == itemID }
//        )
//        return (try? modelContext.fetch(descriptor).first) != nil
//    }
//}
//
//
//#Preview("Service Record List") {
//    struct PreviewWrapper: View {
//        @State private var sortOption: RecordSortOption = .dateDescending
//
//        var body: some View {
//            ServiceVisitListView(vehicle: MockData.allVehicles().first!, sortOption: $sortOption)
//                .modelContainer(PreviewContainer.shared)
//        }
//    }
//
//    return PreviewWrapper()
//}
