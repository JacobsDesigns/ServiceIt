//
//  VehicleSummaryCard.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/19/25.
//


import SwiftUI

struct VehicleSummaryCard: View {
    var vehicle: Vehicle

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 📸 Vehicle Image
            if let data = vehicle.photoData,
               let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 140)
                    .clipped()
                    .cornerRadius(12)
            } else {
                Image(systemName: "car.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
            }

            // 🚘 Vehicle Info
            Text("\(vehicle.modelYear.description) \(vehicle.name)")
                .font(.headline)

            Text("Mileage: \(vehicle.currentMileage, format: .number) mi")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text("License: \(vehicle.license)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(16)
        .shadow(radius: 2)
    }
}

#Preview {
    VehicleSummaryCard(vehicle: MockData.allVehicles().first!)
        .modelContainer(PreviewContainer.shared)
        .padding()
}

