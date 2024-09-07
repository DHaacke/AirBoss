//
//  ADSB.swift
//  AirBoss
//
//  Created by Doug Haacke on 9/1/24.
//

import Foundation
import Swift

struct ADSB: Codable {
    var Icao_addr: Int64
    var Reg: String
    var Tail: String
    var Emitter_category: Int
    var SurfaceVehicleType: Int
    var OnGround: Bool
    var Addr_type: Int
    var TargetType: Int
    var SignalLevel: Double
    var SignalLevelHist: [Double]
    var Squawk: Int
    var Position_valid: Bool
    var Lat: Double
    var Lng: Double
    var Alt: Double
    var GnssDiffFromBaroAlt: Int
    var AltIsGNSS: Bool
    var NIC: Int
    var NACp: Int
    var Track: Double
    var TurnRate: Double
    var Speed: Double
    var Speed_valid: Bool
    var Vvel: Double
    var Timestamp: String
    var PriorityStatus: Int
    var Age: Double
    var AgeLastAlt: Double
    var Last_seen: String
    var Last_alt: String
    var Last_GnssDiff: String
    var Last_GnssDiffAlt: Double
    var Last_speed: String
    var Last_source: Int
    var ExtrapolatedPosition: Bool
    var Last_extrapolation: String
    var AgeExtrapolation: Double
    var Lat_fix: Double
    var Lng_fix: Double
    var Alt_fix: Double
    var BearingDist_valid: Bool
    var Bearing: Double
    var Distance: Double
    var DistanceEstimated: Double
    var DistanceEstimatedLastTs: String
    var ReceivedMsgs: Int
    var IsStratux: Bool
}
