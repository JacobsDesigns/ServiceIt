//
//  PreviewContainer.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/18/25.
//
import SwiftData

@MainActor
enum PreviewContainer {
    static let shared: ModelContainer = {
        let schema = Schema([
            Vehicle.self,
            ServiceProvider.self,
            ServiceItem.self,
            ServiceVisit.self,
            RefuelVisit.self,
            RefuelStation.self
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        do {
            let container = try ModelContainer(for: schema, configurations: [config])
            seedMockData(into: container.mainContext)
            return container
        } catch {
            fatalError("❌ Failed to build preview container: \(error)")
        }

    }()
    private static func seedMockData(into context: ModelContext) {
        let vehicles = MockData.allVehicles()
        let providers = MockData.allProviders()
        let stations = MockData.mockStations()

        vehicles.forEach { context.insert($0) }
        providers.forEach { context.insert($0) }
        stations.forEach { context.insert($0) }

        for (index, vehicle) in vehicles.enumerated() {
            let provider = providers[index % providers.count]
            let station = stations[index % stations.count]
            
            let visits = MockData.generateVisits(for: vehicle, provider: provider, count: 3)
            visits.forEach { context.insert($0) }
            
            let refuelVisits = MockData.generateRefuelVisits(for: vehicle, station: station, count: 2)
            refuelVisits.forEach { context.insert($0) }
            
        }

        try? context.save()
    }
}

