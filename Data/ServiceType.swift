//
//  ServiceType.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/12/25.
//
import SwiftData


@Model
class ServiceType {
    var name: String
    var suggestedMileage: Int?

    init(name: String, suggestedMileage: Int? = nil) {
        self.name = name
        self.suggestedMileage = suggestedMileage
    }
}
