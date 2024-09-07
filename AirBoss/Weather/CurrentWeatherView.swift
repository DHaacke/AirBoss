//
//  WeatherView.swift
//  AirBoss
//
//  Created by Doug Haacke on 9/4/24.
//

import SwiftUI
import WeatherKit
import CoreLocation

struct WeatherView: View {
    // MARK: - PROPERTIES
    let weatherManager = WeatherManager.shared
    @State private var currentWeather: CurrentWeather?
    @State private var dayWeather: Forecast<DayWeather>?
    @State private var isLoading = false

    // MARK: - FUNCTIONS
    
    // MARK: - BODY
    var body: some View {
        ZStack {
            WeatherBackgroundView()
            VStack {
                if isLoading {
                    ProgressView()
                    Text("Fetching Weather")
                } else {
                    if let currentWeather {
                        Text("\(Date.now.formatted(date: .abbreviated, time: .omitted)), \(Date.now.formatted(date: .omitted, time: .shortened))")
                            .foregroundColor(.white)
                        Image(systemName: currentWeather.symbolName)
                            .renderingMode(.original)
                            .symbolVariant(.fill)
                            .font(.system(size: 36.0, weight: .bold))
                            .padding()
                        let temp = weatherManager.temperatureFormatter.string(from: currentWeather.temperature)
                        Text(temp)
                            .font(.title2)
                            .foregroundColor(.white)
                        Text(currentWeather.condition.description)
                            .font(.title3)
                            .foregroundColor(.white)
                        AttributionView()
                    }
                }
            }
            .padding(.horizontal, 10)
//            .task {
//                Task.detached { @MainActor in
//                  currentWeather = await weatherManager.currentWeather(for: CLLocation(latitude: 45.79217051314525, longitude: -108.56978730094518))
//                }
//                isLoading = false
//            }
            .task {
                Task.detached { @MainActor in
                    currentWeather = await weatherManager.currentWeather(for: CLLocation(latitude: 45.79217051314525, longitude: -108.56978730094518))
                }
                isLoading = false
            }
        }
        .frame(width: 220, height: 220)
    }
}

#Preview {
    WeatherView()
}


/*
 
 Text("Some text can go here and can be long if needed.")
   .multilineTextAlignment(.leading)
   .italic()
   .foregroundColor(.customGrayMedium)
 
 */
