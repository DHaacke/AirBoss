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
    @Environment(\.modelContext) private var modelContext
    @Environment(LocationManager.self) var locationManager
    @Environment(WeatherManager.self) var weatherManager
    
    @State private var selectedHomeLocation: HomeLocation?
    @State private var isLoading = false
    @State var isShowingWeather = false
    @State var isShowingNotams = false

    
    @State private var position: MapCameraPosition = .automatic
    @State private var homeLocation: HomeLocation?
    @State private var currentLocation2D: CLLocationCoordinate2D?
//    @State private var websocket = Websocket()
//    @State private var adsb : ADSB?  // = Bundle.main.decode("ADSB.json")
   
    
    // MARK: - FUNCTIONS
    func nothing() {
    }
    
    // MARK: - BODY
    var body: some View {
        TabView {
            Group {
                MapView(isShowingNotams: isShowingNotams)
                    .tabItem {
                        Label("Map", systemImage: "map")
                    }
                    .overlay (alignment: .topLeading) {
                    VStack {
                        if isLoading {
                             ProgressView()
                             Text("  Loading...")
                        } else {
                            if isShowingWeather {
                                CurrentWeatherView(isShowingWeather: isShowingWeather)
                                    .padding(12)
                                    .onTapGesture {
                                        isShowingWeather.toggle()
                                    }
                            } else {
                                Image(systemName: weatherManager.currentWeatherSymbol )
                                    .renderingMode(.original)
                                    .symbolVariant(.fill)
                                    .font(.system(size: 30.0, weight: .bold))
                                    .padding(12)
                                    .onTapGesture {
                                        isShowingWeather.toggle()
                                    }
                            }
                        }
                        Image(systemName: "square.and.pencil" )
                            .renderingMode(.original)
                            .symbolVariant(.fill)
                            .font(.system(size: 30.0, weight: .bold))
                            .padding(.bottom, 0)
                            .onTapGesture {
                                isShowingNotams.toggle()
                            }
                        if isShowingNotams {
                            Text("Hide")
                                .padding(.top, 0)
                                .font(.system(size: 12.0, weight: .medium))
                        }
                        Text("Notams")
                            .padding(.top, 0)
                            .font(.system(size: 12.0, weight: .medium))
                    }
                    .padding(.top, 12)
                }
                
                CurrentWeatherView(isShowingWeather: true)
                    .tabItem {
                        Label("Weather", systemImage: "cloud.rain")
                    }
                
                ImportView(minimumDate: .now)
                    .tabItem {
                        Label("Import", systemImage: "square.and.arrow.down")
                    }
                
                IcaoTypeTableView()
                    .tabItem {
                        Label("ICAO Types", systemImage: "list.bullet.rectangle")
                    }

                AircraftTableView()
                    .tabItem {
                        Label("Aircraft", systemImage: "airplane")
                    }
                    
            }
            .toolbarBackground(.colorBlackDark.opacity(0.8), for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarColorScheme(.dark, for: .tabBar)
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
        .environment(WeatherManager())
    //     .modelContainer(for: Item.self, inMemory: true)
}
