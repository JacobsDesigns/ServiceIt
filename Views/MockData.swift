//
//  MockData.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/18/25.
//
import SwiftData
import Foundation

enum MockData {
    static func allVehicles() -> [Vehicle] {
        [
            Vehicle(name: "Civic",  modelYear: 2018, vin: "1234", license: "Vanitiy" ,currentMileage: 32000),
            Vehicle(name: "Model S",  modelYear: 2022, vin: "1234", license: "Vanitiy" , currentMileage: 14500),
            Vehicle(name: "Forester",  modelYear: 2020, vin: "1234", license: "Vanitiy" , currentMileage: 28000)
        ]
    }

    static func allProviders() -> [ServiceProvider] {
        [
            ServiceProvider(name: "Quick Lube", contactInfo: "714-555-1234"),
            ServiceProvider(name: "Tesla Service Center", contactInfo: "949-555-5678"),
            ServiceProvider(name: "Subie Garage", contactInfo: "949-555-2468")
        ]
    }

    static func mockItems() -> [ServiceItem] {
        [
            ServiceItem(name: "Oil Change", cost: 49.99),
            ServiceItem(name: "Air Filter Replacement", cost: 29.99),
            ServiceItem(name: "Brake Inspection", cost: 0.0)
        ]
    }
    
    static func mockSavedItems() -> [SavedServiceItem] {
        [
            SavedServiceItem(name: "Oil Change", cost: 49.99),
            SavedServiceItem(name: "Air Filter Replacement", cost: 29.99),
            SavedServiceItem(name: "Brake Inspection", cost: 0)
            ]
    }

    static func generateVisits(for vehicle: Vehicle, provider: ServiceProvider, count: Int) -> [ServiceVisit] {
        (1...count).map { i in
            let serviceItems = mockItems().shuffled().prefix(Int.random(in: 1...3))
            let savedItems = serviceItems.map { item in
                SavedServiceItem(name: item.name, cost: item.cost)
            }

            let mileage = vehicle.currentMileage + Int.random(in: 500...(1500 * i))
            let date = Date.now
            let totalCost = savedItems.reduce(0.0) { $0 + $1.cost }

            return ServiceVisit(
                date: date,
                mileage: mileage,
                cost: totalCost,
                notes: "Visit \(i) for \(vehicle.name)",
                photoData: nil,
                vehicle: vehicle,
                provider: provider,
                savedItems: Array(savedItems)
            )
        }
    }

}

//import Foundation
//
//struct MockData {
//    // 🚗 Vehicles
//    static let vehicle1 = Vehicle(name: "Civic", modelYear: 2020, vin: "VIN001", license: "ABC123", currentMileage: 22000)
//    static let vehicle2 = Vehicle(name: "Camry", modelYear: 2019, vin: "VIN002", license: "XYZ789", currentMileage: 33000)
//
//    // 🏢 Service Providers
//    static let providers: [ServiceProvider] = [
//        ServiceProvider(name: "AutoFix", contactInfo: "autofix@example.com"),
//        ServiceProvider(name: "Speedy Repair", contactInfo: "contact@speedyrepair.com"),
//        ServiceProvider(name: "Precision Auto", contactInfo: "info@precisionauto.com"),
//        ServiceProvider(name: "Mobile Mechanics", contactInfo: "hello@mobilemech.com")
//    ]
//
//    // 🔧 Service Items
//    static let serviceItems: [ServiceItem] = [
//        ServiceItem(name: "Oil Change", cost: 59.99),
//        ServiceItem(name: "Brake Inspection", cost: 100),
//        ServiceItem(name: "Tire Rotation", cost: 75),
//        ServiceItem(name: "Transmission Flush", cost: 300),
//        ServiceItem(name: "Battery Replacement", cost: 40),
//        ServiceItem(name: "Coolant Top-Up", cost: 250)
//    ]
//
//    // 📦 Expanded Records
//    static func allRecords() -> [ServiceRecord] {
//        var records: [ServiceRecord] = []
//        let calendar = Calendar.current
//        let today = Date()
//
//        for i in 0..<20 {
//            // Randomly select 2–3 unique service items for each record
//            let civicItems = Array(serviceItems.shuffled().prefix(Int.random(in: 2...3)))
//            let camryItems = Array(serviceItems.shuffled().prefix(Int.random(in: 2...3)))
//
//            let civicRecord = ServiceRecord(
//                vehicle: vehicle1,
//                items: civicItems,
//                cost: civicItems.reduce(0) { $0 + $1.cost },
//                date: calendar.date(byAdding: .month, value: -i, to: today) ?? today,
//                mileage: 18000 + i * 300,
//                provider: providers[i % providers.count]
//            )
//            records.append(civicRecord)
//
//            let camryRecord = ServiceRecord(
//                vehicle: vehicle2,
//                items: camryItems,
//                cost: camryItems.reduce(0) { $0 + $1.cost },
//                date: calendar.date(byAdding: .month, value: -i, to: today) ?? today,
//                mileage: 28000 + i * 350,
//                provider: providers[(i + 1) % providers.count]
//            )
//            records.append(camryRecord)
//        }
//
//        return records
//    }
//
//    // Accessors
//    static func allVehicles() -> [Vehicle] { [vehicle1, vehicle2] }
//    static func allServiceItems() -> [ServiceItem] { serviceItems }
//    static func allProviders() -> [ServiceProvider] { providers }
//}
