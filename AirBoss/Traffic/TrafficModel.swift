//
//  TrafficModel.swift
//  AirBoss
//
//  Created by Doug Haacke on 9/15/24.
//

import Foundation
import CoreLocation
import MapKit
import SwiftUI

enum PriorityType {
    case none, emergency, lifeguard, minfuel, nocomm, interference, downed, unknown
}

@Observable
class TrafficModel {
    var icaoAddress: Int64
    var callSign: String
    var regNo: String
    var priority: Int
    var onGround: Bool
    var squawk: Int
    dynamic var lat: Double
    dynamic var lon: Double
    var altitude: Int
    var course: Int
    var speed: Int
    var distance: Int
    var bearing: Int
    var vvel : Int
    var turnRate: Int
    
    var icao_type: String
    var manufacturer: String
    var model: String
    var icon: String
    var altIcon: String
    var alert: String
    var owner: String
    
    var timeStamp: Int64
    
    var homeLocation: CLLocationCoordinate2D
    var homeElevation: Int
    
       
    init(icaoAddress: Int64, callSign: String, regNo: String, priority: Int, onGround: Bool, squawk: Int, lat: Double, lon: Double, altitude: Int, course: Int, speed: Int, distance: Int, bearing: Int, vvel: Int, turnRate: Int, icao_type: String, manufacturer: String, model: String, icon: String, altIcon: String, alert: String, owner: String, timeStamp: Int64, homeLocation: CLLocationCoordinate2D, homeElevation: Int) {
        self.icaoAddress = icaoAddress
        self.callSign = callSign
        self.regNo = regNo
        self.priority = priority
        self.onGround = onGround
        self.squawk = squawk
        self.lat = lat
        self.lon = lon
        self.altitude = altitude
        self.course = course
        self.speed = speed
        self.distance = distance
        self.bearing = bearing
        self.vvel = vvel
        self.turnRate = turnRate
        self.icao_type = icao_type
        self.manufacturer = manufacturer
        self.model = model
        self.icon = icon
        self.altIcon = altIcon
        self.alert = alert
        self.owner = owner
        self.timeStamp = timeStamp
        self.homeLocation = homeLocation
        self.homeElevation = homeElevation
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    var distanceMiles: Double {
        return homeLocation.distance(to: coordinate)
    }
    var icaoHex: String {
        String(icaoAddress, radix: 16)
    }
    
    var formattedDistance: String {
        return distanceMiles < 100 ? distanceMiles.format(suffix: " mi", decimals: 1) : "--"
    }
    var formattedBearing: String {
        return "\(String(format: "%3d", bearing))°"
    }
    var formattedAltitude: String {
        return altitude.format(suffix: " ft")
    }
    var formattedAltitudeVVel: String {
        var arrow = ""
        if vvel > 50 {
            arrow = "↑"
        } else if vvel < -50 {
            arrow = "↓"
        }
        return arrow + altitude.format(suffix: " ft")
    }
    var formattedSquawk: String {
        return String(format: "%04d", squawk)
    }
    var formattedCourse: String {
        return course > 0 ? "\(String(format: "%03d", course))°" : "--"
    }
    var formattedPriority: String {
        return "\(getAircraftPriority(priority: priority))"
    }
    var formattedVVel: String {
        if vvel > 0 {
            return "+\(vvel) fpm"
        } else  {
          return "\(vvel) fpm"
        }
    }
    var formattedGroundSpeed: String {
        return String(format: "%d kts", speed)
    }
    var formattedAGL: String {
        return (altitude - homeElevation).format(suffix: " ft AGL")
    }
    var callSignTrimmed: String {
        return String(callSign.prefix(5))
    }
    
    
    func getAircraftPriority(priority: Int) -> String {
        switch priority {
            case 0:
                return ""  // no emergency
            case 1:
                return "Emergency"
            case 2:
                return "Lifeguard"
            case 3:
                return "Minimum fuel"
            case 4:
                return "No communications"
            case 5:
                return "Unlawful interference"
            case 6:
                return "Downed aircraft"
            default:
                return "Unknown emergency"
        }
    }
}


