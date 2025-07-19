//
//  MainView.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/13/25.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @Query var vehicles: [Vehicle]
    @Environment(\.modelContext) private var modelContext

    @State private var selectedVehicle: Vehicle?
    @State private var showingAddVehicleForm = false

    var body: some View {
        TabView {
            NavigationStack {
                if vehicles.isEmpty {
                    VStack(spacing: 20) {
                        Text("No vehicles available.")
                            .foregroundColor(.secondary)
                            .padding()

                        Button("Add Vehicle") {
                            showingAddVehicleForm = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .navigationTitle("Your Vehicles")
                } else {
                    VStack {
                        Picker("Select Vehicle", selection: $selectedVehicle) {
                            ForEach(vehicles) { vehicle in
                                Text("\(String(vehicle.modelYear)) \(vehicle.name)").tag(vehicle as Vehicle?)
                            }
                        }
                        .pickerStyle(.menu)
                        .padding(.horizontal)

                        if let vehicle = selectedVehicle {
                            VehicleDetailView(vehicle: vehicle)
                        } else {
                            Text("Select a vehicle to view details")
                                .foregroundColor(.secondary)
                        }
                    }
                    .navigationTitle("Vehicle Info")
                }
            }
            .tabItem {
                Label("Car", systemImage: "car")
            }
            .sheet(isPresented: $showingAddVehicleForm) {
                AddVehicleView()
            }

            NavigationStack {
                if let vehicle = selectedVehicle {
                    ServiceRecordsView(vehicle: vehicle)
                } else {
                    Text("Please select a vehicle to view service records.")
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
            .tabItem {
                Label("Service Records", systemImage: "list.bullet")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
        }
        .task {
            if vehicles.isEmpty {
                MockData.allVehicles().forEach { modelContext.insert($0) }
                MockData.allProviders().forEach { modelContext.insert($0) }
                MockData.allServiceTypes().forEach { modelContext.insert($0) }
                MockData.allRecords().forEach { modelContext.insert($0) }
                try? modelContext.save()
                print("🧪 Seeded mock data into live context")
            }

            if selectedVehicle == nil {
                selectedVehicle = vehicles.first
            }
        }

//        .task {
//            if selectedVehicle == nil {
//                selectedVehicle = vehicles.first
//            }
//        }
    }
}

#Preview{
    MainView()
        .modelContainer(PreviewContainer.shared)
}


