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
            Text("Cost by Year")
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
            }
            .chartYAxis {
                AxisMarks(position: .leading){
                    AxisValueLabel(format: .currency(code: "USD"))}
            }
            .frame(height: 200)
        }
        .padding()
        //.frame(maxWidth: .infinity)
    }
}


//#Preview("Predictive Insights") {
//    let mockRecords = [
////        ServiceRecord.mock(type: "Oil Change", cost: 45.00, mileage: 10000),
////        ServiceRecord.mock(type: "Oil Change", cost: 48.00, mileage: 15000),
////        ServiceRecord.mock(type: "Oil Change", cost: 50.00, mileage: 20000)
//    ]
//     PredictiveInsightsSection(records: mockRecords)
//}

