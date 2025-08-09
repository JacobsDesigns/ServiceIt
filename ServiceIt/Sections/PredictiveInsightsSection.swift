//
//  PredictiveInsightsSection.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/19/25.
//
import SwiftData
import SwiftUI
import Charts

struct PredictiveInsightsSection: View {
    var records: [ServiceVisit]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Service Costs by Year")
                .font(.title3)
                .bold()

            let grouped = Dictionary(grouping: records) { record in
                Calendar.current.component(.year, from: record.date)
            }

            let costByYear = grouped.map { (year, records) in
                (year: year, total: records.reduce(0) { $0 + $1.cost })
            }
            .sorted { $0.year < $1.year }

            Chart(costByYear, id: \.year) { data in
                BarMark(
                    x: .value("Year", "\(data.year)"),
                    y: .value("Cost", data.total)
                )
                .foregroundStyle(.blue)
                .annotation(position: .top){
                    Text(data.total, format: .currency(code: "USD"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading){
                    AxisValueLabel(format: .currency(code: "USD"))}
            }
            .frame(height: 200)
        }
        .padding()
    }
}


#Preview {
    let sampleRecords: [ServiceVisit] = [
        ServiceVisit(
            date: Calendar.current.date(from: DateComponents(year: 2022, month: 3, day: 15))!,
            mileage: 15000,
            cost: 120.0,
            total: 120.0,
            savedItems: []
        ),
        ServiceVisit(
            date: Calendar.current.date(from: DateComponents(year: 2022, month: 7, day: 10))!,
            mileage: 18000,
            cost: 80.0,
            total: 80.0,
            savedItems: []
        ),
        ServiceVisit(
            date: Calendar.current.date(from: DateComponents(year: 2023, month: 2, day: 5))!,
            mileage: 22000,
            cost: 150.0,
            total: 150.0,
            savedItems: []
        ),
        ServiceVisit(
            date: Calendar.current.date(from: DateComponents(year: 2023, month: 11, day: 20))!,
            mileage: 27000,
            cost: 95.0,
            total: 95.0,
            savedItems: []
        ),
        ServiceVisit(
            date: Calendar.current.date(from: DateComponents(year: 2024, month: 6, day: 1))!,
            mileage: 32000,
            cost: 200.0,
            total: 200.0,
            savedItems: []
        )
    ]

    PredictiveInsightsSection(records: sampleRecords)
}




