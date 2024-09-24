//
//  AircraftTableView.swift
//  AirBoss
//
//  Created by Doug Haacke on 9/21/24.
//

//
//  IcaoTypeTableView.swift
//  AirBoss
//
//  Created by Doug Haacke on 9/21/24.
//

import SwiftUI
import SwiftData

struct AircraftTableView: View {
    
    @Environment(\.modelContext) var modelContext
    @Query var aircrafts: [Aircraft]

    var body: some View {
        VStack {
            Table(aircrafts) {
                TableColumn("ICAO", value: \.icao.description)
                    .width(min: 60, max: 80)
                TableColumn("Callsign", value: \.callSign)
                    .width(min: 70, max: 80)
                TableColumn("Reg", value: \.reg)
                    .width(min: 70, max: 80)
                TableColumn("Type", value: \.icaoType!.icaoType)
                    .width(min: 50, max: 70)
                TableColumn("Owner", value: \.owner)
                    .width(min: 200, max: 400)
                TableColumn("Mil", value: \.mil)
                    .width(min: 30, max: 40)
                TableColumn("Alert", value: \.alert)
                    .width(min: 40, max: 50)
                TableColumn("Date") { aircraft in
                    Text("\(aircraft.date.format(format: "YYYY-MM-dd"))")
                }
            }
            .tableStyle(.automatic)
            .clipped()
        }
        
    }
    
    init() {
        let distantPast = Date.distantPast
        _aircrafts = Query(filter: #Predicate<Aircraft> { aircraft in
            aircraft.date > distantPast
        }, sort: \Aircraft.icao, order: .forward
           
    )}
}



#Preview {
    IcaoTypeTableView()
}



