//
//  RedButtonView.swift
//  AirBoss
//
//  Created by Doug Haacke on 9/22/24.
//

import SwiftUI

struct RedButtonView: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Color(red: 0.5, green: 0, blue: 0.0))
            .foregroundStyle(.white)
            .clipShape(Capsule())
    }
}
