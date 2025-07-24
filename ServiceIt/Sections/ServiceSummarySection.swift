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
    var records: [ServiceRecord]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Service Summary")
                .font(.title3)
                .bold()

            let totalCost = records.reduce(0) { $0 + $1.cost }
            let recordCount = records.count
            let avgCost = recordCount == 0 ? 0 : totalCost / Double(recordCount)

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
            }
            .font(.subheadline)
        }
        .padding()
        //.frame(maxWidth: .infinity)
    }
}

#Preview("Predictive Insights") {
    let mockRecords = [
        ServiceRecord.mock(type: "Oil Change", cost: 45.00, mileage: 10000),
        ServiceRecord.mock(type: "Oil Change", cost: 48.00, mileage: 15000),
        ServiceRecord.mock(type: "Oil Change", cost: 50.00, mileage: 20000)
    ]
    ServiceSummarySection(records: mockRecords)
}
