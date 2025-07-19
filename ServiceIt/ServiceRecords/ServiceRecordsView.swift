//
//  ServiceRecordListViewForVehicle.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/18/25.
//


import SwiftUI
import SwiftData

struct ServiceRecordsView: View {
    var vehicle: Vehicle

    @Query var allRecords: [ServiceRecord]
    @State private var searchText = ""
    @State private var sortOption: RecordSortOption = .dateDescending
    @State private var showingAddRecord = false
    @State private var recordToEdit: ServiceRecord?

    var filteredRecords: [ServiceRecord] {
        let base = allRecords.filter { $0.vehicle?.id == vehicle.id }

        let searched = searchText.isEmpty
            ? base
            : base.filter {
                ($0.type?.name ?? "").localizedCaseInsensitiveContains(searchText) ||
                ($0.provider?.name ?? "").localizedCaseInsensitiveContains(searchText)
            }

        switch sortOption {
        case .dateDescending:
            return searched.sorted { $0.date > $1.date }
        case .dateAscending:
            return searched.sorted { $0.date < $1.date }
        case .mileageAscending:
            return searched.sorted { $0.mileage < $1.mileage }
        case .mileageDescending:
            return searched.sorted { $0.mileage > $1.mileage }
        case .costAscending:
            return searched.sorted { $0.cost < $1.cost }
        case .costDescending:
            return searched.sorted { $0.cost > $1.cost }
        }
    }

    var body: some View {
        List {
            Picker("Sort By", selection: $sortOption) {
                ForEach(RecordSortOption.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .padding(.vertical)

            ForEach(filteredRecords) { record in
                Button {
                    recordToEdit = record
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(record.type?.name ?? "Unknown Service")
                                .font(.headline)
                            Spacer()
                            Text("Provider: \(record.provider?.name ?? "Unknown")")
                                .font(.footnote).italic()
                                .foregroundColor(.secondary)
                        }

                        Text("Cost: \(record.cost, format: .currency(code: "USD"))")

                        HStack {
                            Text("Date: \(record.date.formatted(date: .abbreviated, time: .omitted))")
                            Spacer()
                            Text("Mileage: \(record.mileage)")
                        }
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Service History")
        .searchable(text: $searchText)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddRecord = true }) {
                    Label("Add Record", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddRecord) {
            ServiceRecordFormView(vehicleMileage: vehicle.currentMileage)
        }
        .sheet(item: $recordToEdit) { record in
            ServiceRecordFormView(recordToEdit: record, vehicleMileage: vehicle.currentMileage)
        }
    }
}

#Preview {
    ServiceRecordsView(vehicle: MockData.vehicle1)
        .modelContainer(PreviewContainer.shared)
}
