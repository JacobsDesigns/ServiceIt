//
//  ServiceVisit.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/24/25.
//
import Foundation
import SwiftData

@Model
class ServiceVisit : Identifiable {
    var date: Date
    var mileage: Int
    var cost: Double
    var notes: String?
    var photoData: Data?

    @Relationship var vehicle: Vehicle?
    @Relationship var provider: ServiceProvider?
    @Relationship var items: [ServiceItem] = []

    init(date: Date, mileage: Int, cost: Double, notes: String? = nil, photoData: Data? = nil, vehicle: Vehicle? = nil, provider: ServiceProvider? = nil, items: [ServiceItem]) {
        self.date = date
        self.mileage = mileage
        self.cost = cost
        self.notes = notes
        self.photoData = photoData
        self.vehicle = vehicle
        self.provider = provider
        self.items = items
    }
}

