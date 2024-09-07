//
//  WeatherItemsView.swift
//  AirBoss
//
//  Created by Doug Haacke on 9/5/24.
//

import SwiftUI
import WeatherKit
import CoreLocation

struct WeatherItemsView: View {
    // MARK: - PROPERTIES
    let weatherManager = WeatherManager.shared
    @State private var currentWeather: CurrentWeather?
    @State private var dayWeather: Forecast<DayWeather>?
    @State private var isLoading = false
    @State private var dayItems : [DayItem] = []
    
    @State private var selection: Int = 1
    
    struct DayItem: Identifiable  {
        let title: String
        let value: String
        let suffix: String
        let id = UUID()
        
    }

    // MARK: - FUNCTIONS
    func populateTableItems(c: CurrentWeather, d: Forecast<DayWeather>) {
        dayItems = []
        dayItems.append(DayItem(title: "Temp Range",
                                value: "L: \(String(describing: d.first?.lowTemperature))  H: \(String(describing: d.first?.highTemperature))",
                                suffix: "°"))
        dayItems.append(DayItem(title: "Altimeter",
                                value: "\(c.pressure * 0.0295301)",
                                suffix: "°"))
        dayItems.append(DayItem(title: "Wind",
                                value:  "\(String(describing: d.first?.wind.speed)))",
                                suffix: "mph"))
        if let gusts = d.first?.wind.gust {
            dayItems.append(DayItem(title: "Gusts",
                                value:  "\(String(describing: gusts))",
                                suffix: "mph"))
        }
        print("Size: \(dayItems.count)")
        
    }
    
    // MARK: - BODY
    var body: some View {
        ZStack {
            WeatherBackgroundView()
            VStack {
                if isLoading {
                    ProgressView()
                    Text("Fetching Weather")
                } else {
                    Table(dayItems) {
                        TableColumn("Name", value: \.title).alignment(.leading)
                        TableColumn("Value", value: \.value).alignment(.trailing)
                        TableColumn("", value: \.suffix).alignment(.leading)
                    }
                    .foregroundColor(.white)
                    
                }
            }
            .padding(.horizontal, 10)
            .task {
//                Task.detached { @MainActor in
//                    currentWeather = await weatherManager.currentWeather(for: CLLocation(latitude: 45.79217051314525, longitude: -108.56978730094518))
//                }
                Task.detached { @MainActor in
                    dayWeather = await weatherManager.dayWeather(for: CLLocation(latitude: 45.79217051314525, longitude: -108.56978730094518))
                }
                isLoading = false
                if currentWeather != nil && dayWeather != nil {
                    print("Done!")
                    populateTableItems(c: currentWeather!, d: dayWeather!)
                }
            }
        }
        .frame(width: 220, height: 220)
    }
}

#Preview {
    WeatherItemsView()
}
