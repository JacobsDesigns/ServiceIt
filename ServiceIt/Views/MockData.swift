//
//  MockData.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/18/25.
//
import Foundation

struct MockData {
    // 🚗 Vehicles
    static let vehicle1 = Vehicle(name: "Civic", modelYear: 2020, vin: "VIN001", license: "ABC123", currentMileage: 22000)
    static let vehicle2 = Vehicle(name: "Camry", modelYear: 2019, vin: "VIN002", license: "XYZ789", currentMileage: 33000)

    // 🏢 Service Providers
    static let providers: [ServiceProvider] = [
        ServiceProvider(name: "AutoFix", contactInfo: "autofix@example.com"),
        ServiceProvider(name: "Speedy Repair", contactInfo: "contact@speedyrepair.com"),
        ServiceProvider(name: "Precision Auto", contactInfo: "info@precisionauto.com"),
        ServiceProvider(name: "Mobile Mechanics", contactInfo: "hello@mobilemech.com")
    ]

    // 🔧 Service Types
    static let serviceTypes: [ServiceType] = [
        ServiceType(name: "Oil Change", suggestedMileage: 5000),
        ServiceType(name: "Brake Inspection", suggestedMileage: 10000),
        ServiceType(name: "Tire Rotation", suggestedMileage: 7500),
        ServiceType(name: "Transmission Flush", suggestedMileage: 30000),
        ServiceType(name: "Battery Replacement", suggestedMileage: 40000),
        ServiceType(name: "Coolant Top-Up", suggestedMileage: 25000)
    ]

    // 📦 Expanded Records
    static func allRecords() -> [ServiceRecord] {
        var records: [ServiceRecord] = []
        let calendar = Calendar.current
        let today = Date()

        for i in 0..<20 {
            // Civic Records
            let civicMileage = 18000 + i * 300
            let civicDate = calendar.date(byAdding: .month, value: -i, to: today) ?? today
            let civicType = serviceTypes[i % serviceTypes.count]
            let civicProvider = providers[i % providers.count]
            let civicCost = Double.random(in: 60...150)

            let civicRecord = ServiceRecord(
                vehicle: vehicle1,
                type: civicType,
                cost: civicCost,
                date: civicDate,
                mileage: civicMileage,
                provider: civicProvider
            )
            records.append(civicRecord)

            // Camry Records
            let camryMileage = 28000 + i * 350
            let camryDate = calendar.date(byAdding: .month, value: -i, to: today) ?? today
            let camryType = serviceTypes[(i + 2) % serviceTypes.count]
            let camryProvider = providers[(i + 1) % providers.count]
            let camryCost = Double.random(in: 70...180)

            let camryRecord = ServiceRecord(
                vehicle: vehicle2,
                type: camryType,
                cost: camryCost,
                date: camryDate,
                mileage: camryMileage,
                provider: camryProvider
            )
            records.append(camryRecord)
        }

        return records
    }

    // Accessors
    static func allVehicles() -> [Vehicle] { [vehicle1, vehicle2] }
    static func allServiceTypes() -> [ServiceType] { serviceTypes }
    static func allProviders() -> [ServiceProvider] { providers }
}
