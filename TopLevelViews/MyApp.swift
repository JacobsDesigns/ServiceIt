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
                AllVisitsView()
                    .tabItem {
                        Label("Records", systemImage: "doc.text")
                    }
                AllRefuelsView()
                    .tabItem {
                        Label("Refuel", systemImage: "fuelpump.and.filter")
                    }
                ServiceScheduleView()
                    .tabItem {
                        Label("Summaries", systemImage: "chart.bar")
                    }
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
            }
        }
        .modelContainer(for: [
            Vehicle.self,
            ServiceProvider.self,
            ServiceItem.self,
            SavedServiceItem.self,
            ServiceVisit.self,
            RefuelStation.self,
            RefuelVisit.self])
        
    }
}

