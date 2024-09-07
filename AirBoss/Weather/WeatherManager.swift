//
//  WeatherManager.swift
//  AirBoss
//
//  Created by Doug Haacke on 9/5/24.
//

// Buy me a ko-fi:  https://ko-fi.com/StewartLynch


import Foundation
import WeatherKit
import CoreLocation

class WeatherManager {
    static let shared = WeatherManager()
    let service = WeatherService.shared
    
    func currentWeather(for location: CLLocation) async -> (CurrentWeather, Forecast<DayWeather>)? {
        let currentWeather = await Task.detached(priority: .userInitiated) {
            let forecast = try? await self.service.weather(
                for: location,
                including: .current, .daily
            )
            return forecast
        }.value
        return currentWeather
    }
    
    func weatherAttribution() async -> WeatherAttribution? {
        let attribution = await Task(priority: .userInitiated) {
            return try? await self.service.attribution
        }.value
        return attribution
    }
}

