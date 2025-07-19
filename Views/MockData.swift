//
//  MockData.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/18/25.
//
import Foundation

struct MockData {
    static let vehicle1 = Vehicle(
        name: "Civic",
        modelYear: 2020,
        vin: "VIN001",
        currentMileage: 22000,
        license: "ABC123"
    )

    static let vehicle2 = Vehicle(
        name: "Camry",
        modelYear: 2019,
        vin: "VIN002",
        currentMileage: 33000,
        license: "XYZ789"
    )

    static let provider1 = ServiceProvider(
        name: "AutoFix",
        contactInfo: "autofix@example.com"
    )

    static let provider2 = ServiceProvider(
        name: "Speedy Repair",
        contactInfo: "contact@speedyrepair.com"
    )

    static let type1 = ServiceType(name: "Oil Change")
    static let type2 = ServiceType(name: "Brake Inspection")

    static var record1: ServiceRecord {
        ServiceRecord(
            vehicle: vehicle1,
            type: type1,
            cost: 89.99,
            date: Date(),
            mileage: 22000,
            provider: provider1
        )
    }

    static var record2: ServiceRecord {
        ServiceRecord(
            vehicle: vehicle2,
            type: type2,
            cost: 159.00,
            date: Calendar.current.date(byAdding: .month, value: -2, to: Date()) ?? Date(),
            mileage: 32500,
            provider: provider2
        )
    }

    static func allVehicles() -> [Vehicle] {
        [vehicle1, vehicle2]
    }

    static func allProviders() -> [ServiceProvider] {
        [provider1, provider2]
    }

    static func allServiceTypes() -> [ServiceType] {
        [type1, type2]
    }

    static func allRecords() -> [ServiceRecord] {
        [record1, record2]
    }
}
