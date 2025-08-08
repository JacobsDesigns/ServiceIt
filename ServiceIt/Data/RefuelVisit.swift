//
//  RefuelVisit.swift
//  ServiceIt
//
//  Created by Jacob Filek on 8/4/25.
//
import Foundation
import SwiftData

@Model
class RefuelVisit : Identifiable {
    var odometer: Int
    var date: Date
    var gallons: Double
    var costPerGallon: Double
    var total: Double
    
    @Relationship var vehicle: Vehicle?
    @Relationship var refuelStation: RefuelStation?
    
    @Attribute var addedCarWash: Bool = false
    @Attribute var carWashCost: Double?

    init(odometer: Int, date: Date, gallons: Double, costPerGallon: Double, total: Double, vehicle: Vehicle? = nil, refuelStation: RefuelStation? = nil) {
        self.odometer = odometer
        self.date = date
        self.gallons = gallons
        self.costPerGallon = costPerGallon
        self.total = total
        self.vehicle = vehicle
        self.refuelStation = refuelStation
    }
    
}

extension RefuelVisit {
    func mpg(previousOdometer: Int?) -> Double? {
        guard let previous = previousOdometer, gallons > 0 else { return nil }
        let milesDriven = odometer - previous
        return Double(milesDriven) / gallons
    }
}
