//
//  ServiceRecordListView.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/12/25.
//
import SwiftUI
import SwiftData

struct ServiceRecordListView: View {
    @Environment(\.modelContext) private var modelContext
    var vehicle: Vehicle
    @Query var allRecords: [ServiceRecord]

    @State private var searchText = ""
    @Binding var sortOption: RecordSortOption
    var selectedYear: Int?

    @State private var showingAddRecord = false
    @State private var recordToEdit: ServiceRecord?
    
    var filteredRecords: [ServiceRecord] {
        let validRecords = allRecords.filter {
            $0.type != nil && $0.provider != nil && $0.vehicle != nil
        }

        let vehicleRecords = validRecords.filter {
            $0.vehicle?.id == vehicle.id
        }

        let yearFiltered = selectedYear == nil ? vehicleRecords : vehicleRecords.filter {
            Calendar.current.component(.year, from: $0.date) == selectedYear
        }

        let searched = searchText.isEmpty ? yearFiltered : yearFiltered.filter {
            guard let typeName = $0.type?.name,
                  let providerName = $0.provider?.name else { return false }

            return typeName.localizedCaseInsensitiveContains(searchText) ||
                   providerName.localizedCaseInsensitiveContains(searchText) ||
                   String(Calendar.current.component(.year, from: $0.date)).contains(searchText)
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

                                if let type = record.type, isValidType(type) {
                                    Text(type.name)
                                        .font(.headline)
                                } else {
                                    Text("Unknown Service")
                                        .font(.headline)
                                }

                                Spacer()
                                
                                if let provider = record.provider {
                                    Text(provider.name)
                                        .font(.footnote)
                                        .italic()
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("Unknown Provider")
                                        .font(.footnote)
                                }
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
            ServiceRecordFormView(vehicle: vehicle)
        }
        .sheet(item: $recordToEdit) { record in
            ServiceRecordFormView(recordToEdit: record, vehicle: vehicle)
        }
    }

    func isValidType(_ type: ServiceType?) -> Bool {
        guard let type else { return false }
        let typeID = type.persistentModelID
        let descriptor = FetchDescriptor<ServiceType>(
            predicate: #Predicate { $0.persistentModelID == typeID }
        )
        return (try? modelContext.fetch(descriptor).first) != nil
    }

    
}

#Preview("Service Record List") {
    struct PreviewWrapper: View {
        @State private var sortOption: RecordSortOption = .dateDescending

        var body: some View {
            ServiceRecordListView(vehicle: MockData.vehicle1, sortOption: $sortOption)
                .modelContainer(PreviewContainer.shared)
        }
    }

    return PreviewWrapper()
}
