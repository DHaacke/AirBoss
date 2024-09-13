//
//  RotationAnimationView.swift
//  AirBoss
//
//  Created by Doug Haacke on 9/11/24.
//

import SwiftUI

struct HeliAnimationView: View {
    @State private var isRotating = 0.0
    
    var bodyName: String
    var rotorName: String
 
    var body: some View {
        Image("H1PL")
            .renderingMode(.template)
            .resizable()
            .frame(width: 36, height: 36)
            .overlay {
                Image("ROTOR-00")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 36, height: 36)
                    .rotationEffect(.degrees(isRotating))
                    .onAppear {
                        withAnimation(.linear(duration: 1.0)
                            .speed(1.2).repeatForever(autoreverses: false)) {
                            isRotating = 360.0
                        }
                    }
            }
    }
}

#Preview {
    HeliAnimationView(bodyName: "H1TL", rotorName: "ROTOR-00")
}
