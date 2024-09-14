//
//  NotanAnnotationView.swift
//  AirBoss
//
//  Created by Doug Haacke on 9/14/24.
//

import Foundation
import SwiftUI
import MapKit

// Create the custom view
struct NotamAnnotationView: View {
    
    var title: String?
    var subtitle: String?
    var text: String?
    
    var body: some View {
        ZStack {
            Image(systemName: "flame")
            Text(title!)
                .font(.headline)
            Text(subtitle!)
                .font(.subheadline)
        }
    }
}
    

//    var notam: NotamData
//    
//    var notamAnnotation: NotamAnnotation?
//    
//    var body: some View {
//        ZStack {
//            if let notamAnnotation {
//                Image(systemName: notamAnnotation.imageName!)
//                Text(notamAnnotation.title!)
//                    .font(.headline)
//                Text(notamAnnotation.subtitle!)
//                    .font(.subheadline)
//            }
//        }
//        .onAppear() {
//            let notamAnnotation = NotamAnnotation(coordinate: notam.coordinate, title: notam.freq, subtitle: "subtitle", imageName: "flame", text: notam.text)
//        }
//    }

