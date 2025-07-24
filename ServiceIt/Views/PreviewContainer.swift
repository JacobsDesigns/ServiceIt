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
            ServiceType.self,
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

//        let container = try! ModelContainer(for: schema, configurations: [config])
//        seedMockData(into: container.mainContext)
//        return container
    }()

    private static func seedMockData(into context: ModelContext) {
        MockData.allVehicles().forEach { context.insert($0) }
        MockData.allProviders().forEach { context.insert($0) }
        MockData.allServiceTypes().forEach { context.insert($0) }
        MockData.allRecords().forEach { context.insert($0) }
        try? context.save()
    }
}

