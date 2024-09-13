//
//  ContentView.swift
//  AirBoss
//
//  Created by Doug Haacke on 9/1/24.
//

import SwiftUI
import SwiftData
import MapKit
import Observation
import CoreLocation
import Combine

import AudioToolbox

struct ContentView: View {
    
    // MARK: - PROPERTIES
    //    @Environment(\.modelContext) private var modelContext
    //    @Query private var items: [Item]
    @Environment(LocationManager.self) var locationManager
    @State private var selectedHomeLocation: HomeLocation?
    @State private var isLoading = false
    
    @State private var position: MapCameraPosition = .automatic
    @State private var homeLocation: HomeLocation?
    @State private var currentLocation2D: CLLocationCoordinate2D?
    @State private var websocket = Websocket()
    @State private var adsb : ADSB = Bundle.main.decode("ADSB.json")
    
    
    // MARK: - FUNCTIONS
    func nothing() {
    }
    
    // MARK: - BODY
    var body: some View {
        TabView {
            Group {
                MapView()
                    .tabItem {
                    Label("Map", systemImage: "map")
                }
                .overlay (alignment: .topLeading) {
                    VStack {
                        if isLoading {
                             ProgressView()
                             Text("Loading...")
                        } else {
                            CurrentWeatherView()
                                .padding(.leading, 2)
                        }
                    }
                }
                CurrentWeatherView()
                    .tabItem {
                        Label("Weather", systemImage: "cloud.rain")
                    }
            }
            .toolbarBackground(.colorBlackDark.opacity(0.8), for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarColorScheme(.dark, for: .tabBar)
        }
        
//        ZStack {
//            // Color(.darkGray).ignoresSafeArea(.all, edges: .all)
//            GeometryReader { g in
//                VStack {
//                    MapView()
//                        .overlay (alignment: .topLeading) {
//                            VStack {
//                                if isLoading {
//                                     ProgressView()
//                                     Text("Loading...")
//                                } else {
//                                    CurrentWeatherView()
//                                        .padding(.leading, 2)
//                                }
//                            }
//                        }
//                }
//            }
//        }
        // .frame(width: visible ? .infinity : 0, height: visible ? .infinity : 0, alignment: .center)
//        .onReceive(Just(websocket.message)) { _ in
//            // print("---> Just onReceive message: \(websocket.message)")
//            // AudioServicesPlaySystemSound(1026)
//        }
        .onReceive(Just(websocket.adsb)) { _ in
            if websocket.adsb != nil {
                adsb = websocket.adsb!
            }
        }
        .task(id: locationManager.currentLocation) {
            isLoading = true
            if let currentLocation = locationManager.currentLocation {
                homeLocation = currentLocation
                currentLocation2D = currentLocation.location2D
                isLoading = false
            }
        }
    }
}


#Preview {
    // @State var adsb: ADSB = Bundle.main.decode("adsb.json")

    ContentView()
        .environment(LocationManager())
    //     .modelContainer(for: Item.self, inMemory: true)
}
