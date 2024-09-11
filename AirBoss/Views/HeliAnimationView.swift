//
//  RotationAnimationView.swift
//  AirBoss
//
//  Created by Doug Haacke on 9/11/24.
//

import SwiftUI

struct HeliAnimation: View {
    @State private var isRotating = 0.0
 
    var body: some View {
        Image("H1PL")
            .renderingMode(.template)
            .resizable()
            .frame(width: 84, height: 84)
            .overlay {
                Image("ROTOR-00")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 84, height: 84)
                    .rotationEffect(.degrees(isRotating))
                    .onAppear {
                        withAnimation(.linear(duration: 1.0)
                            .speed(1.5).repeatForever(autoreverses: false)) {
                            isRotating = 360.0
                        }
                    }
            }
    }
}

#Preview {
    HeliAnimation()
}
