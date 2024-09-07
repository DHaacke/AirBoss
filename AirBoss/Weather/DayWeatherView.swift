//
//  WeatherItemsView.swift
//  AirBoss
//
//  Created by Doug Haacke on 9/5/24.
//

import SwiftUI
import WeatherKit
import CoreLocation

struct DayWeatherView: View {
    // MARK: - PROPERTIES
    let weatherManager = WeatherManager.shared
    @Environment(LocationManager.self) var locationManager
    @State private var currentWeather: (CurrentWeather, Forecast<DayWeather>)?
    @State private var isLoading = false
    @State private var dayItems : [DayItem] = []
    
    @State private var selection: Int = 1
    
    struct DayItem: Identifiable  {
        let title: String
        let value: String
        let id = UUID()
        
    }

    // MARK: - FUNCTIONS
    func populateTableItems(current: (CurrentWeather, Forecast<DayWeather>)?) {
        var tempRangeLow: String = ""
        var tempRangeHigh: String = ""
        var altimeter: String = ""
        var wind: String = ""
        var gusts: String = ""
        var windDir: String = ""
        var lat: String = ""
        var lon: String = ""
        
        if let c = current {
            if let _tempRangeLow = c.1.first?.lowTemperature {
                tempRangeLow = ((_tempRangeLow.value * 9/5) + 32).format(suffix: "°", decimals: 0)
            }
            if let _tempRangeHigh = c.1.first?.highTemperature {
                tempRangeHigh = ((_tempRangeHigh.value * 9/5) + 32).format(suffix: "°", decimals: 0)
            }
            altimeter = (c.0.pressure.value * 0.0295301).format(suffix: "", decimals: 2)
            if let _wind = c.1.first?.wind.speed {
                wind = _wind.converted(to: .milesPerHour).value.format(suffix: "mph", decimals: 0)
            }
            if let _gusts = c.1.first?.wind.gust {
                gusts = _gusts.converted(to: .milesPerHour).value.format(suffix: "mph", decimals: 0)
            }
            if let _windDir = c.1.first?.wind.compassDirection.abbreviation {
                windDir = _windDir
            }
            if let _lat = locationManager.currentLocation?.latitude {
                lat = _lat.format(suffix: "", decimals: 6)
            }
            if let _lon = locationManager.currentLocation?.longitude {
                lon = _lon.format(suffix: "", decimals: 6)
            }
            
            dayItems = []
            dayItems.append(DayItem(title: "Temp Range",  value: "L: \(tempRangeLow)  H: \(tempRangeHigh)"))
            dayItems.append(DayItem(title: "Altimeter",   value: "\(altimeter)"))
            dayItems.append(DayItem(title: "Wind",        value: "\(wind) \(windDir)"))
            dayItems.append(DayItem(title: "Gusts",       value: "\(gusts)"))
            dayItems.append(DayItem(title: "Lat",         value: "\(lat)"))
            dayItems.append(DayItem(title: "Lon",         value: "\(lon)"))

        }
    }
    
    // MARK: - BODY
    var body: some View {
        
        VStack {
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(.accent)
                .frame(width: 228, height: 208)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(gradient: Gradient(colors: [Color.colorGrayLight, Color.colorBlackDark]), startPoint: .top, endPoint: .bottom)
                        )
                        // .foregroundColor(.black)
                        .frame(width: 220, height: 200)
                        
                        .overlay(
                            VStack {
                                if isLoading {
                                    ProgressView()
                                    Text("Fetching Weather")
                                } else {
                                    ForEach(dayItems) { item in
                                        HStack {
                                            Text(item.title).font(.caption).fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                            Spacer()
                                            Text(item.value).font(.caption)
                                        }
                                    }
                                }
                            }
                                .padding()
                                .frame(width: 220)
                        )
                )
                .offset(x: 4, y: 4)
        }
        .padding()
        .frame(width: 228)
        .task {
            Task.detached { @MainActor in
                if let lat = locationManager.currentLocation?.latitude, let lon = locationManager.currentLocation?.longitude {
                    currentWeather = await weatherManager.currentWeather(for: CLLocation(latitude: lat, longitude: lon))
                    populateTableItems(current: currentWeather)
                }
            }
            isLoading = false
        }

            

    }
}

#Preview {
    DayWeatherView()
        .environment(LocationManager())
    
}


/*
let styles: [UIFont.TextStyle] = [
    // iOS 17
    .extraLargeTitle, .extraLargeTitle2,
    // iOS 11
    .largeTitle,
    // iOS 9
    .title1, .title2, .title3, .callout,
    // iOS 7
    .headline, .subheadline, .body, .footnote, .caption1, .caption2,
*/
