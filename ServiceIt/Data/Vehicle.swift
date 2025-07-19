//
//  Vehicle.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/13/25.
//
import SwiftData


@Model
class Vehicle {
    var name: String
    var modelYear: Int
    var vin: String
    var license: String
    var currentMileage: Int // 🔗 Linkable field

    @Relationship var serviceRecords: [ServiceRecord] = []

    init(name: String, modelYear: Int, vin: String, currentMileage: Int, license: String) {
        self.name = name
        self.modelYear = modelYear
        self.vin = vin
        self.currentMileage = currentMileage
        self.license = license
    }
}
