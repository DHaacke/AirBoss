//
//  NotanAnnotationView.swift
//  AirBoss
//
//  Created by Doug Haacke on 9/14/24.
//

import Foundation
import SwiftUI
import MapKit

struct ViewSizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

struct ViewGeometry: View {
    var body: some View {
        GeometryReader { geometry in
            Color.clear
                .preference(key: ViewSizeKey.self, value: geometry.size)
        }
    }
}

// Create the custom view
struct NotamAnnotationView: View {
    var title: String?
    var subtitle: String?
    var text: String?
    
    @State private var isShowingNotamText = false
    
    @State var textSize: CGSize = .zero
    
    var body: some View {
        ZStack {
            VStack {
                Image(systemName: "flame")
                    .renderingMode(.original)
                    .symbolVariant(.fill)
                    .foregroundStyle(.yellow)
                    .frame(width: 44, height: 44, alignment: .bottom)
                    .background(.clear)
                    .opacity(0.8)
                    .onTapGesture {
                        isShowingNotamText.toggle()
                    }
                Text(title!)
                    .font(.system(size: 10, weight: .medium))
                    .frame(width: 90, height: 12, alignment: .bottom)
                    .onTapGesture {
                        // print("Tapped at \(location)")
                        isShowingNotamText.toggle()
                    }

                if isShowingNotamText {
                    VStack {
                        HStack() {
                            Spacer()
                            Button {
                                isShowingNotamText.toggle()
                                print("Button pressed")
                            } label: {
                                Image(systemName: "x.circle")
                                    .foregroundColor(.white)
                            }
                            .padding(.top, 10)
                        }
                        .frame(width: 260, height: 12, alignment: .trailing)
                        Text(text!)
                            .font(.system(size: 9.0, weight: .medium))
                            .frame(width: 260, height: CGFloat(((text?.count ?? 260) / 40) * 10), alignment: .topLeading)  // 84 chars per line
                            .padding(8)
                            .minimumScaleFactor(0.9)
                            .background {
                                 Color.colorBlackLight
                            }
                            .onTapGesture {
                                isShowingNotamText.toggle()
                            }
                    }
                    .background {
                         Color.colorBlackLight
                    }
                    .onTapGesture {
                        isShowingNotamText.toggle()
                    }
                } else {
                    VStack {
                        Text(" ")
                    }
                }
            }
            .onTapGesture {
                print("Tapped!")
                isShowingNotamText.toggle()
            }
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

