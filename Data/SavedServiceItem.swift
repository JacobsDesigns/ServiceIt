//
//  SavedServiceItem.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/26/25.
//
import SwiftData

@Model
class SavedServiceItem {
    @Attribute var name: String
    @Attribute var cost: Double

    @Relationship var visit: ServiceVisit?

    init(name: String, cost: Double, visit: ServiceVisit? = nil) {
        self.name = name
        self.cost = cost
        self.visit = visit
    }
}
