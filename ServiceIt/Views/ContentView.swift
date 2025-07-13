//
//  ContentView.swift
//  ServiceIt
//
//  Created by Jacob Filek on 7/12/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
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
                    
                    Button("Manage Types") {
                        showingTypeManager = true}
                        .buttonStyle(.borderedProminent)
                        .padding()
                    }
                
            }//end vstack

            .sheet(isPresented: $showingAddProvider) {
                AddProviderFormView()
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ServiceRecordListView()) {
                        Image(systemName: "magnifyingglass")
                    }
                }
            }
        }
    }
}


#Preview {
    ContentView()
}


