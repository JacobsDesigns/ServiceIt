//
//  MyAppPreviewRoot.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/23/25.
//
import SwiftUI


struct MyAppPreviewRoot: View {
    var body: some View {
        TabView {
            GarageView()
                .tabItem {
                    Label("Garage", systemImage: "car.fill")
                }
            AllVisitsView()
                .tabItem {
                    Label("Records", systemImage: "list.bullet")
                }
            AllRefuelsView() // Optional tab
            
                .tabItem {
                    Label("Refuel", systemImage: "fuelpump.and.filter")
                }
            ServiceScheduleView()
                .tabItem {
                    Label("Schedule", systemImage: "calendar")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .modelContainer(PreviewContainer.shared)
    }
}

#Preview {
    MyAppPreviewRoot()
}

