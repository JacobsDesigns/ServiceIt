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
            Vehicle(name: "Toyota",  modelYear: 2022, vin: "1234", license: "Vanitiy" , currentMileage: 14500),
            Vehicle(name: "Forester",  modelYear: 2020, vin: "1234", license: "Vanitiy" , currentMileage: 28000)
        ]
    }

    static func allProviders() -> [ServiceProvider] {
        [
            ServiceProvider(name: "Quick Lube", contactInfo: "714-555-1234"),
            ServiceProvider(name: "Toyota Service Center", contactInfo: "949-555-5678"),
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
    
    static func mockStations() -> [RefuelStation] {
        [
            RefuelStation(name: "Shell", location: "RSM"),
            RefuelStation(name: "Shell", location: "Mission Viejo"),
            RefuelStation(name: "Chevron", location: "RSM")
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
            let tax = totalCost * 0.08
            let totalCostWithTax = totalCost + tax
            
            return ServiceVisit(
                date: date,
                mileage: mileage,
                cost: totalCost,
                tax : tax,
                total: totalCostWithTax,
                notes: "Visit \(i) for \(vehicle.name)",
                photoData: nil,
                vehicle: vehicle,
                provider: provider,
                savedItems: Array(savedItems)
            )
        }
    }
    
    static func generateRefuelVisits(for vehicle: Vehicle, station: RefuelStation, count: Int) -> [RefuelVisit] {
        (1...count).map { i in
            let gallons = Double.random(in: 8...15)
            let costPerGallon = Double.random(in: 4.0...5.5)
            let cost = gallons * costPerGallon
            let mileage = vehicle.currentMileage + Int.random(in: 100...(500 * i))
            let date = Calendar.current.date(byAdding: .day, value: -i * 30, to: Date())!

            return RefuelVisit(
                odometer: mileage,
                date: date,
                gallons: gallons,
                costPerGallon: costPerGallon,
                total: cost,
                vehicle: vehicle,
                refuelStation: station
            )
        }
    }


}
