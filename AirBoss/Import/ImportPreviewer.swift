//
//  ImportPreviewer.swift
//  AirBoss
//
//  Created by Doug Haacke on 9/20/24.
//

import Foundation
import SwiftData

@MainActor
struct Previewer {
    let container: ModelContainer
    let aircraft1: Aircraft
    let aircraft2: Aircraft
    let aircraft3: Aircraft
    let icaoType1: IcaoType
    let icaoType2: IcaoType
    let icaoType3: IcaoType

    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Aircraft.self, configurations: config)

        icaoType1 = IcaoType(icaoType: "DXH1", manufacturer: "Douglas", model: "DXH-1000", icon: "L1PL", altIcon: "", date: .now)
        icaoType2 = IcaoType(icaoType: "DXH2", manufacturer: "Douglas", model: "DXH-1000", icon: "L1PL", altIcon: "", date: .now.addingTimeInterval(86400 * -10 ))
        icaoType3 = IcaoType(icaoType: "DXH3", manufacturer: "Douglas", model: "DXH-1000", icon: "L1PL", altIcon: "", date: .now.addingTimeInterval(86400 * 10 ))
        
        aircraft1 = Aircraft(icao: 1, callSign: "DOUG1", reg: "DOUG1", icao_type: icaoType1, owner: "J.Douglas Haacke", mil: "N", alert: "Y", date: .now)
        aircraft2 = Aircraft(icao: 2, callSign: "DOUG2", reg: "DOUG2", icao_type: icaoType2, owner: "J.Douglas Haacke", mil: "N", alert: "Y", date: .now.addingTimeInterval(86400 * -10))
        aircraft3 = Aircraft(icao: 3, callSign: "DOUG3", reg: "DOUG3", icao_type: icaoType2, owner: "J.Douglas Haacke", mil: "N", alert: "Y", date: .now.addingTimeInterval(86400 * 10))
        
        container.mainContext.insert(aircraft1)
        container.mainContext.insert(aircraft2)
        container.mainContext.insert(aircraft3)
    }
}
