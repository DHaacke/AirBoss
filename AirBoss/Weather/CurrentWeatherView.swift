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
    var isShowingWeather: Bool
    
    let weatherManager = WeatherManager.shared
    @Environment(LocationManager.self) var locationManager
   
    @State private var homeLocation: HomeLocation?
    @State private var currentWeather: (CurrentWeather, Forecast<DayWeather>)?
    @State private var isLoading = false
    @State private var dayItems : [DayItem] = []
    @State private var selectedHomeLocation: HomeLocation?

    
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
        var densityAlt: String = ""
        var wind: String = ""
        var gusts: String = ""
        var windDir: String = ""
        var cloudCover : String = ""
        var dewpoint : String = ""
        var humidity : String = ""
        var precip: String = ""
        var snow: String = ""
        var moonphase : String = ""
        var sunrise : String = ""
        var sunset : String = ""
        
        if let c = current {
            if let _tempRangeLow = c.1.first?.lowTemperature {
                tempRangeLow = ((_tempRangeLow.value * 9/5) + 32).format(suffix: "°", decimals: 0)
            }
            if let _tempRangeHigh = c.1.first?.highTemperature {
                tempRangeHigh = ((_tempRangeHigh.value * 9/5) + 32).format(suffix: "°", decimals: 0)
            }
            altimeter = (c.0.pressure.value * 0.0295301).format(suffix: "", decimals: 2)  // 1,010.8330144497
            if let _alt = locationManager.currentLocation?.altitude.magnitude {
                densityAlt = ((((c.0.pressure.value * 0.0295301) - 29.92) * 1000) + _alt).format(suffix: "ft", decimals: 0)
            }

            if let _wind = c.1.first?.wind.speed {
                wind = _wind.converted(to: .milesPerHour).value.format(suffix: "mph", decimals: 0)
            }
            if let _gusts = c.1.first?.wind.gust {
                gusts = _gusts.converted(to: .milesPerHour).value.format(suffix: "mph", decimals: 0)
            }
            if let _windDir = c.1.first?.wind.compassDirection.abbreviation {
                windDir = _windDir
            }
            cloudCover = (c.0.cloudCover.magnitude * 100).format(suffix: "%", decimals: 0)
            dewpoint   = c.0.dewPoint.converted(to: .fahrenheit).value.format(suffix: "°", decimals: 2)
            humidity   = (c.0.humidity.magnitude * 100).format(suffix: "%", decimals: 2)
            if let _precip = c.1.first?.precipitationAmount.value {
                precip = _precip.format(suffix: "in", decimals: 1)
            }
            if let _snow = c.1.first?.snowfallAmount.value {
                snow = _snow.format(suffix: "in", decimals: 1)
            }
            if let _moonphase = c.1.first?.moon.phase.description {
                moonphase = _moonphase
            }
            if let _sunrise = c.1.first?.sun.civilDawn?.timeIntervalSince1970 {
                sunrise = Date(timeIntervalSince1970: _sunrise).formatted(date: .omitted, time: .shortened)
            }
            if let _sunset = c.1.first?.sun.civilDusk?.timeIntervalSince1970 {
                sunset = Date(timeIntervalSince1970: _sunset).formatted(date: .omitted, time: .shortened)
            }
            
            dayItems = []
            dayItems.append(DayItem(title: "Temp Range",  value: "L: \(tempRangeLow)  H: \(tempRangeHigh)"))
            dayItems.append(DayItem(title: "Altimeter",   value: "\(altimeter)"))
            dayItems.append(DayItem(title: "Density Alt", value: "\(densityAlt)"))
            dayItems.append(DayItem(title: "Wind",        value: "\(windDir) at \(wind)"))
            dayItems.append(DayItem(title: "Gusts",       value: "\(gusts)"))
            dayItems.append(DayItem(title: "Cloud cover", value: "\(cloudCover)"))
            dayItems.append(DayItem(title: "Dew point",   value: "\(dewpoint)"))
            dayItems.append(DayItem(title: "Humidity",    value: "\(humidity)"))
            dayItems.append(DayItem(title: "Precip",      value: "\(precip)"))
            dayItems.append(DayItem(title: "Snowfall",    value: "\(snow)"))
            dayItems.append(DayItem(title: "Moon phase",  value: "\(moonphase)"))
            dayItems.append(DayItem(title: "Sunrise",     value: "\(sunrise)"))
            dayItems.append(DayItem(title: "Sunset",      value: "\(sunset)"))
        }
    }
    
    // MARK: - BODY
    var body: some View {
        if isShowingWeather {
            ZStack {
                VStack {
                    Color.customBlackLight
                        .cornerRadius(20)
                        .opacity(0.50)
                }
                if isLoading {
                    ProgressView()
                    Text("Fetching Weather")
                } else {
                    VStack {
                        if let currentWeather {
                            AttributionView()
                            Image(systemName: currentWeather.0.symbolName)
                                .renderingMode(.original)
                                .symbolVariant(.fill)
                                .font(.system(size: 30.0, weight: .bold))
                            let temp = String(describing: ((currentWeather.0.temperature.value * 9/5) + 32).format(suffix: "°", decimals: 0))
                            Text(temp)
                                .font(.title2)
                                .foregroundColor(.white)
                                .shadow(color: .colorBlackDark, radius: 2, x: 1, y: 1)
                            Text(currentWeather.0.condition.description)
                                .font(.caption)
                                .foregroundColor(.white)
                                .shadow(color: .colorBlackDark, radius: 2, x: 1, y: 1)
                            Divider().overlay(.gray)
                            if let name = selectedHomeLocation?.name {
                                Text(name)
                            }
                            let elevation = (locationManager.currentLocation?.altitude.magnitude ?? 0.0).format(suffix: "ft", decimals: 0)
                            Text("Elevation: \(elevation)")
                                .font(.footnote)
                            
                            ForEach(dayItems) { item in
                                HStack {
                                    Text(item.title).font(.caption).fontWeight(.semibold)
                                        .shadow(color: .colorBlackDark, radius: 2, x: 1, y: 1)
                                    Spacer()
                                    Text(item.value).font(.caption)
                                        .shadow(color: .colorBlackDark, radius: 2, x: 1, y: 1)
                                }
                                
                            }
                        }
                    }
                    .padding()
                }
            }
            .frame(width: 260, height: 380)
            .task {
                Task.detached { @MainActor in
                    if let lat = locationManager.currentLocation?.latitude, let lon = locationManager.currentLocation?.longitude {
                        currentWeather = await weatherManager.currentWeather(for: CLLocation(latitude: lat, longitude: lon))
                        homeLocation = locationManager.currentLocation
                        populateTableItems(current: currentWeather)
                    }
                }
                isLoading = false
            }
            .task(id: locationManager.currentLocation) {
                if let currentLocation = locationManager.currentLocation, selectedHomeLocation == nil {
                    selectedHomeLocation = currentLocation
                }
            }
            .task(id: selectedHomeLocation) {
                if let selectedHomeLocation {
                    await fetchWeather(for: selectedHomeLocation)
                }
            }
        }
    }
    
    func fetchWeather(for homeLocation: HomeLocation) async {
        isLoading = true
        Task.detached { @MainActor in
            currentWeather = await weatherManager.currentWeather(for: homeLocation.clLocation)
        }
        isLoading = false
    }
    
}

#Preview {
    CurrentWeatherView(isShowingWeather: false)
        .environment(LocationManager())
}


/*
 
 Text("Some text can go here and can be long if needed.")
   .multilineTextAlignment(.leading)
   .italic()
   .foregroundColor(.customGrayMedium)
 
 */
