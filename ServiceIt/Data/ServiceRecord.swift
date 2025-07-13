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
    
    @Relationship var type: ServiceType?
    var cost: Double
    var date: Date
    var mileage: Int
    @Relationship var provider: ServiceProvider?

    
    init(type: ServiceType?, cost: Double, date: Date, mileage: Int, provider: ServiceProvider? = nil) {
        self.type = type
        self.cost = cost
        self.date = date
        self.mileage = mileage
        self.provider = provider
    }
    
    
}
