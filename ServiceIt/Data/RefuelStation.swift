//
//  RefuelStation.swift
//  ServiceIt
//
//  Created by Jacob Filek on 8/4/25.
//
import SwiftData

@Model
class RefuelStation : Identifiable {
    var name: String
    var location: String
    
    init(name: String, location: String) {
        self.name = name
        self.location = location
    }
    
}
