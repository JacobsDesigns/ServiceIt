//
//  RecordSortOption.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/19/25.
//
import SwiftUI

enum RecordSortOption: String, CaseIterable, Identifiable {
    case dateDescending = "Date ↓"
    case dateAscending = "Date ↑"
    case mileageAscending = "Mileage ↑"
    case mileageDescending = "Mileage ↓"
    case costDescending = "Cost ↓"
    case costAscending = "Cost ↑"

    var id: String { rawValue }
}
