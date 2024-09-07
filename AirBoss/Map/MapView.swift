//
//  MapView.swift
//  AirBoss
//
//  Created by Doug Haacke on 9/4/24.
//

import SwiftUI
import MapKit
import WeatherKit

extension CLLocationCoordinate2D {
    static let home = CLLocationCoordinate2D(latitude: 45.79208074322167, longitude: -108.56983021630413)
}

struct MapView: View {
    // MARK: - PROPERTIES
    // 45.79208074322167, -108.56983021630413
    @Environment(LocationManager.self) var locationManager
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 45.79208074322167, longitude: -108.56983021630413), span: MKCoordinateSpan(latitudeDelta: 8.0, longitudeDelta: 8.0))
    @State private var position: MapCameraPosition = .automatic
    @State private var visibleRegion: MKCoordinateRegion?
    
    let weatherManager = WeatherManager.shared
    
    @State private var currentWeather: (CurrentWeather, Forecast<DayWeather>)?
    @State private var isLoading = false

    // MARK: - BODY
    
    var body: some View {
        VStack {
            Map(position: $position) {
                // Map(coordinateRegion: $region)
                Marker("Home", coordinate: .home)
            } //: NAVIGATION
            .mapStyle(.standard(elevation: .flat))
//            .safeAreaInset(edge: .bottom) {
//                
//            }
        }
        .frame(minWidth: 400, idealWidth: 800, maxWidth: 900, minHeight: 800, idealHeight: 1200, maxHeight: 1300)
        .cornerRadius(12)
        .overlay (alignment: .topLeading) {
            ZStack {
                if isLoading == true {
                    ProgressView()
                } else {
                    if let currentWeather {
                        Text("Howdy")
                        Text("\(Date.now.formatted(date: .abbreviated, time: .omitted)), \(Date.now.formatted(date: .omitted, time: .shortened))")
                            .foregroundColor(.white)
                        Image(systemName: currentWeather.0.symbolName)
                            .renderingMode(.original)
                            .symbolVariant(.fill)
                            .font(.system(size: 36.0, weight: .bold))
                            .padding()
                        let temp = String(describing: ((currentWeather.0.temperature.value * 9/5) + 32).format(suffix: "°", decimals: 0))
                        Text(temp)
                            .font(.title2)
                            .foregroundColor(.white)
                        Text(currentWeather.0.condition.description)
                            .font(.title3)
                            .foregroundColor(.white)
                        AttributionView()
                    }
                }
            }
        }
        .task {
            Task.detached { @MainActor in
                isLoading = true
                if let lat = locationManager.currentLocation?.latitude, let lon = locationManager.currentLocation?.longitude {
                    currentWeather = await weatherManager.currentWeather(for: CLLocation(latitude: lat, longitude: lon))
                }
                isLoading = false
            }
        }
    }
}

#Preview {
    MapView()
        .environment(LocationManager())
}
