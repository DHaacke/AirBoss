//
//  ADSB.swift
//  AirBoss
//
//  Created by Doug Haacke on 9/1/24.
//

import Foundation
import SwiftData

@Model
final class ADSB {
    var Icao_addr: Int64
    var Reg: String?
    var Tail: String?
    var OnGound: Bool
    var Squawk: String?
    var Lat: Double
    var Lng: Double
    var Alt: Double
    var Track: Double
    var TurnRate: Double
    var Speed: Double
    var Vvel: Double
    var PriorityStatus: Int
    var Bearing: Double
    var Distance: Double
    
    
    init(Icao_addr: Int64,
         Reg: String?,
         Tail: String?,
         OnGround: Bool,
         Squawk: String?,
         Lat: Double,
         Lng: Double,
         Alt: Double,
         Track: Double,
         TurnRate: Double,
         Speed: Double,
         Vvel: Double,
         PriorityStatus: Int,
         Bearing: Double,
         Distance: Double)
        {
            self.Icao_addr = Icao_addr
            self.Reg = Reg
            self.Tail = Tail
            self.OnGound = OnGround
            self.Squawk = Squawk
            self.Lat = Lat
            self.Lng = Lng
            self.Alt = Alt
            self.Track = Track
            self.TurnRate = TurnRate
            self.Speed = Speed
            self.Vvel = Vvel
            self.PriorityStatus = PriorityStatus
            self.Bearing = Bearing
            self.Distance = Distance
        }
    }
