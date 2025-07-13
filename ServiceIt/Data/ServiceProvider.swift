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
    var records: [ServiceRecord]
    
    
    init(name: String,contactInfo: String, records: [ServiceRecord] = []) {
        self.name = name
        self.contactInfo = contactInfo
        self.records = records
    }
}


