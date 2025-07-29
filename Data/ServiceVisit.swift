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
    var tax: Double?
    var total: Double
    var notes: String?
    var photoData: Data?

    @Relationship var vehicle: Vehicle?
    @Relationship var provider: ServiceProvider?
    @Relationship var savedItems: [SavedServiceItem] = []

    init(date: Date, mileage: Int, cost: Double, tax: Double? = nil, total: Double , notes: String? = nil, photoData: Data? = nil, vehicle: Vehicle? = nil, provider: ServiceProvider? = nil, savedItems: [SavedServiceItem]) {
        self.date = date
        self.mileage = mileage
        self.cost = cost
        self.tax = tax
        self.total = total
        self.notes = notes
        self.photoData = photoData
        self.vehicle = vehicle
        self.provider = provider
        self.savedItems = savedItems
    }
}

