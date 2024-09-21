//
//  Aircraft.swift
//  AirBoss
//
//  Created by Doug Haacke on 9/20/24.
//

import Foundation
import SwiftData

@Model
class Aircraft {
    @Attribute(.unique) var icao: Int64 = 0
    var callSign: String = ""
    var reg: String = ""
    var icaoType: IcaoType? = nil
    var owner: String = ""
    var mil: String = ""
    var alert: String = ""
    var date: Date = Date()
    
    init(icao: Int64, callSign: String, reg: String, icao_type: IcaoType, owner: String, mil: String, alert: String, date: Date) {
        self.icao = icao
        self.callSign = callSign
        self.reg = reg
        self.icaoType = icao_type
        self.owner = owner
        self.mil = mil
        self.alert = alert
        self.date = date
    }
}

@Model
class IcaoType {
    @Attribute(.unique) var icaoType: String = ""
    var manufacturer: String = ""
    var model: String = ""
    var icon: String = ""
    var altIcon: String = ""
    var date: Date = Date()
    
    init(icaoType: String, manufacturer: String, model: String, icon: String, altIcon: String, date: Date) {
        self.icaoType = icaoType
        self.manufacturer = manufacturer
        self.model = model
        self.icon = icon
        self.altIcon = altIcon
        self.date = date
    }
}

