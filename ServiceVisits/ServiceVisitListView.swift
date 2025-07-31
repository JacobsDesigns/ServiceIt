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

                               
                            }

                            Text("Cost: \(visit.total, format: .currency(code: "USD"))")
                                .foregroundColor(.gray)
                            //Spacer()
                            Divider()
                            Text(visit.provider?.name ?? "Unknown Provider")
                                .font(.footnote)
                                .italic()
                                .foregroundColor(.secondary)
                            
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
                    Text("\(vehicle.name)")
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
//            //print("Vehicle ID: \(visit.vehicle?.persistentModelID)")
//            print("View vehicle ID: \(vehicle.persistentModelID)")
//            print("Provider exists: \(visit.provider != nil)")
//            print("Items count: \(visit.savedItems.count)")
//            print("Filter valid? \(filterValidVisits([visit]).isEmpty ? "❌" : "✅")")
//            print("Year match? \(applyYearFilter(to: [visit]).isEmpty ? "❌" : "✅")")
//            print("Search match? \(applySearchFilter(to: [visit]).isEmpty ? "❌" : "✅")")
//        }
//    }

    }
}

private extension ServiceVisitListView {
    
    var filteredVisits: [ServiceVisit] {
        let base = allVisits.filter {
            $0.provider != nil &&
            $0.vehicle?.persistentModelID == vehicle.persistentModelID
        }

        let withYear = applyYearFilter(to: base)
        let withSearch = applySearchFilter(to: withYear)
        let sorted = applySorting(to: withSearch)
        return sorted
    }

//    var filteredVisits: [ServiceVisit] {
//        allVisits.filter { visit in
//            visit.provider != nil &&
//            visit.vehicle?.persistentModelID == vehicle.persistentModelID //&&
//            //(!visit.items.isEmpty)// || visit.notes?.isEmpty == false)
//        }
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
                cost: 50.99,
                tax : 1.01,
                total: 51.00,
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
