//
//  MainView.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/13/25.
//
import SwiftUI
import SwiftData

struct GarageView: View {
    @Query var vehicles: [Vehicle]
    @State private var showingAddVehicleForm = false
    @State private var sortOption: RecordSortOption = .dateDescending
    
    var body: some View {
        NavigationStack {
            VStack {
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
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(vehicles) { vehicle in
                                NavigationLink(value: vehicle) {
                                    VehicleSummaryCard(vehicle: vehicle)
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top)
                    }
                }
            }
            .navigationDestination(for: Vehicle.self) { vehicle in
                ServiceRecordListView(vehicle: vehicle, sortOption: $sortOption)
            }
            .navigationTitle("My Garage")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddVehicleForm = true
                    } label: {
                        Label("Add Vehicle", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddVehicleForm) {
                AddVehicleView()
            }
        }
    }
}

#Preview {
    GarageView()
        .modelContainer(PreviewContainer.shared)
}

