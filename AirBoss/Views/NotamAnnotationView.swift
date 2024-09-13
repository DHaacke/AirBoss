//
//  NotamAnnotationView.swift
//  AirBoss
//
//  Created by Doug Haacke on 9/11/24.
//

import SwiftUI

struct NotamAnnotationView: View {
    var body: some View {
        Image(systemName: "flame")
            .renderingMode(.template)
            .resizable()
            .frame(width: 30, height: 30)
    }
}

#Preview {
    NotamAnnotationView()
}
