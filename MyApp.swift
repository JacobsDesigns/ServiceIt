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
        DocumentGroup(editing: ServiceProvider.self, contentType: .carServiceDocument) {
            ContentView()
                //.modelContainer(file.modelContainer)
        }

    }
}

