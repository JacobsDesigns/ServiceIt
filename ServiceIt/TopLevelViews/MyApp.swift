//
//  MyApp.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/12/25.
//

import SwiftUI
import SwiftData

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                GarageView()
                    .tabItem {
                        Label("Garage", systemImage: "car.fill")
                    }
                AllRecordsView()
                    .tabItem {
                        Label("Service Records", systemImage: "list.bullet")
                    }
                ServiceScheduleView() // Optional tab
                
                    .tabItem {
                        Label("Schedule", systemImage: "calendar")
                    }
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
        }
        .modelContainer(for: [Vehicle.self, ServiceProvider.self, ServiceItem.self, ServiceRecord.self])
        
    }
}

