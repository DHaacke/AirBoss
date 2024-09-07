//
//  CLLocation+Extensions.swift
//  Air Boss
//
//  Created by Doug Haacke on 8/12/22.
//

import Foundation
import CoreLocation

extension CLLocation {
    func bearingTo(to: CLLocation) -> Int {
        let lat1 = degreesToRadians(degrees: self.coordinate.latitude)
        let lon1 = degreesToRadians(degrees: self.coordinate.longitude)

        let lat2 = degreesToRadians(degrees: to.coordinate.latitude)
        let lon2 = degreesToRadians(degrees: to.coordinate.longitude)

        let dLon = lon2 - lon1

        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        
        var bearing = Int(radiansToDegrees(radians: radiansBearing))
        if bearing < 0 {
            bearing += 360
        } else if bearing > 360 {
            bearing -= 360
        }
        return bearing
    }
    func degreesToRadians(degrees: Double) -> Double {
        return degrees * .pi / 180.0
    }
    func radiansToDegrees(radians: Double) -> Double {
        return radians * 180.0 / .pi
    }
    /// SwifterSwift: Calculate the half-way point along a great circle path between the two points.
    ///
    /// - Parameters:
    ///   - start: Start location.
    ///   - end: End location.
    /// - Returns: Location that represents the half-way point.
    static func midLocation(start: CLLocation, end: CLLocation) -> CLLocation {
        let lat1 = Double.pi * start.coordinate.latitude / 180.0
        let long1 = Double.pi * start.coordinate.longitude / 180.0
        let lat2 = Double.pi * end.coordinate.latitude / 180.0
        let long2 = Double.pi * end.coordinate.longitude / 180.0

        // Formula
        //    Bx = cos φ2 ⋅ cos Δλ
        //    By = cos φ2 ⋅ sin Δλ
        //    φm = atan2( sin φ1 + sin φ2, √(cos φ1 + Bx)² + By² )
        //    λm = λ1 + atan2(By, cos(φ1)+Bx)
        // Source: http://www.movable-type.co.uk/scripts/latlong.html
        let bxLoc = cos(lat2) * cos(long2 - long1)
        let byLoc = cos(lat2) * sin(long2 - long1)
        let mlat = atan2(sin(lat1) + sin(lat2), sqrt((cos(lat1) + bxLoc) * (cos(lat1) + bxLoc) + (byLoc * byLoc)))
        let mlong = long1 + atan2(byLoc, cos(lat1) + bxLoc)

        return CLLocation(latitude: mlat * 180 / Double.pi, longitude: mlong * 180 / Double.pi)
    }
    func toLocationCoordinate2d() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.coordinate.latitude, longitude: self.coordinate.longitude)
    }
   
}
