//
//  WeatherView.swift
//  AirBoss
//
//  Created by Doug Haacke on 9/4/24.
//

import SwiftUI
import WeatherKit
import CoreLocation

struct CurrentWeatherView: View {
    // MARK: - PROPERTIES
    let weatherManager = WeatherManager.shared
    @Environment(LocationManager.self) var locationManager
    @State private var currentWeather: (CurrentWeather, Forecast<DayWeather>)?
    @State private var isLoading = false

    // MARK: - FUNCTIONS
    
    // MARK: - BODY
    var body: some View {
        ZStack {
            // WeatherBackgroundView()
            VStack {
                if isLoading {
                    ProgressView()
                    Text("Fetching Weather")
                } else {
                    if let currentWeather {
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
            .padding(.horizontal, 10)
            .task {
                Task.detached { @MainActor in
                    if let lat = locationManager.currentLocation?.latitude, let lon = locationManager.currentLocation?.longitude {
                        currentWeather = await weatherManager.currentWeather(for: CLLocation(latitude: lat, longitude: lon))
                    }
                }
                isLoading = false
            }
        }
        .frame(width: 220, height: 220)
    }
}

#Preview {
    CurrentWeatherView()
        .environment(LocationManager())
}


/*
 
 Text("Some text can go here and can be long if needed.")
   .multilineTextAlignment(.leading)
   .italic()
   .foregroundColor(.customGrayMedium)
 
 */
