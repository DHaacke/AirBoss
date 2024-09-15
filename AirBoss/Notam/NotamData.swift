//
//  NotamData.swift
//  AirBoss
//
//  Created by Doug Haacke on 9/11/24.
//

import Foundation
import CoreLocation

struct NotamData {
    
    let id: String
    let number: String
    let type: String
    let issued: String
    let location: String
    let effectiveStart: String
    let effectiveEnd: String
    let text: String
    let classification: String
    let accountId: String
    let lastUpdated: String
    let icaoLocation: String
    let schedule: String?
    let notamTranslation: [NotamTranslation]?
    let geometryType : String?
    let geometries : [Geometries]?
    var coordinate: CLLocationCoordinate2D
    var distance: Double = 0
    var freq: String = ""
    var gps: String = ""
    var polygons: [CLLocationCoordinate2D]
    
    var formattedEffectiveStart : String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sssZ"
        if let date = dateFormatter.date(from: effectiveStart) {
            dateFormatter.dateFormat = "MM/dd/YY HH:mm"
            return dateFormatter.string(from: date)
        } else {
            return effectiveStart
        }
    }
    
    var formattedEffectiveEnd : String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sssZ"
        if let date = dateFormatter.date(from: effectiveEnd) {
            dateFormatter.dateFormat = "MM/dd/YY HH:mm"
            return dateFormatter.string(from: date)
        } else {
            return effectiveEnd
        }
    }
    
    var shortNotamText : String {
        return text
    }
    
    var longNotamText : String {
        return text
    }
}
