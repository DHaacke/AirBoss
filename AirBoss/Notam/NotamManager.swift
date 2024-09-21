 //
//  NotamManager.swift
//  AirBoss
//
//  Created by Doug Haacke on 9/8/24.
//

import Foundation
import CoreLocation

@Observable
class NotamManager: NSObject {
    
    // 45.79208074322167, -108.56983021630413
    // https://external-api.faa.gov/notamapi/v1/notams?locationLatitude=45.79208074322167&locationLongitude=-108.56983021630413&locationRadius=300&featureType=AIRSPACE&classification=FDC&notamType=N
    func getNotams(latitude: Double, longitude: Double, radius: Double = 100) async throws -> [NotamData]? {
        let clientId        =  "2fa29850d579473fa93da9716f16f9b9"
        let clientSecret    =  "190eDFe8A0f9468cbC90687742A912C2"
        
        let url = URL(string: "https://external-api.faa.gov/notamapi/v1/notams?locationLatitude=\(latitude)&locationLongitude=\(longitude)&locationRadius=\(radius)&featureType=AIRSPACE&classification=FDC&notamType=N")!
        var request = URLRequest(url: url)
        request.setValue("application/json",forHTTPHeaderField: "Content-Type")
        request.setValue(clientId,          forHTTPHeaderField: "client_id")
        request.setValue(clientSecret,      forHTTPHeaderField: "client_secret")
        request.httpMethod = "GET"
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request as URLRequest)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                print("NOTAM: There was an error trying \(url)")
                return nil
            }
            let notamModel = try JSONDecoder().decode(NotamModel.self, from: data)
            if let items = notamModel.items {
                return await processNotams(items: items, latitude: latitude, longitude: longitude, radius: radius)
            } else {
                return nil
            }
            
        } catch let DecodingError.dataCorrupted(context) {
            print("JSON: \(context)")
        } catch let DecodingError.keyNotFound(key, context) {
            print("JSON Key '\(key)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.valueNotFound(value, context) {
            print("JSON Value '\(value)' not found:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch let DecodingError.typeMismatch(type, context)  {
            print("JSON Type '\(type)' mismatch:", context.debugDescription)
            print("codingPath:", context.codingPath)
        } catch {
            print("JSON error: ", error)
        }
        return nil
    }
    
    func processNotams(items: [Item], latitude: Double, longitude: Double, radius: Double) async -> [NotamData] {
        var notamArray : [NotamData] = []

        for item in items {
            let id                  = item.properties.coreNOTAMData.notam.id
            let number              = item.properties.coreNOTAMData.notam.number
            let type                = item.properties.coreNOTAMData.notam.type
            let issued              = item.properties.coreNOTAMData.notam.issued
            let location            = item.properties.coreNOTAMData.notam.location
            let effectiveStart      = item.properties.coreNOTAMData.notam.effectiveStart
            let effectiveEnd        = item.properties.coreNOTAMData.notam.effectiveEnd
            var text                = item.properties.coreNOTAMData.notam.text.replacingOccurrences(of: "\n", with: " ", options: NSString.CompareOptions.literal, range: nil)
            let classification      = item.properties.coreNOTAMData.notam.classification
            let accountId           = item.properties.coreNOTAMData.notam.accountId
            let lastUpdated         = item.properties.coreNOTAMData.notam.lastUpdated
            let icaoLocation        = item.properties.coreNOTAMData.notam.icaoLocation
            let schedule            = item.properties.coreNOTAMData.notam.schedule
            let notamTranslation    = item.properties.coreNOTAMData.notamTranslation
            let geometryType        = item.geometry.type
            let geometries          = item.geometry.geometries
            var coordinate : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
            var distance :Double = 0
            var freq: String = ""
            var gps: String = ""
            var polygons: [CLLocationCoordinate2D] = []
            
            if text.contains("FREQ") {
                let inputString = text
                let pattern = "FREQ ?[0-9]{3}\\.[0-9]{1,4}"
                if let regex = try? NSRegularExpression(pattern: pattern) {
                    let matches = regex.matches(in: inputString, range: NSRange(inputString.startIndex..., in: inputString))
                    let matchStrings = matches.map { match in
                      String(inputString[Range(match.range, in: inputString)!])
                    }
                    // print("Match strings: \(matchStrings)")
                    freq = matchStrings.joined()
                    // print(freq)
                }
            }
            
            if let geoArray = geometries {
                if geoArray.count > 0 {
                    let geo = geoArray[0]
                    // get the first one for our fire location
                    if let coordsArray = geo.coordinates {
                        let revCoord = coordsArray[0][0] as CLLocationCoordinate2D
                        coordinate = CLLocationCoordinate2D(latitude: revCoord.longitude, longitude: revCoord.latitude)
                        let target = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
                        let home   = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        distance = home.distance(to: target)
                        gps = "\(target.latitude), \(target.longitude)"
                        text += "\nGPS:  \(target.latitude), \(target.longitude)\nDistance away: \(distance.metersToMiles().format(suffix: " miles", decimals: 0))"
                        // print("Distance away: \(distance.metersToMiles())mi")
                    }
                    // build the polygons array
                    if let geoArray = geometries {
                        for geo in geoArray {
                            if let coordsArrayBase = geo.coordinates {
                                polygons = []
                                for coordsArray in coordsArrayBase  {
                                    for (_, coords) in coordsArray.enumerated() {
                                        let swiftCoords : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: coords.longitude, longitude: coords.latitude)
                                        polygons.append(swiftCoords)
                                    }
                                }
                            }
                        }
                    }
                }
            }
                        
            // print("NOTAM:  \(text)")
//            print("NOTAM:  \(polygons)")
//            print("----------------------")
            
            if distance.metersToMiles() > 0 {
                // print("NOTAM in \(distance.metersToMiles().format(suffix: " miles", decimals: 0)) range at \(coordinate.latitude), \(coordinate.longitude)")
                let notam = NotamData(id: id, number: number, type: type, issued: issued, location: location, effectiveStart: effectiveStart, effectiveEnd: effectiveEnd, text: text, classification: classification, accountId: accountId, lastUpdated: lastUpdated, icaoLocation: icaoLocation, schedule: schedule, notamTranslation: notamTranslation, geometryType: geometryType, geometries: geometries, coordinate: coordinate, distance: distance.metersToMiles(), freq: freq, gps: gps, polygons: polygons)
                notamArray.append(notam)
                // print(notam)
            } else {
                // print("NOTAM out of range (\(radius):  \(coordinate.latitude), \(coordinate.longitude))")
            }
                        
        }
        return notamArray
    }
}
