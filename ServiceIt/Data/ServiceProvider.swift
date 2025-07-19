//
//  ServiceProvider.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/12/25.
//
import SwiftData


@Model
class ServiceProvider {
    var name: String
    var contactInfo: String

    @Relationship var records: [ServiceRecord] = []

    init(name: String, contactInfo: String) {
        self.name = name
        self.contactInfo = contactInfo
    }
}



