//
//  RotorView.swift
//  AirBoss
//
//  Created by Doug Haacke on 9/10/24.
//

import SwiftUI

struct RotorView: View {
    @State private var degrees : Double = 45
    
    var body: some View {
        Image(systemName: "ROTOR-00")
            .resizable()
            .frame(width: 30, height: 30, alignment: .center)
            .imageScale(.large)
            .foregroundStyle(.red)
            .padding()
            .background(.clear)
            .rotationEffect(.degrees(degrees))
            // .clipShape(.circle)
            .onAppear() {
                withAnimation(.linear(duration: 1)
                    .speed(0.1).repeatForever(autoreverses: false)) {
                        degrees = degrees <= 360 ? degrees + 45 : 0
                    }
                
            }
    }
}

#Preview {
    RotorView()
}
