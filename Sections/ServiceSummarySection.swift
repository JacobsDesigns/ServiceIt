//
//  ServiceSummarySection.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/19/25.
//
import SwiftData
import SwiftUI
import Foundation

struct ServiceSummarySection: View {
    var records: [ServiceVisit]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Service Summary")
                .font(.title3)
                .bold()

            let totalCost = records.reduce(0) { $0 + $1.cost }
            let recordCount = records.count
            let avgCost = recordCount == 0 ? 0 : totalCost / Double(recordCount)

            // Average cost per year
            let calendar = Calendar.current
            let recordsByYear = Dictionary(grouping: records) {
                calendar.component(.year, from: $0.date)
            }

            let avgCostPerYear: Double = {
                guard !recordsByYear.isEmpty else { return 0 }
                let yearlyTotals = recordsByYear.values.map { yearRecords in
                    yearRecords.reduce(0) { $0 + $1.cost }
                }
                let sumOfYears = yearlyTotals.reduce(0, +)
                return sumOfYears / Double(yearlyTotals.count)
            }()

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Total Records")
                    Spacer()
                    Text("\(recordCount)")
                }
                HStack {
                    Text("Total Cost")
                    Spacer()
                    Text(totalCost, format: .currency(code: "USD"))
                }
                HStack {
                    Text("Avg Cost/Service")
                    Spacer()
                    Text(avgCost, format: .currency(code: "USD"))
                }
                HStack {
                    Text("Avg Cost / Year")
                    Spacer()
                    Text(avgCostPerYear, format: .currency(code: "USD"))
                }
            }
            .font(.subheadline)
        }
        .padding()
        //.frame(maxWidth: .infinity)
    }
}

#Preview("Service Summary") {
    let mockRecords: [ServiceVisit] = [
        ServiceVisit(
            date: Calendar.current.date(byAdding: .day, value: -30, to: .now) ?? .now,
            mileage: 10_000,
            cost: 45.00,
            tax: nil,
            discount: nil,
            total: 45.00,
            notes: nil,
            photoData: nil,
            vehicle: nil,
            provider: nil,
            savedItems: []
        ),
        ServiceVisit(
            date: Calendar.current.date(byAdding: .day, value: -15, to: .now) ?? .now,
            mileage: 15_000,
            cost: 48.00,
            tax: nil,
            discount: nil,
            total: 48.00,
            notes: nil,
            photoData: nil,
            vehicle: nil,
            provider: nil,
            savedItems: []
        ),
        ServiceVisit(
            date: .now,
            mileage: 20_000,
            cost: 50.00,
            tax: nil,
            discount: nil,
            total: 50.00,
            notes: nil,
            photoData: nil,
            vehicle: nil,
            provider: nil,
            savedItems: []
        )
    ]

    return ServiceSummarySection(records: mockRecords)
        .padding()
}
