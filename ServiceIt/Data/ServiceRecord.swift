//
//  ServiceRecord.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/12/25.
//
import SwiftData
import Foundation

@Model
class ServiceRecord {
    @Relationship var vehicle: Vehicle?
    @Relationship var type: ServiceType?
    var cost: Double
    var date: Date
    var mileage: Int
    @Relationship var provider: ServiceProvider?
    
    init(vehicle: Vehicle? = nil, type: ServiceType?, cost: Double, date: Date, mileage: Int, provider: ServiceProvider? = nil) {
        self.vehicle = vehicle
        self.type = type
        self.cost = cost
        self.date = date
        self.mileage = mileage
        self.provider = provider
    }
}
extension ServiceRecord {
    static func mock(type: String, cost: Double, mileage: Int) -> ServiceRecord {
        ServiceRecord(
            vehicle: nil,
            type: ServiceType(name: type),
            cost: cost,
            date: .now,
            mileage: Int.random(in: 10000...20000),
            provider: ServiceProvider(name: "Mock Provider", contactInfo: "Info")
        )
    }
}
