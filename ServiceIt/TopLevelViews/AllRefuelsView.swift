//
//  AllRefuelsView.swift
//  ServiceIt
//
//  Created by Jacob Filek on 8/7/25.
//

import SwiftUI
import SwiftData

struct AllRefuelsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query var allVehicles: [Vehicle]
    @Query var allVisits: [RefuelVisit] = []
    @State private var selectedVehicle: Vehicle?
    @State private var sortOption: RecordSortOption = .dateDescending
    @State private var selectedYear: Int? = nil

    var body: some View {

        let availableYears: [Int] = Array(Set(allVisits.map {
            Calendar.current.component(.year, from: $0.date)
        })).sorted(by: >)

        NavigationStack {
                VStack(spacing: 2) {
                    HStack(spacing: 12) {
                        
                        Picker("Vehicle", selection: $selectedVehicle) {
                            Text("Vehicle").tag(nil as Vehicle?)
                            ForEach(allVehicles) {
                                Text("\($0.name)").tag(Optional($0))
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(maxWidth: .infinity)

 
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

                    
                    if let vehicle = selectedVehicle {
                        RefuelListView(
                            vehicle: vehicle,
                            sortOption: $sortOption,
                            selectedYear: selectedYear
                        )
                        
                    } else {
                        Text("Select a vehicle to view its records.")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                }
            Spacer()
            .navigationTitle("Refuel Records")
            
            // Auto-select logic
            .onAppear(perform: autoSelectIfSingle)
            .onChange(of: allVehicles) { autoSelectIfSingle() }
        }
    }

    private func autoSelectIfSingle() {
        if allVehicles.count == 1 {
            selectedVehicle = allVehicles.first
        } else if let selected = selectedVehicle {
            // Clear selection if the previously selected vehicle no longer exists
            let stillExists = allVehicles.contains { $0.persistentModelID == selected.persistentModelID }
            if !stillExists {
                selectedVehicle = nil
            }
        }
    }
}



#Preview {
    AllRefuelsView()
        .modelContainer(PreviewContainer.shared)
}
