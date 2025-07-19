//
//  SettingsView.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/13/25.
//
import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext

    @Query var vehicles: [Vehicle]
    @Query var providers: [ServiceProvider]
    @Query var serviceTypes: [ServiceType]

    @State private var showingAddVehicle = false
    @State private var editingVehicle: Vehicle?
    @State private var vehicleToDelete: Vehicle?

    @State private var showingAddProvider = false
    @State private var editingProvider: ServiceProvider?
    @State private var providerToDelete: ServiceProvider?

    @State private var showingAddType = false
    @State private var editingType: ServiceType?
    @State private var typeToDelete: ServiceType?

    var body: some View {
        NavigationStack {
            List {
                // 🚗 Vehicles Section
                Section(header: Text("Vehicles")) {
                    ForEach(vehicles) { vehicle in
                        Button {
                            editingVehicle = vehicle
                        } label: {
                            VStack(alignment: .leading) {
                                Text("\(vehicle.modelYear.description) \(vehicle.name)")
                                Text("Mileage: \(vehicle.currentMileage)")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                vehicleToDelete = vehicle
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }

                    Button("Add Vehicle") {
                        showingAddVehicle = true
                    }
                    .buttonStyle(.borderedProminent)
                }

                // 🏢 Providers Section
                Section(header: Text("Service Providers")) {
                    ForEach(providers) { provider in
                        Button {
                            editingProvider = provider
                        } label: {
                            VStack(alignment: .leading) {
                                Text(provider.name)
//                                Text(provider.contactInfo)
//                                    .font(.footnote)
//                                    .foregroundColor(.secondary)
                            }
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                providerToDelete = provider
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }

                    Button("Add Provider") {
                        showingAddProvider = true
                    }
                    .buttonStyle(.borderedProminent)
                }

                // 🔧 Service Types Section
                Section(header: Text("Service Types")) {
                    ForEach(serviceTypes) { type in
                        Button {
                            editingType = type
                        } label: {
                            Text(type.name)
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                typeToDelete = type
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }

                    Button("Add Service Type") {
                        showingAddType = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle("Settings")
            // Sheets for Editing and Adding
            .sheet(isPresented: $showingAddVehicle) {
                AddVehicleView()
            }
            .sheet(item: $editingVehicle) {
                EditVehicleView(vehicle: $0)
            }
            .sheet(isPresented: $showingAddProvider) {
                AddProviderView()
            }
            .sheet(item: $editingProvider) {
                EditProviderFormView(provider: $0)
            }
            .sheet(isPresented: $showingAddType) {
                AddServiceTypeView()
            }
            .sheet(item: $editingType) {
                EditServiceTypeView(type: $0)
            }
            // Delete Alerts
            .alert("Delete Vehicle?", isPresented: .constant(vehicleToDelete != nil), presenting: vehicleToDelete) { vehicle in
                Button("Delete", role: .destructive) {
                    modelContext.delete(vehicle)
                    try? modelContext.save()
                    vehicleToDelete = nil
                }
                Button("Cancel", role: .cancel) {
                    vehicleToDelete = nil
                }
            } message: { vehicle in
                Text("This will permanently remove \(vehicle.name).")
            }
            .alert("Delete Provider?", isPresented: .constant(providerToDelete != nil), presenting: providerToDelete) { provider in
                Button("Delete", role: .destructive) {
                    modelContext.delete(provider)
                    try? modelContext.save()
                    providerToDelete = nil
                }
                Button("Cancel", role: .cancel) {
                    providerToDelete = nil
                }
            } message: { provider in
                Text("This will permanently remove \(provider.name).")
            }
            .alert("Delete Service Type?", isPresented: .constant(typeToDelete != nil), presenting: typeToDelete) { type in
                Button("Delete", role: .destructive) {
                    modelContext.delete(type)
                    try? modelContext.save()
                    typeToDelete = nil
                }
                Button("Cancel", role: .cancel) {
                    typeToDelete = nil
                }
            } message: { type in
                Text("This will permanently remove \"\(type.name)\" from your list.")
            }
        }
    }
}

#Preview {
     SettingsView()
        .modelContainer(PreviewContainer.shared)
}

