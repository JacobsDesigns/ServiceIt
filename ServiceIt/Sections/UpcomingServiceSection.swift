//
//  UpcomingServiceSection.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/19/25.
//
import SwiftData
import SwiftUI

struct UpcomingServiceSection: View {
    var vehicle: Vehicle
    var serviceTypes: [ServiceItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Upcoming Services")
                .font(.title3)
                .bold()

            let upcoming = serviceTypes.compactMap { type -> String? in
                let interval = type.cost
                guard interval > 0 else { return nil }
                let nextDue = ((Double(vehicle.currentMileage) / interval) + 1) * interval
                guard Int(nextDue) > vehicle.currentMileage else { return nil }
                return "\(type.name): due at \(nextDue.formatted()) mi"
            }

            if upcoming.isEmpty {
                Text("No upcoming services detected.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(upcoming, id: \.self) { item in
                    Label(item, systemImage: "wrench.and.screwdriver")
                }
            }
        }
        .padding()
        //.frame(maxWidth: .infinity, alignment: .leading)
    }
}


struct ReminderRow: View {
    var type: String
    var dueMileage: Int? = nil
    var currentMileage: Int? = nil
    var dueDate: Date? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(type)
                .font(.subheadline)
                .bold()

            if let dueMileage, let currentMileage {
                Text("Due at \(dueMileage) mi · \(dueMileage - currentMileage) mi remaining")
                    .foregroundColor(.secondary)
                    .font(.footnote)
            }

            if let dueDate {
                Text("Due by \(dueDate.formatted(date: .abbreviated, time: .omitted))")
                    .foregroundColor(.secondary)
                    .font(.footnote)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview("Upcoming Services") {
    struct PreviewWrapper: View {
        var body: some View {
            let vehicle = Vehicle(
                name: "Civic",
                modelYear: 2020,
                vin: "",license: "",currentMileage: 12000,
                photoData: nil
            )

            let types = [
                ServiceItem(name: "Oil Change", cost: 50),
                ServiceItem(name: "Tire Rotation", cost: 100),
                ServiceItem(name: "Brake Inspection", cost: 89),
                ServiceItem(name: "Cabin Filter", cost: 15)
            ]

            UpcomingServiceSection(vehicle: vehicle, serviceTypes: types)
        }
    }

    return PreviewWrapper()
}

