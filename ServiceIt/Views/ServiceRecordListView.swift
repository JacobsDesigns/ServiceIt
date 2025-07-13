//
//  ServiceRecordListView.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/12/25.
//
import SwiftData
import SwiftUI


struct ServiceRecordListView: View {
    @Query var records: [ServiceRecord]
    @State private var searchText = ""

    var filteredRecords: [ServiceRecord] {
        if searchText.isEmpty {
            return records
        } else {
            return records.filter {
                ($0.type?.name ?? "").localizedCaseInsensitiveContains(searchText) ||
                ($0.provider?.name ?? "").description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredRecords) { record in
                    if let provider = record.provider {
                        NavigationLink(destination: ProviderDetailView(provider: provider)) {
                            
                            VStack(alignment: .leading) {
                                Text(record.type?.name ?? "Unknown Service")
                                    .font(.headline)
                                Text("Cost: \(record.cost, format: .currency(code: "USD"))")
                                
                                Text("Provider: \(record.provider?.name ?? "Unknown")")
                                    .font(.footnote).italic()
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    Text("Date: \(record.date.formatted(date: .abbreviated, time: .omitted))")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                
                                Spacer()
                                Text("Miles: \(record.mileage) mi")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                             }
                            }
                            
                        }
                    }
                }
            }
            .listRowSpacing(3)
            .navigationTitle("All Service Records")
            .searchable(text: $searchText)
        }
    }
}
