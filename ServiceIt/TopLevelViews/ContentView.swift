//
//  ContentView.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/12/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Bindable var provider: ServiceProvider
    @Query var providers: [ServiceProvider]
    @State private var showingAddProvider = false
    @State private var showingTypeManager = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if providers.isEmpty {
                    Text("No service providers found.")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    List {
                        ForEach(providers) { provider in
                            NavigationLink(destination: ProviderDetailView(provider: provider)) {
                                ProviderRowView(provider: provider)
                            }
                        }
                    }
                }

                Spacer()

                HStack {
                    Button("Add Provider") {
                        showingAddProvider = true
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                    }
            }//end vstack

            .sheet(isPresented: $showingAddProvider) {
                AddProviderView()
            }
            .sheet(isPresented: $showingTypeManager){
                ServiceTypeListView()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Service It")
                        .font(.headline)
                }

            }
        }
    }
}


#Preview {
    let container = try! ModelContainer(
        for: ServiceProvider.self, ServiceRecord.self,
        configurations: .init(isStoredInMemoryOnly: true)
    )
    let context = container.mainContext
    let provider = ServiceProvider(name: "Preview Garage", contactInfo: "preview@garage.com")
     ContentView(provider: provider)
        .modelContainer(container)
}



