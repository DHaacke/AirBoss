//
//  AirBossApp.swift
//  AirBoss
//
//  Created by Doug Haacke on 9/1/24.
//

import SwiftUI
import SwiftData

@main
struct AirBossApp: App {
    @State private var locationManager = LocationManager()
    @State private var weatherManager = WeatherManager()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
           Aircraft.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            if locationManager.isAuthorized {
                ContentView()
            } else {
                LocationDeniedView()
            }
            
        }
        .environment(locationManager)
        .environment(weatherManager)
        .modelContainer(sharedModelContainer)
    }
}
