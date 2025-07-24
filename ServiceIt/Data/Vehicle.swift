//
//  Vehicle.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/13/25.
//
import SwiftData
import Foundation


@Model
class Vehicle {
    var name: String
    var modelYear: Int
    var vin: String
    var license: String
    var currentMileage: Int // 🔗 Linkable field
    var photoData: Data?

    @Relationship var serviceRecords: [ServiceRecord] = []

    init(name: String, modelYear: Int, vin: String, license: String, currentMileage: Int, photoData: Data? = nil) {
        self.name = name
        self.modelYear = modelYear
        self.vin = vin
        self.license = license
        self.currentMileage = currentMileage
        self.photoData = photoData

    }
}
extension Vehicle {
    var plainModelYearString: String {
        String(modelYear)
    }
}
