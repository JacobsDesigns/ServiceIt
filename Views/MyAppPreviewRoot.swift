struct MyAppPreviewRoot: View {
    var body: some View {
        TabView {
            GarageView()
                .tabItem {
                    Label("Garage", systemImage: "car.fill")
                }
            AllRecordsView()
                .tabItem {
                    Label("Service Records", systemImage: "list.bullet")
                }
            ServiceScheduleView()
                .tabItem {
                    Label("Schedule", systemImage: "calendar")
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .modelContainer(PreviewContainer.shared)
    }
}
