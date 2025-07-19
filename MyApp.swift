//
//  MyApp.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/12/25.
//

import SwiftUI
import UniformTypeIdentifiers
import SwiftData

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
        }
        //.modelContainer(for: [ServiceProvider.self, ServiceRecord.self])
        .modelContainer(for: [Vehicle.self, ServiceProvider.self, ServiceType.self, ServiceRecord.self])

    }
}

//
//@main
//struct MyApp: App {
//    
//    let newProvider = ServiceProvider(name: "name", contactInfo: "contact")
//    
//    var body: some Scene {
//        DocumentGroup(editing: ServiceProvider.self, contentType: .carServiceDocument) {
//            MainView(provider: newProvider)
//        }
//    }
//    
//}

