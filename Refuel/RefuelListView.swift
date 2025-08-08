//
//  RefuelListView.swift
//  ServiceIt
//
//  Created by Jacob Filek on 8/7/25.
//
import SwiftUI
import SwiftData

struct RefuelListView: View {
    
    @Environment(\.modelContext) private var modelContext
    var vehicle: Vehicle
    @Query var allVisits: [RefuelVisit]

    @Binding var sortOption: RecordSortOption
    var selectedYear: Int?

    @State private var searchText = ""
    @State private var showingAddRecord = false
    @State private var showVehicleDetails = false
    @State private var showAddRefuelVisit = false
    @State private var recordToEdit: RefuelVisit?

    var body: some View {
        VStack(spacing: 0) {
            List {
                ForEach(filteredVisits) { visit in
                    let mpg = mpgLookup[visit.id]

                    Button {
                        recordToEdit = visit
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Fuel Cost: \(visit.total, format: .currency(code: "USD"))")
                                .foregroundColor(.gray)
                                
                            HStack {
                                if let mpg = mpg {
                                    Text("MPG: \(String(format: "%.2f", mpg))")
                                        .foregroundColor(mpg < 20 ? .red : .green)
                                } else {
                                    Text("MPG: —")
                                        .foregroundColor(.gray)
                                }

                                Spacer()

                                Text("Gallons: \(visit.gallons, specifier: "%.2f")")
                                        .foregroundColor(.gray)
                            }
                            .font(.caption)


                            Divider()

                            HStack {
                                Text(visit.refuelStation?.name ?? "Unknown Provider")
                                Text(visit.refuelStation?.location ?? "")
                            }
                            .font(.footnote)
                            .italic()
                            .foregroundColor(.secondary)

                            HStack {
                                Text(visit.date.formatted(date: .abbreviated, time: .omitted))
                                Spacer()
                                Text("Mileage: \(visit.odometer)")
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
                    //Text("\(vehicle.name)")
                    Text("Total Cost")
                        .font(.headline)
                    Spacer()
                    Text(totalCost, format: .currency(code: "USD"))
                        .font(.headline)
                }
                .padding()
            }
            
            if !filteredVisits.isEmpty {
                if let avg = averageMPG {
                    HStack {
                        Text("Average MPG")
                            .font(.headline)
                        Spacer()
                        Text(String(format: "%.2f", avg))
                            .font(.headline)
                            .foregroundColor(avg < 20 ? .red : .green)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showVehicleDetails = true
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showAddRefuelVisit = true
                } label: {
                    Label("Add Refuel", systemImage: "fuelpump")
                }
            }

        }
        .sheet(item: $recordToEdit){ visit in
            RefuelVistFormView(vehicle: vehicle, refuelVisitToEdit: visit)
        }
        .sheet(isPresented: $showVehicleDetails) {
            EditVehicleView(vehicle: vehicle)
        }
        .sheet(isPresented: $showAddRefuelVisit){
            RefuelVistFormView(vehicle: vehicle)
        }

    }
}

private extension RefuelListView {
    
    var filteredVisits: [RefuelVisit] {
        let base = allVisits.filter {
            $0.refuelStation != nil &&
            $0.vehicle?.persistentModelID == vehicle.persistentModelID
        }

        let withYear = applyYearFilter(to: base)
        let withSearch = applySearchFilter(to: withYear)
        let sorted = applySorting(to: withSearch)
        return sorted
    }

    func applyYearFilter(to visits: [RefuelVisit]) -> [RefuelVisit] {
        guard let year = selectedYear else { return visits }
        return visits.filter {
            Calendar.current.component(.year, from: $0.date) == year
        }
    }

    func applySearchFilter(to visits: [RefuelVisit]) -> [RefuelVisit] {
        guard !searchText.isEmpty else { return visits }
        return visits.filter {
            let providerMatches = $0.refuelStation?.name.localizedCaseInsensitiveContains(searchText) ?? false
            let yearMatches = String(Calendar.current.component(.year, from: $0.date)).contains(searchText)
            return providerMatches || yearMatches
        }
    }

    func applySorting(to visits: [RefuelVisit]) -> [RefuelVisit] {
        switch sortOption {
        case .dateDescending:     return visits.sorted { $0.date > $1.date }
        case .dateAscending:      return visits.sorted { $0.date < $1.date }
        case .mileageAscending:   return visits.sorted { $0.odometer < $1.odometer }
        case .mileageDescending:  return visits.sorted { $0.odometer > $1.odometer }
        case .costAscending:      return visits.sorted { $0.total < $1.total }
        case .costDescending:     return visits.sorted { $0.total > $1.total }
        }
    }

    var totalCost: Decimal {
        Decimal(filteredVisits.reduce(0) { $0 + $1.total })
    }
    
    var averageMPG: Double? {
        let mpgValues = visitsWithMPG.compactMap { $0.mpg }
        guard !mpgValues.isEmpty else { return nil }
        let total = mpgValues.reduce(0, +)
        return total / Double(mpgValues.count)
    }

    var visitsWithMPG: [(visit: RefuelVisit, mpg: Double?)] {
        let sorted = allVisits
            .filter { $0.vehicle?.id == vehicle.id }
            .sorted { $0.date < $1.date }

        var result: [(RefuelVisit, Double?)] = []
        var previousOdometer: Int?

        for visit in sorted {
            let mpg = visit.mpg(previousOdometer: previousOdometer)
            result.append((visit, mpg))
            previousOdometer = visit.odometer
        }

        return result
    }
    
    var mpgLookup: [PersistentIdentifier: Double] {
        Dictionary(uniqueKeysWithValues: visitsWithMPG.compactMap { pair in
            guard let mpg = pair.mpg else { return nil }
            return (pair.visit.persistentModelID, mpg)
        })
    }


}

#Preview ("Refuel Record List") {
    struct PreviewWrapper: View {
        @State private var sortOption: RecordSortOption = .dateDescending

        var body: some View {
            let container = PreviewContainer.shared
            let context = container.mainContext
            
            //let sortOption: RecordSortOption = .dateDescending
            let vehicle = MockData.allVehicles().first!

            let visit =  RefuelVisit(
                    odometer: 12500,
                    date: Calendar.current.date(byAdding: .day, value: -30, to: Date())!,
                    gallons: 13.5,
                    costPerGallon: 5.39,
                    total: (13.5 * 5.39),
                    vehicle: vehicle,
                    refuelStation: RefuelStation(name: "Chevron", location: "")
                )
            
            context.insert(vehicle)
            context.insert(visit)
            
           return RefuelListView(vehicle: vehicle, sortOption: $sortOption)
                .modelContainer(container)
            
        }
    }
    
    return PreviewWrapper()
}
