//
//  AllRecordsView.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/19/25.


import SwiftUI
import SwiftData

struct AllRecordsView: View {
    @Query var allVehicles: [Vehicle]
    @Query var allRecords: [ServiceRecord]
    @State private var selectedVehicle: Vehicle?
    @State private var sortOption: RecordSortOption = .dateDescending
    @State private var selectedYear: Int? = nil

    var body: some View {

        let availableYears: [Int] = Array(Set(allRecords.map {
            Calendar.current.component(.year, from: $0.date)
        })).sorted(by: >)

        NavigationStack {
                VStack(spacing: 2) {
                    HStack(spacing: 12) {
                        
                        Picker("Vehicle", selection: $selectedVehicle) {
                            Text("Vehicle").tag(nil as Vehicle?)
                            ForEach(allVehicles) {
                                Text("\($0.plainModelYearString) \($0.name)").tag(Optional($0))
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity)
                        .onAppear {
                            if allVehicles.count == 1 {
                                selectedVehicle = allVehicles.first
                            }
                            
                            print("all Records: \(allRecords.count)")
                            print("all Vehicles: \(allVehicles.count)")
                            print("available Years: \(availableYears)")
                        }
                        
                        Picker("Sort", selection: $sortOption) {
                            ForEach(RecordSortOption.allCases) {
                                Text($0.rawValue).tag($0)
                            }
                        }
                        .pickerStyle(.menu)
                        .layoutPriority(1)
                        
                        Picker("Year", selection: $selectedYear) {
                            Text("All").tag(nil as Int?)
                            ForEach(availableYears, id: \.self) {
                                Text(String($0)).tag(Optional($0))
                            }
                        }
                        .pickerStyle(.menu)
                        .layoutPriority(1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .onAppear {
                        for record in allRecords {
                           print("Record date: \(record.date)")
                        }
                    }
                    
                    if let vehicle = selectedVehicle {
                        ServiceVisitListView(
                            vehicle: vehicle,
                            sortOption: $sortOption,
                            selectedYear: selectedYear
                        )
                    } else {
                        Text("Select a vehicle to view its service records.")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                }
            Spacer()
            .navigationTitle("Service Records")
        }
    }
        
}



#Preview {
    AllRecordsView()
        .modelContainer(PreviewContainer.shared)
}
