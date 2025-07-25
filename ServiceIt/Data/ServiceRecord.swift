//
//  ServiceRecord.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/12/25.
//
import SwiftData
import Foundation

@Model
class ServiceRecord : Identifiable {
    @Relationship var vehicle: Vehicle?
    @Relationship var items: [ServiceItem] = []
    var cost: Double
    var date: Date
    var mileage: Int
    @Relationship var provider: ServiceProvider?
    
    init(vehicle: Vehicle? = nil, items: [ServiceItem] = [], cost: Double, date: Date, mileage: Int, provider: ServiceProvider? = nil) {
        self.vehicle = vehicle
        self.items = items
        self.cost = cost
        self.date = date
        self.mileage = mileage
        self.provider = provider
    }
}
extension ServiceRecord {
    static func mock(types: [String], cost: Double, mileage: Int) -> ServiceRecord {
        let items = types.map { ServiceItem(name: $0, cost: Double.random(in: 50...200)) }
        return ServiceRecord(
            vehicle: nil,
            items: items,
            cost: cost,
            date: .now,
            mileage: mileage,
            provider: ServiceProvider(name: "Mock Provider", contactInfo: "Info")
        )
    }
}

