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
            ServiceRecord.self
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

        vehicles.forEach { context.insert($0) }
        providers.forEach { context.insert($0) }

        for (index, vehicle) in vehicles.enumerated() {
            let provider = providers[index % providers.count]
            let visits = MockData.generateVisits(for: vehicle, provider: provider, count: 3)
            visits.forEach { context.insert($0) }
        }

        try? context.save()
    }

//    private static func seedMockData(into context: ModelContext) {
//        MockData.allVehicles().forEach { context.insert($0) }
//        MockData.allProviders().forEach { context.insert($0) }
//        //MockData.generateVisits(for: <#Vehicle#>, count: <#Int#>).forEach { context.insert($0) }
//        try? context.save()
//    }
}

