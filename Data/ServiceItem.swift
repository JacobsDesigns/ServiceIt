//
//  ServiceType.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/12/25.
//
import SwiftData


@Model
class ServiceItem {
    var name: String
    var cost: Double

    init(name: String, cost: Double) {
        self.name = name
        self.cost = cost
    }
}
