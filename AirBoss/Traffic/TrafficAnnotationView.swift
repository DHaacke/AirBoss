//
//  TrafficAnnotationView.swift
//  AirBoss
//
//  Created by Doug Haacke on 9/19/24.
//

import Foundation
import SwiftUI
import MapKit

// Create the custom view
struct TrafficAnnotationView: View {
    var traffic: TrafficModel
    
    var body: some View {
        ZStack {
            VStack {
                Image("L1PL")
                    .renderingMode(.original)
                    .rotationEffect(.degrees(Double(traffic.course)))
                    .symbolVariant(.fill)
                    .foregroundStyle(.yellow)
                    .frame(width: 44, height: 44, alignment: .bottom)
                    .background(.clear)
                    .opacity(0.9)
                    .shadow(color: .colorBlackDark, radius: 2, x: 2, y: 2)
                Text(traffic.callSign)
                    .font(.system(size: 10, weight: .medium))
                    .frame(width: 90, height: 12, alignment: .bottom)
            }
       }
       // .animation(.easeInOut(duration: 5.0), value: traffic.course)
   }
}
