//
//  ProviderDetailView.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/12/25.
//


import SwiftUI
import SwiftData

struct ProviderDetailView: View {
    
    @Bindable var provider: ServiceProvider
    @State private var showingAddForm = false
    @State private var editingRecord: ServiceRecord?
    @State private var showingEditProviderForm = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                headerSection

                if provider.records.isEmpty {
                    Text("No service records yet.")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    recordList
                }

                Spacer()

                HStack {
                    Button("Add Service Record") {
                        showingAddForm = true
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.bottom)
                    
                    Button ("Edit Provider"){
                        showingEditProviderForm = true
                    }
                    .sheet(isPresented: $showingEditProviderForm) {
                        EditProviderFormView(provider: provider)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.bottom)
                }
            }
            .padding()
            .navigationTitle("Details")
            .sheet(isPresented: $showingAddForm) {
                ServiceRecordFormView(provider: provider)
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(provider.name)
                .font(.body)
//            Text(provider.contactInfo)
//                .font(.subheadline)
//                .foregroundColor(.secondary)
        }
    }

    private var recordList: some View {
        List {
            ForEach(provider.records) { record in
                recordRow(for: record)
                    .onTapGesture {
                        editingRecord = record
                    }
            }

        }
        .listRowSpacing(3)//.listStyle(.plain)
        .sheet(item: $editingRecord) { record in
            ServiceRecordFormView(provider: provider, editingRecord: record)
        }
    }

    private func recordRow(for record: ServiceRecord) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(record.type?.name ?? "Unknown Service")
                .font(.headline)
            Text("Cost: $\(record.cost, specifier: "%.2f")")
                .foregroundColor(.green)
            HStack {
                Text("Date: \(record.date.formatted(date: .abbreviated, time: .omitted))")
                    .foregroundColor(.gray)
                    .font(.footnote)
                Spacer()
                Text("Miles: \(record.mileage, format: .number.grouping(.automatic))")
                    .foregroundColor(.gray)
                    .font(.footnote)
            }
        }
        .padding(.vertical, 2)
    }// end recordRow
    
}


#Preview {
    ProviderDetailView(
        provider: ServiceProvider(
            name: "Quick Auto Care",
            contactInfo: "123-456-7890",
            records: [
                ServiceRecord(
                    type: ServiceType(name: "Tire Rotation"),
                    cost: 49.99,
                    date: Date(),
                    mileage: 10000
                ),
                
                ServiceRecord(
                    type: ServiceType(name: "Tire Rotation"),
                    cost: 49.99,
                    date: Date(),
                    mileage: 10000
                )
                
            ]
        )
    )
}

