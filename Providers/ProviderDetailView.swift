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
    @State private var showingEditProviderForm = false
    @State private var recordToEdit: ServiceRecord?

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                HeaderSection(provider: provider)

                if provider.records.isEmpty {
                    Text("No service records yet.")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    RecordList(records: provider.records, onEdit: { record in
                        recordToEdit = record
                    })
                }

                Spacer()

                ActionButtons(
                    showingAddForm: $showingAddForm,
                    showingEditProviderForm: $showingEditProviderForm
                )
            }
            .padding()
            .navigationTitle("Provider Details")
            .sheet(isPresented: $showingAddForm) {
                ServiceRecordFormView()
            }
            .sheet(item: $recordToEdit) { record in
                ServiceRecordFormView(recordToEdit: record)
            }
            .sheet(isPresented: $showingEditProviderForm) {
                EditProviderFormView(provider: provider)
            }
        }
    }
}

private struct HeaderSection: View {
    let provider: ServiceProvider

    var body: some View {
        VStack(alignment: .leading) {
            Text(provider.name)
                .font(.title2)
            Text(provider.contactInfo)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct RecordList: View {
    let records: [ServiceRecord]
    let onEdit: (ServiceRecord) -> Void

    var body: some View {
        List {
            ForEach(records) { record in
                RecordRow(record: record)
                    .onTapGesture { onEdit(record) }
            }
        }
        .listRowSpacing(3)
    }
}

private struct RecordRow: View {
    let record: ServiceRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(record.type?.name ?? "Unknown Service")
                .font(.headline)
            Text("Cost: $\(record.cost, specifier: "%.2f")")
                .foregroundColor(.green)
            HStack {
                Text("Date: \(record.date.formatted(date: .abbreviated, time: .omitted))")
                Spacer()
                Text("Miles: \(record.mileage, format: .number.grouping(.automatic))")
            }
            .font(.footnote)
            .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}

private struct ActionButtons: View {
    @Binding var showingAddForm: Bool
    @Binding var showingEditProviderForm: Bool

    var body: some View {
        VStack(spacing: 10) {
            Button("Add Service Record") {
                showingAddForm = true
            }
            .buttonStyle(.borderedProminent)

            Button("Edit Provider Info") {
                showingEditProviderForm = true
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
