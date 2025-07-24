//
//  ServiceScheduleView.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/19/25.
//
import SwiftUI
import SwiftData
import Charts

struct ServiceScheduleView: View {
    @Query var allRecords: [ServiceRecord]
    @Query var allVehicles: [Vehicle]
    @Query var allServiceTypes: [ServiceType]
    
    @State private var selectedVehicle: Vehicle?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    
                    Picker("Vehicle", selection: $selectedVehicle) {
                        Text("Vehicle").tag(nil as Vehicle?)
                        ForEach(allVehicles) {
                            Text("\($0.plainModelYearString) \($0.name)").tag(Optional($0))
                        }
                    }
                    .pickerStyle(.menu)
                    .onAppear {
                        if allVehicles.count == 1 {
                            selectedVehicle = allVehicles.first
                        }
                    }
                    
                    // 🔍 Contextual Schedule
                    if let selectedVehicle {
                        let vehicleRecords = allRecords.filter {
                            $0.vehicle?.id == selectedVehicle.id
                        }

                        // 📅 Upcoming Reminders
                        UpcomingServiceSection(vehicle: selectedVehicle, serviceTypes: allServiceTypes)

                        Divider()

                        // 📊 Service Summary Dashboard
                        ServiceSummarySection(records: vehicleRecords)

                        Divider()

                        // 🔧 Predictive Maintenance
                        PredictiveInsightsSection(records: vehicleRecords)
                    } else {
                        Text("Select a vehicle to view its service schedule.")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                }
            }
            .navigationTitle("Service Schedule")
        }
    }
}

#Preview("Service Schedule") {
    struct PreviewWrapper: View {
        var body: some View {
            ServiceScheduleView()
                .modelContainer(PreviewContainer.shared)
        }
    }
    
    return PreviewWrapper()
}
