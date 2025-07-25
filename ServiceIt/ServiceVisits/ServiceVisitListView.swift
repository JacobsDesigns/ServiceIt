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

    @State private var searchText = ""
    @Binding var sortOption: RecordSortOption
    var selectedYear: Int?

    @State private var showingAddRecord = false
    @State private var recordToEdit: ServiceVisit?

    var filteredRecords: [ServiceVisit] {
        let validRecords = allVisits.filter {
            !$0.items.isEmpty && $0.provider != nil && $0.vehicle != nil
        }

        let vehicleRecords = validRecords.filter {
            $0.vehicle?.id == vehicle.id
        }

        let yearFiltered = selectedYear == nil ? vehicleRecords : vehicleRecords.filter {
            Calendar.current.component(.year, from: $0.date) == selectedYear
        }

        let searched = searchText.isEmpty ? yearFiltered : yearFiltered.filter {
            let itemMatches = $0.items.contains {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
            let providerMatches = $0.provider?.name.localizedCaseInsensitiveContains(searchText) ?? false
            let yearMatches = String(Calendar.current.component(.year, from: $0.date)).contains(searchText)
            return itemMatches || providerMatches || yearMatches
        }

        switch sortOption {
        case .dateDescending:     return searched.sorted { $0.date > $1.date }
        case .dateAscending:      return searched.sorted { $0.date < $1.date }
        case .mileageAscending:   return searched.sorted { $0.mileage < $1.mileage }
        case .mileageDescending:  return searched.sorted { $0.mileage > $1.mileage }
        case .costAscending:      return searched.sorted { $0.cost < $1.cost }
        case .costDescending:     return searched.sorted { $0.cost > $1.cost }
        }
    }

    var totalCost: Decimal {
        Decimal(filteredRecords.reduce(0) { $0 + $1.cost })
    }

    var body: some View {
        VStack(spacing: 0) {
            List {
                ForEach(filteredRecords) { record in
                    Button {
                        recordToEdit = record
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    ForEach(record.items) { item in
                                        if isValidItem(item) {
                                            Text(item.name)
                                                .font(.headline)
                                        }
                                    }
                                }

                                Spacer()

                                Text(record.provider?.name ?? "Unknown Provider")
                                    .font(.footnote)
                                    .italic()
                                    .foregroundColor(.secondary)
                            }

                            Text("Cost: \(record.cost, format: .currency(code: "USD"))")

                            HStack {
                                Text(record.date.formatted(date: .abbreviated, time: .omitted))
                                Spacer()
                                Text("Mileage: \(record.mileage)")
                            }
                            .font(.footnote)
                            .foregroundColor(.gray)
                        }
                    }
                }
            }
            .listRowSpacing(4)
            .searchable(text: $searchText)

            if !filteredRecords.isEmpty {
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
            ServiceVisitFormView()//(vehicle: vehicle)
        }
        .sheet(item: $recordToEdit) { record in
            ServiceVisitFormView()//(recordToEdit: record, vehicle: vehicle)
        }
    }

    func isValidItem(_ item: ServiceItem) -> Bool {
        let itemID = item.persistentModelID
        let descriptor = FetchDescriptor<ServiceItem>(
            predicate: #Predicate { $0.persistentModelID == itemID }
        )
        return (try? modelContext.fetch(descriptor).first) != nil
    }
}


#Preview("Service Record List") {
    struct PreviewWrapper: View {
        @State private var sortOption: RecordSortOption = .dateDescending

        var body: some View {
            ServiceVisitListView(vehicle: MockData.allVehicles().first!, sortOption: $sortOption)
                .modelContainer(PreviewContainer.shared)
        }
    }

    return PreviewWrapper()
}
