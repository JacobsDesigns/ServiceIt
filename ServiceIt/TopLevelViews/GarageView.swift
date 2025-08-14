//
//  MainView.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/13/25.
//
import SwiftUI
import SwiftData

struct GarageView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query var vehicles: [Vehicle]
    @State private var showingAddVehicleForm = false
    @State private var sortOption: RecordSortOption = .dateDescending
    @State private var longPressedVehicle: Vehicle?
    @State private var tempOdometer: String = ""
    @State private var showAddItemOverlay = false
    @State private var showAddRefuelVisit = false
    
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
                                        .onLongPressGesture {
                                            longPressedVehicle = vehicle
                                            showAddItemOverlay = true
                                        }
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
                ServiceVisitListView(vehicle: vehicle, sortOption: $sortOption)
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
//            .sheet(item: $longPressedVehicle) { vehicle in
//                RefuelVistFormView(vehicle: vehicle)
//            }
//            .sheet(item: $longPressedVehicle) { vehicle in
//                EditVehicleView(vehicle: vehicle)
//            }
//                    .presentationDetents([.medium, .large])
//                    .presentationDragIndicator(.automatic)
            

        }
        .overlay(
            Group {
                if showAddItemOverlay {
                    ZStack {
                        Color.black.opacity(0.64)
                            .ignoresSafeArea()
                        VStack(spacing: 20) {
                            Text("Update Odometer ")
                                .font(.headline)
                            TextField("New Odometer Reading", text: $tempOdometer)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(.roundedBorder)
                            HStack {
                                Button("Cancel") {
                                    withAnimation {
                                        showAddItemOverlay = false
                                    }
                                }
                                Spacer()
                                Button("Save") {
                                    let trimmedOdometer = tempOdometer.trimmingCharacters(in: .whitespacesAndNewlines)
                                    guard !trimmedOdometer.isEmpty else { return }
                                    longPressedVehicle?.currentMileage = Int(trimmedOdometer) ?? 0
                                    try? modelContext.save()
                                    withAnimation {
                                        showAddItemOverlay = false
                                    }
                                }
                                .disabled(tempOdometer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            }
                        }
                       
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .frame(maxWidth: 400)
                        .shadow(radius: 10)
                    }
                    .transition(.opacity)
                }
            }
        )
    }
}

#Preview {
    GarageView()
        .modelContainer(PreviewContainer.shared)
}

