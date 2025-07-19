//
//  ProviderRowView.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/12/25.
//
import SwiftUI


struct ProviderRowView: View {
    var provider: ServiceProvider

    var body: some View {
        VStack(alignment: .leading) {
            Text(provider.name)
                .font(.headline)
//            Text(provider.contactInfo)
//                .font(.subheadline)
//                .foregroundColor(.secondary)
        }
    }
}
