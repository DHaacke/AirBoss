//
//  IcaoTypeTableView.swift
//  AirBoss
//
//  Created by Doug Haacke on 9/21/24.
//

import SwiftUI
import SwiftData

struct IcaoTypeTableView: View {
    
    @Environment(\.modelContext) var modelContext
    // @Query(sort: \IcaoType.icaoType, order: .forward) var icaoTypes: [IcaoType]
    @Query var icaoTypes: [IcaoType]

    var body: some View {
        VStack {
            Table(icaoTypes) {
                TableColumn("Type", value: \.icaoType)
                    .width(min: 50, max: 60)
                TableColumn("Manufacturer", value: \.manufacturer)
                TableColumn("Model", value: \.model)
                TableColumn("Icon", value: \.icon)
                    .width(min: 40, max: 50)
                TableColumn("altIcon", value: \.altIcon)
                    .width(min: 60, max: 70)
                TableColumn("Date") { aircraft in
                    Text("\(aircraft.date.format(format: "YYYY-MM-dd"))")
                }
            }
            .padding()
            .clipped()
        }
        
    }
    
    init() {
        let distantPast = Date.distantPast
        _icaoTypes = Query(filter: #Predicate<IcaoType> { icaoType in
            icaoType.date > distantPast
        }, sort: \IcaoType.icaoType, order: .forward
           
    )}
}



#Preview {
    IcaoTypeTableView()
}



