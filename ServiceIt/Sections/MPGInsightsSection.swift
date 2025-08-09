
//  MPGInsightsSection.swift
//  ServiceIt
//
//  Created by Jacob Filek on 8/8/25.
//
import SwiftData
import SwiftUI
import Charts

struct MPGInsightsSection: View {
    var refuelRecords: [RefuelVisit]
    var selectedVehicle: Vehicle?

    private struct MPGData: Identifiable {
        let id = UUID()
        let year: Int
        let vehicleName: String
        let averageMPG: Double
    }
    private struct VehicleYearKey: Hashable {
        let vehicleName: String
        let year: Int
    }

    private var averagedMPGByYearAndVehicle: [MPGData] {
        let filteredRecords = selectedVehicle == nil
        ? refuelRecords
        : refuelRecords.filter { $0.vehicle?.id == selectedVehicle?.id}
        let sortedRecords = filteredRecords.sorted { $0.date < $1.date }

        // Group by vehicle name and year
        let grouped = Dictionary(grouping: sortedRecords) { record in
            let vehicleName = record.vehicle?.name ?? "Unknown"
            let year = Calendar.current.component(.year, from: record.date)
            return VehicleYearKey(vehicleName: vehicleName, year: year)
        }



        var result: [MPGData] = []

        for (key, records) in grouped {
            var previousOdometer: Int?
            var mpgs: [Double] = []

            for record in records {
                if let mpg = record.mpg(previousOdometer: previousOdometer) {
                    mpgs.append(mpg)
                }
                previousOdometer = record.odometer
            }

            if !mpgs.isEmpty {
                let average = mpgs.reduce(0, +) / Double(mpgs.count)
                result.append(MPGData(year: key.year, vehicleName: key.vehicleName, averageMPG: average))
            }
        }

        return result.sorted { $0.year < $1.year }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Average MPG by Year")
                .font(.title3)
                .bold()

            Chart(averagedMPGByYearAndVehicle) { data in
                BarMark(
                    x: .value("Year", "\(data.year)"),
                    y: .value("MPG", data.averageMPG)
                )
                .foregroundStyle(by: .value("Vehicle", data.vehicleName))
                .annotation(position: .top) {
                    Text(String(format: "%.1f MPG", data.averageMPG))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) {
                    AxisValueLabel()
                }
            }
            .frame(height: 240)
        }
        .padding()
    }
}
