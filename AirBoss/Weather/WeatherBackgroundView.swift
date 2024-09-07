//
//  WeatherBackgroundView.swift
//  AirBoss
//
//  Created by Doug Haacke on 9/4/24.
//

import SwiftUI

struct WeatherBackgroundView: View {
    var body: some View {
        ZStack {
           
            Color.customBlackLight
                .cornerRadius(40)
                .opacity(0.85)
          
            LinearGradient(
                colors: [.customBlackLight, .customBlackDark],
                startPoint: .top,
                endPoint: .bottom
            )
            .cornerRadius(40)
        }
        .overlay(
             RoundedRectangle(cornerRadius: 40)
                .stroke(Color.accentColor, lineWidth: 6)
            )

    }
}

struct WeatherBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
    
    WeatherBackgroundView()
        .padding()
    }
}
